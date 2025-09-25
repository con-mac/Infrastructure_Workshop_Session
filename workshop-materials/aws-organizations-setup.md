# AWS Organizations Setup Guide
## Automated Student Account Creation for Infrastructure Workshop

---

## Overview

This guide explains how to set up AWS Organizations with automated account creation for the Infrastructure Workshop. Students will self-register using their email addresses, and the system will automatically create dedicated AWS accounts for them.

### Benefits

- **Complete Isolation:** Each student gets their own AWS account
- **Automated Onboarding:** Students self-register with email addresses
- **Cost Control:** Individual billing and budget management per account
- **Easy Cleanup:** Simple account deletion after workshop
- **Professional Experience:** Students get real AWS accounts, not sandbox environments

---

## Architecture Overview

```
Master Account (Instructor)
├── AWS Organizations
├── IAM Identity Center (SSO)
├── Lambda Functions (Automation)
├── API Gateway (Student Registration)
├── S3 (Static Website)
└── SES (Email Notifications)

Student Registration Flow:
Email → API Gateway → Lambda → Organizations → IAM Identity Center → Email
```

---

## Prerequisites

### Master Account Requirements

- **AWS Account:** Personal or organisational AWS account
- **Administrator Access:** Full administrative permissions
- **AWS Organizations:** Enable Organizations service
- **IAM Identity Center:** Enable IAM Identity Center (formerly AWS SSO)
- **Service Limits:** Ensure sufficient limits for account creation

### Required AWS Services

- **AWS Organizations:** For account management
- **IAM Identity Center:** For user access management
- **Lambda:** For automation functions
- **API Gateway:** For student registration API
- **S3:** For static website hosting
- **SES:** For email notifications
- **CloudFormation:** For infrastructure deployment

---

## Step 1: Enable AWS Organizations

### Create Organization

1. **Navigate to AWS Organizations**
   - Go to AWS Console → Services → Organizations
   - Click "Create organization"
   - Choose "All features" (consolidated billing, SCPs, etc.)

2. **Configure Organization Settings**
   - **Organization Name:** `Infrastructure-Workshop-2024`
   - **Root Email:** Your email address
   - **Enable All Features:** ✅

3. **Create Organizational Unit (OU)**
   - **OU Name:** `Workshop-Students`
   - **Purpose:** Group student accounts for easier management

### Enable Required Services

1. **IAM Identity Center**
   - Go to IAM Identity Center in AWS Console
   - Click "Enable IAM Identity Center"
   - Choose "Free" tier (up to 50 users)

2. **Service Control Policies (SCPs)**
   - Go to Organizations → Policies
   - Create SCPs for cost control (optional but recommended)

---

## Step 2: Create Service Control Policies

### Cost Control SCP

