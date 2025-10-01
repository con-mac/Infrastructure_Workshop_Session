import json
import boto3
import uuid
import time
import logging
import secrets
import string
import os
from datetime import datetime, timedelta
from typing import Dict, Any, Optional

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
organizations = boto3.client('organizations')
sso_admin = boto3.client('sso-admin')
ses = boto3.client('ses')
budgets = boto3.client('budgets')
cloudformation = boto3.client('cloudformation')

# Configuration
WORKSHOP_NAME = 'Infrastructure-Workshop-2025'
WORKSHOP_DURATION_DAYS = 7
MAX_STUDENTS = 8
BUDGET_LIMIT = 10.00

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Main Lambda handler for creating student AWS accounts
    """
    try:
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Handle CORS preflight requests
        if event.get('httpMethod') == 'OPTIONS':
            return create_response(200, {'message': 'CORS preflight'})
        
        # Parse request body
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
            
        email = body.get('email', '').strip().lower()
        name = body.get('name', '').strip()
        student_id = body.get('studentId', '').strip()
        
        # Validate inputs
        validation_result = validate_inputs(email, name)
        if not validation_result['valid']:
            return create_response(400, {'error': validation_result['error']})
        
        # Check if account already exists
        existing_account = check_existing_account(email)
        if existing_account:
            return create_response(409, {
                'error': 'Account already exists',
                'account_id': existing_account['Id']
            })
        
        # Check workshop capacity
        if not check_workshop_capacity():
            return create_response(503, {
                'error': 'Workshop is at full capacity. Please contact your instructor.'
            })
        
        # Create AWS account
        account_result = create_aws_account(email, name)
        if not account_result['success']:
            return create_response(500, {'error': account_result['error']})
        
        # Get the account ID from the create request
        create_request_id = account_result['create_account_request_id']
        
        # Wait for account to be created (this is necessary to get the account ID)
        # Note: This simplified version returns immediately but logs the request ID
        # In a production system, you'd use an async workflow or Step Functions
        logger.info(f"Account creation request initiated: {create_request_id}")
        
        # Return success immediately (account creation happens asynchronously)
        return create_response(200, {
            'message': 'Account creation initiated successfully',
            'create_account_request_id': create_request_id,
            'email': email,
            'name': name,
            'workshop_info': {
                'name': WORKSHOP_NAME,
                'duration_days': WORKSHOP_DURATION_DAYS,
                'budget_limit': BUDGET_LIMIT
            },
            'note': 'Your account is being created. This may take 5-10 minutes. You will receive an email when ready.'
        })
        
        # Create IAM Identity Center user
        user_result = create_sso_user(email, name)
        if not user_result['success']:
            logger.warning(f"Failed to create SSO user for {email}: {user_result['error']}")
        
        # Set up budget and monitoring
        setup_account_monitoring(account_id, email, name)
        
        # Send welcome email
        email_result = send_welcome_email(email, name, account_id, account_result.get('temp_password'))
        
        # Log successful registration
        log_registration(email, name, student_id, account_id)
        
        return create_response(200, {
            'message': 'Account created successfully',
            'account_id': account_id,
            'email_sent': email_result['success'],
            'workshop_info': {
                'name': WORKSHOP_NAME,
                'duration_days': WORKSHOP_DURATION_DAYS,
                'budget_limit': BUDGET_LIMIT
            }
        })
        
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}", exc_info=True)
        return create_response(500, {
            'error': 'Internal server error. Please contact support.'
        })

def validate_inputs(email: str, name: str) -> Dict[str, Any]:
    """Validate input parameters"""
    
    if not email:
        return {'valid': False, 'error': 'Email address is required'}
    
    if not name:
        return {'valid': False, 'error': 'Full name is required'}
    
    # Validate email format
    if '@' not in email or '.' not in email.split('@')[1]:
        return {'valid': False, 'error': 'Invalid email format'}
    
    # Check for university email domains (optional validation)
    university_domains = ['.edu', '.ac.uk', '.university.edu']
    if not any(domain in email for domain in university_domains):
        logger.warning(f"Non-university email detected: {email}")
    
    # Validate name length
    if len(name) < 2 or len(name) > 50:
        return {'valid': False, 'error': 'Name must be between 2 and 50 characters'}
    
    return {'valid': True}

def check_existing_account(email: str) -> Optional[Dict[str, Any]]:
    """Check if account already exists for this email"""
    try:
        # Get workshop OU ID
        workshop_ou_id = get_workshop_ou_id()
        
        # List accounts in workshop OU
        response = organizations.list_accounts_for_parent(ParentId=workshop_ou_id)
        
        for account in response['Accounts']:
            if account['Email'].lower() == email.lower():
                return account
                
        return None
        
    except Exception as e:
        logger.error(f"Error checking existing account: {str(e)}")
        return None

def check_workshop_capacity() -> bool:
    """Check if workshop has capacity for more students"""
    try:
        workshop_ou_id = get_workshop_ou_id()
        response = organizations.list_accounts_for_parent(ParentId=workshop_ou_id)
        
        current_count = len(response['Accounts'])
        return current_count < MAX_STUDENTS
        
    except Exception as e:
        logger.error(f"Error checking workshop capacity: {str(e)}")
        return False

def create_aws_account(email: str, name: str) -> Dict[str, Any]:
    """Create new AWS account"""
    try:
        # Generate account name
        account_name = f"{name.replace(' ', '-')}-workshop-account"
        
        # Create account
        response = organizations.create_account(
            Email=email,
            AccountName=account_name,
            RoleName='OrganizationAccountAccessRole',
            IamUserAccessToBilling='ALLOW'
        )
        
        create_account_request_id = response['CreateAccountStatus']['Id']
        
        logger.info(f"Account creation initiated for {email}: {create_account_request_id}")
        
        # Generate temporary password for SSO
        temp_password = generate_temp_password()
        
        return {
            'success': True,
            'account_id': None,  # Will be populated when account is ready
            'create_account_request_id': create_account_request_id,
            'temp_password': temp_password
        }
        
    except Exception as e:
        logger.error(f"Error creating AWS account: {str(e)}")
        return {'success': False, 'error': str(e)}

def wait_for_account_ready(account_id: str) -> bool:
    """Wait for account to be ready (simplified version)"""
    max_wait_time = 300  # 5 minutes
    wait_interval = 30   # 30 seconds
    
    for _ in range(max_wait_time // wait_interval):
        try:
            response = organizations.describe_account(AccountId=account_id)
            if response['Account']['Status'] == 'ACTIVE':
                return True
            time.sleep(wait_interval)
        except Exception as e:
            logger.error(f"Error checking account status: {str(e)}")
            time.sleep(wait_interval)
    
    return False

def move_account_to_workshop_ou(account_id: str) -> bool:
    """Move account to workshop OU"""
    try:
        # Get root ID and workshop OU ID
        root_id = organizations.list_roots()['Roots'][0]['Id']
        workshop_ou_id = get_workshop_ou_id()
        
        # Move account
        organizations.move_account(
            AccountId=account_id,
            SourceParentId=root_id,
            DestinationParentId=workshop_ou_id
        )
        
        logger.info(f"Account {account_id} moved to workshop OU")
        return True
        
    except Exception as e:
        logger.error(f"Error moving account to workshop OU: {str(e)}")
        return False

def create_sso_user(email: str, name: str) -> Dict[str, Any]:
    """Create IAM Identity Center user"""
    try:
        # Get identity store ID
        identity_store_id = get_identity_store_id()
        
        # Create user
        sso_admin.create_user(
            IdentityStoreId=identity_store_id,
            UserName=email,
            DisplayName=name,
            Name={
                'Formatted': name,
                'FamilyName': name.split()[-1] if ' ' in name else name,
                'GivenName': name.split()[0]
            },
            Emails=[{'Value': email, 'Primary': True}]
        )
        
        logger.info(f"SSO user created for {email}")
        return {'success': True}
        
    except Exception as e:
        logger.error(f"Error creating SSO user: {str(e)}")
        return {'success': False, 'error': str(e)}

def setup_account_monitoring(account_id: str, email: str, name: str) -> bool:
    """Set up budget and monitoring for the account"""
    try:
        # Create budget
        budget_name = f"Workshop-Budget-{account_id}"
        
        budget_config = {
            'BudgetName': budget_name,
            'BudgetLimit': {
                'Amount': str(BUDGET_LIMIT),
                'Unit': 'USD'
            },
            'TimeUnit': 'MONTHLY',
            'BudgetType': 'COST',
            'CostFilters': {
                'Account': [account_id]
            },
            'NotificationsWithSubscribers': [
                {
                    'Notification': {
                        'NotificationType': 'ACTUAL',
                        'ComparisonOperator': 'GREATER_THAN',
                        'Threshold': 80,
                        'ThresholdType': 'PERCENTAGE'
                    },
                    'Subscribers': [
                        {
                            'SubscriptionType': 'EMAIL',
                            'Address': email
                        }
                    ]
                }
            ]
        }
        
        budgets.create_budget(
            AccountId=account_id,
            Budget=budget_config
        )
        
        # Tag the account
        organizations.tag_resource(
            ResourceId=account_id,
            Tags=[
                {'Key': 'Workshop', 'Value': WORKSHOP_NAME},
                {'Key': 'StudentEmail', 'Value': email},
                {'Key': 'StudentName', 'Value': name},
                {'Key': 'CreatedDate', 'Value': datetime.now().isoformat()},
                {'Key': 'BudgetLimit', 'Value': str(BUDGET_LIMIT)}
            ]
        )
        
        logger.info(f"Monitoring setup complete for account {account_id}")
        return True
        
    except Exception as e:
        logger.error(f"Error setting up monitoring: {str(e)}")
        return False

def send_welcome_email(email: str, name: str, account_id: str, temp_password: Optional[str] = None) -> Dict[str, Any]:
    """Send welcome email with account details"""
    try:
        subject = f"Welcome to {WORKSHOP_NAME}!"
        
        # Create email body
        body_html = create_welcome_email_html(name, account_id, temp_password)
        body_text = create_welcome_email_text(name, account_id, temp_password)
        
        # Send email
        ses.send_email(
            Source='workshop@yourdomain.com',  # Must be verified in SES
            Destination={'ToAddresses': [email]},
            Message={
                'Subject': {'Data': subject},
                'Body': {
                    'Html': {'Data': body_html},
                    'Text': {'Data': body_text}
                }
            }
        )
        
        logger.info(f"Welcome email sent to {email}")
        return {'success': True}
        
    except Exception as e:
        logger.error(f"Error sending welcome email: {str(e)}")
        return {'success': False, 'error': str(e)}

def create_welcome_email_html(name: str, account_id: str, temp_password: Optional[str] = None) -> str:
    """Create HTML welcome email"""
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
            .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
            .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 10px 10px 0 0; text-align: center; }}
            .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
            .account-details {{ background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #667eea; }}
            .button {{ background: #667eea; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 10px 0; }}
            .warning {{ background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚀 Welcome to {WORKSHOP_NAME}!</h1>
                <p>Your AWS account is ready</p>
            </div>
            
            <div class="content">
                <p>Hello {name},</p>
                
                <p>Congratulations! Your dedicated AWS account has been created successfully and is ready for the workshop.</p>
                
                <div class="account-details">
                    <h3>📋 Your Account Details</h3>
                    <ul>
                        <li><strong>Account ID:</strong> {account_id}</li>
                        <li><strong>Email:</strong> {email}</li>
                        <li><strong>Budget Limit:</strong> ${BUDGET_LIMIT}</li>
                        <li><strong>Workshop Duration:</strong> {WORKSHOP_DURATION_DAYS} days</li>
                    </ul>
                </div>
                
                <h3>🔑 How to Access Your Account</h3>
                <ol>
                    <li>Go to: <a href="https://{account_id}.signin.aws.amazon.com/console">AWS Console</a></li>
                    <li>Use your email address to log in</li>
                    <li>Follow the prompts to set up your account</li>
                </ol>
                
                <div class="warning">
                    <h4>⚠️ Important Information</h4>
                    <ul>
                        <li>Your account has a ${BUDGET_LIMIT} spending limit</li>
                        <li>All resources will be automatically cleaned up after the workshop</li>
                        <li>Your account is isolated from other students</li>
                        <li>Contact your instructor if you encounter any issues</li>
                    </ul>
                </div>
                
                <h3>📚 Workshop Resources</h3>
                <p>Your instructor will provide:</p>
                <ul>
                    <li>Lab guide and instructions</li>
                    <li>CloudFormation templates</li>
                    <li>Challenge scenarios</li>
                    <li>Support throughout the workshop</li>
                </ul>
                
                <p>We're excited to have you join us for this hands-on AWS learning experience!</p>
                
                <p>Best regards,<br>
                The Workshop Team</p>
            </div>
        </div>
    </body>
    </html>
    """