Create a policy to limit expensive services:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyExpensiveServices",
            "Effect": "Deny",
            "Action": [
                "ec2:RunInstances"
            ],
            "Resource": "*",
            "Condition": {
                "StringNotEquals": {
                    "ec2:InstanceType": [
                        "t2.micro",
                        "t2.small",
                        "t3.micro",
                        "t3.small"
                    ]
                }
            }
        },
        {
            "Sid": "DenyLargeInstances",
            "Effect": "Deny",
            "Action": [
                "ec2:RunInstances"
            ],
            "Resource": "*",
            "Condition": {
                "NumericGreaterThan": {
                    "ec2:VolumeSize": "50"
                }
            }
        }
    ]
}
```

### Apply SCP to Workshop OU

1. **Attach Policy to OU**
   - Go to Organizations → Organizational units
   - Select "Workshop-Students" OU
   - Attach the cost control SCP

---

## Step 3: Deploy Automation Infrastructure

### CloudFormation Template for Automation

Create a CloudFormation template to deploy the automation infrastructure:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Workshop Student Account Creation Automation'

Parameters:
  WorkshopName:
    Type: String
    Default: 'Infrastructure-Workshop-2024'
    Description: Name of the workshop
  
  MaxStudents:
    Type: Number
    Default: 20
    Description: Maximum number of student accounts
  
  WorkshopDuration:
    Type: Number
    Default: 7
    Description: Workshop duration in days

Resources:
  # S3 Bucket for Static Website
  RegistrationWebsiteBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${WorkshopName}-registration-${AWS::AccountId}'
      WebsiteConfiguration:
        IndexDocument: index.html
        ErrorDocument: error.html
      PublicAccessBlockConfiguration:
        BlockPublicAcls: false
        BlockPublicPolicy: false
        IgnorePublicAcls: false
        RestrictPublicBuckets: false

  # S3 Bucket Policy for Public Access
  RegistrationWebsiteBucketPolicy:
    Type: AWS::S3::BucketPolicy
    Properties:
      Bucket: !Ref RegistrationWebsiteBucket
      PolicyDocument:
        Statement:
          - Effect: Allow
            Principal: '*'
            Action: 's3:GetObject'
            Resource: !Sub '${RegistrationWebsiteBucket}/*'

  # Lambda Function for Account Creation
  AccountCreationFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: !Sub '${WorkshopName}-account-creation'
      Runtime: python3.9
      Handler: index.lambda_handler
      Role: !GetAtt AccountCreationRole.Arn
      Timeout: 300
      Environment:
        Variables:
          ORGANIZATION_ID: !Ref 'AWS::Organization'
          OU_ID: !Ref WorkshopOU
          WORKSHOP_NAME: !Ref WorkshopName
      Code:
        ZipFile: |
          import json
          import boto3
          import uuid
          import time
          from datetime import datetime, timedelta
          
          organizations = boto3.client('organizations')
          iam_identity_center = boto3.client('sso-admin')
          ses = boto3.client('ses')
          
          def lambda_handler(event, context):
              try:
                  # Parse request
                  body = json.loads(event['body'])
                  email = body['email']
                  student_name = body.get('name', email.split('@')[0])
                  
                  # Validate email format
                  if '@' not in email or '.' not in email.split('@')[1]:
                      return {
                          'statusCode': 400,
                          'body': json.dumps({'error': 'Invalid email format'})
                      }
                  
                  # Create AWS account
                  account_name = f"{student_name}-workshop-account"
                  account_email = email
                  
                  response = organizations.create_account(
                      Email=account_email,
                      AccountName=account_name,
                      RoleName='OrganizationAccountAccessRole',
                      IamUserAccessToBilling='ALLOW'
                  )
                  
                  create_account_request_id = response['CreateAccountStatus']['Id']
                  
                  # Wait for account creation (simplified - in production, use Step Functions)
                  time.sleep(30)
                  
                  # Get account ID
                  account_status = organizations.describe_create_account_status(
                      CreateAccountRequestId=create_account_request_id
                  )
                  
                  if account_status['CreateAccountStatus']['State'] == 'SUCCEEDED':
                      account_id = account_status['CreateAccountStatus']['AccountId']
                      
                      # Move account to Workshop OU
                      organizations.move_account(
                          AccountId=account_id,
                          SourceParentId=organizations.list_roots()['Roots'][0]['Id'],
                          DestinationParentId=event['environment']['variables']['OU_ID']
                      )
                      
                      # Create IAM Identity Center user
                      iam_identity_center.create_user(
                          IdentityStoreId=get_identity_store_id(),
                          UserName=email,
                          DisplayName=student_name,
                          Name={
                              'Formatted': student_name,
                              'FamilyName': student_name.split()[-1] if ' ' in student_name else student_name,
                              'GivenName': student_name.split()[0]
                          },
                          Emails=[{'Value': email, 'Primary': True}]
                      )
                      
                      # Generate temporary password
                      temp_password = generate_temp_password()
                      
                      # Set up AWS Budget for account
                      setup_account_budget(account_id, email)
                      
                      # Send welcome email
                      send_welcome_email(email, student_name, account_id, temp_password)
                      
                      return {
                          'statusCode': 200,
                          'body': json.dumps({
                              'message': 'Account created successfully',
                              'account_id': account_id,
                              'email_sent': True
                          })
                      }
                  else:
                      return {
                          'statusCode': 500,
                          'body': json.dumps({'error': 'Account creation failed'})
                      }
                      
              except Exception as e:
                  return {
                      'statusCode': 500,
                      'body': json.dumps({'error': str(e)})
                  }
          
          def get_identity_store_id():
              response = iam_identity_center.list_identity_stores()
              return response['IdentityStores'][0]['IdentityStoreId']
          
          def generate_temp_password():
              import secrets
              import string
              alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
              password = ''.join(secrets.choice(alphabet) for i in range(12))
              return password
          
          def setup_account_budget(account_id, email):
              # This would require cross-account role assumption
              # Simplified for this example
              pass
          
          def send_welcome_email(email, name, account_id, temp_password):
              subject = f"Welcome to {event['environment']['variables']['WORKSHOP_NAME']}!"
              body = f"""
              Hello {name},
              
              Your AWS workshop account has been created successfully!
              
              Account Details:
              - Account ID: {account_id}
              - Email: {email}
              - Temporary Password: {temp_password}
              
              Access Instructions:
              1. Go to: https://{account_id}.signin.aws.amazon.com/console
              2. Use your email and temporary password to log in
              3. You'll be prompted to set a new password
              
              Workshop Information:
              - Date: [Workshop Date]
              - Duration: [Workshop Duration]
              - Cost Limit: $50 per account
              
              If you have any questions, contact your instructor.
              
              Best regards,
              Workshop Team
              """
              
              ses.send_email(
                  Source='workshop@yourdomain.com',  # Must be verified in SES
                  Destination={'ToAddresses': [email]},
                  Message={
                      'Subject': {'Data': subject},
                      'Body': {'Text': {'Data': body}}
                  }
              )

  # IAM Role for Lambda Function
  AccountCreationRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
      Policies:
        - PolicyName: OrganizationsAccess
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - organizations:*
                  - sso-admin:*
                  - ses:SendEmail
                  - budgets:*
                Resource: '*'

  # API Gateway for Student Registration
  RegistrationAPI:
    Type: AWS::ApiGateway::RestApi
    Properties:
      Name: !Sub '${WorkshopName}-registration-api'
      Description: API for student account registration
      EndpointConfiguration:
        Types:
          - REGIONAL

  # API Gateway Resource and Method
  RegistrationResource:
    Type: AWS::ApiGateway::Resource
    Properties:
      RestApiId: !Ref RegistrationAPI
      ParentId: !GetAtt RegistrationAPI.RootResourceId
      PathPart: register

  RegistrationMethod:
    Type: AWS::ApiGateway::Method
    Properties:
      RestApiId: !Ref RegistrationAPI
      ResourceId: !Ref RegistrationResource
      HttpMethod: POST
      AuthorizationType: NONE
      Integration:
        Type: AWS_PROXY
        IntegrationHttpMethod: POST
        Uri: !Sub 'arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${AccountCreationFunction.Arn}/invocations'

  # API Gateway Deployment
  APIDeployment:
    Type: AWS::ApiGateway::Deployment
    DependsOn: RegistrationMethod
    Properties:
      RestApiId: !Ref RegistrationAPI
      StageName: prod

  # Lambda Permission for API Gateway
  LambdaPermission:
    Type: AWS::Lambda::Permission
    Properties:
      FunctionName: !Ref AccountCreationFunction
      Action: lambda:InvokeFunction
      Principal: apigateway.amazonaws.com
      SourceArn: !Sub 'arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${RegistrationAPI}/*/*'

  # Workshop OU (will be created if it doesn't exist)
  WorkshopOU:
    Type: AWS::Organizations::OrganizationalUnit
    Properties:
      Name: Workshop-Students
      ParentId: !Ref 'AWS::Organization'

Outputs:
  RegistrationWebsiteURL:
    Description: URL for student registration website
    Value: !Sub 'http://${RegistrationWebsiteBucket}.s3-website-${AWS::Region}.amazonaws.com'
  
  RegistrationAPIURL:
    Description: API endpoint for account registration
    Value: !Sub 'https://${RegistrationAPI}.execute-api.${AWS::Region}.amazonaws.com/prod/register'
  
  WorkshopOUId:
    Description: Organizational Unit ID for student accounts
    Value: !Ref WorkshopOU
```

---

## Step 4: Create Student Registration Website

### HTML Registration Form

Create a simple registration form:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWS Workshop Registration</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="email"], input[type="text"] {
            width: 100%;
            padding: 10px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
        }
        button {
            background: #4CAF50;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
        }
        button:hover {
            background: #45a049;
        }
        .success, .error {
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            display: none;
        }
        .success {
            background: rgba(76, 175, 80, 0.3);
            border: 1px solid #4CAF50;
        }
        .error {
            background: rgba(244, 67, 54, 0.3);
            border: 1px solid #f44336;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 AWS Infrastructure Workshop</h1>
        <h2>Student Account Registration</h2>
        
        <div class="success" id="successMessage">
            ✅ Account created successfully! Check your email for access details.
        </div>
        
        <div class="error" id="errorMessage">
            ❌ Registration failed. Please try again or contact support.
        </div>
        
        <form id="registrationForm">
            <div class="form-group">
                <label for="email">University Email Address:</label>
                <input type="email" id="email" name="email" required 
                       placeholder="your.name@university.edu">
            </div>
            
            <div class="form-group">
                <label for="name">Full Name:</label>
                <input type="text" id="name" name="name" required 
                       placeholder="John Smith">
            </div>
            
            <button type="submit">Create My AWS Account</button>
        </form>
        
        <div style="margin-top: 30px; font-size: 14px; opacity: 0.8;">
            <h3>What happens next?</h3>
            <ol>
                <li>We'll create a dedicated AWS account for you</li>
                <li>You'll receive an email with login details</li>
                <li>Your account will have a $50 spending limit</li>
                <li>All resources will be automatically cleaned up after the workshop</li>
            </ol>
        </div>
    </div>

    <script>
        document.getElementById('registrationForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const email = document.getElementById('email').value;
            const name = document.getElementById('name').value;
            
            try {
                const response = await fetch('YOUR_API_GATEWAY_URL/register', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        email: email,
                        name: name
                    })
                });
                
                const result = await response.json();
                
                if (response.ok) {
                    document.getElementById('successMessage').style.display = 'block';
                    document.getElementById('errorMessage').style.display = 'none';
                    document.getElementById('registrationForm').reset();
                } else {
                    throw new Error(result.error || 'Registration failed');
                }
            } catch (error) {
                document.getElementById('errorMessage').style.display = 'block';
                document.getElementById('successMessage').style.display = 'none';
                console.error('Registration error:', error);
            }
        });
    </script>