def create_welcome_email_text(name: str, account_id: str, temp_password: Optional[str] = None) -> str:
    """Create text welcome email"""
    return f"""
Welcome to {WORKSHOP_NAME}!

Hello {name},

Your dedicated AWS account has been created successfully!

Account Details:
- Account ID: {account_id}
- Budget Limit: ${BUDGET_LIMIT}
- Workshop Duration: {WORKSHOP_DURATION_DAYS} days

How to Access Your Account:
1. Go to: https://{account_id}.signin.aws.amazon.com/console
2. Use your email address to log in
3. Follow the prompts to set up your account

Important Information:
- Your account has a ${BUDGET_LIMIT} spending limit
- All resources will be automatically cleaned up after the workshop
- Your account is isolated from other students
- Contact your instructor if you encounter any issues

Workshop Resources:
Your instructor will provide lab guides, CloudFormation templates, 
challenge scenarios, and support throughout the workshop.

We're excited to have you join us for this hands-on AWS learning experience!

Best regards,
The Workshop Team
"""

def generate_temp_password() -> str:
    """Generate a secure temporary password"""
    alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
    password = ''.join(secrets.choice(alphabet) for _ in range(12))
    return password

def get_workshop_ou_id() -> str:
    """Get the workshop OU ID"""
    try:
        # This would typically be stored as an environment variable
        # or retrieved from a configuration service
        return os.environ.get('WORKSHOP_OU_ID', 'ou-xxxx-xxxxxxxx')
    except Exception as e:
        logger.error(f"Error getting workshop OU ID: {str(e)}")
        raise

def get_identity_store_id() -> str:
    """Get IAM Identity Center store ID"""
    try:
        response = sso_admin.list_identity_stores()
        return response['IdentityStores'][0]['IdentityStoreId']
    except Exception as e:
        logger.error(f"Error getting identity store ID: {str(e)}")
        raise

def log_registration(email: str, name: str, student_id: str, account_id: str) -> None:
    """Log successful registration"""
    logger.info(f"Registration completed - Email: {email}, Name: {name}, Student ID: {student_id}, Account ID: {account_id}")

def create_response(status_code: int, body: Dict[str, Any]) -> Dict[str, Any]:
    """Create API Gateway response"""
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type'
        },
        'body': json.dumps(body)
    }