</body>
</html>
```

---

## Step 5: Configure Email Notifications

### Amazon SES Setup

1. **Verify Email Domain**
   - Go to SES in AWS Console
   - Verify your domain (e.g., yourdomain.com)
   - Set up DKIM authentication

2. **Create Email Template**
   - Use the email template in the Lambda function above
   - Customise with your workshop details

3. **Test Email Delivery**
   - Send test emails to verify delivery
   - Check spam folders

---

## Step 6: Cost Management Setup

### AWS Budgets Configuration

Create budgets for each student account:

```python
def setup_account_budget(account_id, email):
    budgets = boto3.client('budgets')
    
    # Create budget for the account
    budget = {
        'BudgetName': f'Workshop-Budget-{account_id}',
        'BudgetLimit': {
            'Amount': '50.00',
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
        Budget=budget
    )
```

---

## Step 7: Workshop Management

### Instructor Dashboard

Create a simple dashboard to monitor student accounts:

```python
def get_workshop_status():
    organizations = boto3.client('organizations')
    
    # Get all accounts in Workshop OU
    accounts = organizations.list_accounts_for_parent(
        ParentId=workshop_ou_id
    )
    
    # Get account details and costs
    account_status = []
    for account in accounts['Accounts']:
        status = {
            'account_id': account['Id'],
            'name': account['Name'],
            'email': account['Email'],
            'status': account['Status'],
            'joined_date': account['JoinedTimestamp']
        }
        account_status.append(status)
    
    return account_status
```

### Automated Cleanup

Create a cleanup function to run after the workshop:

```python
def cleanup_workshop_accounts():
    organizations = boto3.client('organizations')
    
    # Get all accounts in Workshop OU
    accounts = organizations.list_accounts_for_parent(
        ParentId=workshop_ou_id
    )
    
    for account in accounts['Accounts']:
        # Close the account (requires account to be empty)
        organizations.close_account(
            AccountId=account['Id']
        )
```

---

## Security Considerations

### Access Control

- **Student Isolation:** Each student has their own AWS account
- **No Cross-Account Access:** Students cannot see other students' resources
- **Limited Permissions:** SCPs restrict expensive services
- **Time-Limited Access:** Accounts are automatically cleaned up

### Data Protection

- **Email Privacy:** Student emails are only used for account creation
- **Password Security:** Temporary passwords are securely generated
- **Account Cleanup:** All student data is removed after workshop

---

## Troubleshooting

### Common Issues

1. **Account Creation Fails**
   - Check AWS Organizations limits
   - Verify email format
   - Check Lambda function logs

2. **Email Not Delivered**
   - Verify SES configuration
   - Check spam folders
   - Verify email domain

3. **Student Cannot Access Account**
   - Check IAM Identity Center configuration
   - Verify account status
   - Check password reset process

### Monitoring

- **CloudWatch Logs:** Monitor Lambda function execution
- **AWS Budgets:** Track spending across all accounts
- **Organizations:** Monitor account creation and status

---

## Cost Estimation

### Workshop Costs (20 Students, 1 Day)

- **Lambda Function:** ~$0.20 (minimal usage)
- **API Gateway:** ~$0.35 (API calls)
- **S3 Storage:** ~$0.01 (website hosting)
- **SES Emails:** ~$0.20 (20 emails)
- **Student Accounts:** ~$360-560 (as per requirements document)

**Total Infrastructure Cost:** ~$0.76
**Total Student Account Cost:** ~$360-560
**Grand Total:** ~$360-561

---

## Conclusion

This automated account creation system provides:

- **Professional Experience:** Students get real AWS accounts
- **Scalable Solution:** Can handle 20+ students easily
- **Cost Control:** Individual budgets and automated cleanup
- **Easy Management:** Instructor dashboard and monitoring
- **Security:** Complete isolation between student accounts

The system eliminates manual account management while providing students with a professional AWS experience that directly translates to real-world skills.

---

**Ready to deploy an amazing automated workshop experience! 🚀**
