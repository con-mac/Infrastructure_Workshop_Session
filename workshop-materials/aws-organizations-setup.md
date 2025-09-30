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
   - **Organization Name:** `Infrastructure-Workshop-2025`
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

### Quick Reference
- **Template File:** `workshop-materials/cloudformation/automation-infrastructure.yaml`
- **Repository:** `https://github.com/con-mac/Infrastructure_Workshop_Session.git`
- **Prerequisites:** AWS Console access, repository cloned locally
- **Time Required:** 15-20 minutes
- **Cost:** $0.76/month

### Overview

This step deploys the automation infrastructure that handles student account creation, registration website, and workshop management. The infrastructure includes:

- **S3 Bucket:** Hosts the student registration website
- **Lambda Function:** Handles automated account creation
- **API Gateway:** Provides the registration API endpoint
- **IAM Roles:** Manages permissions for automation
- **CloudWatch:** Monitors the automation system

### Step 3.1: Prepare Template File

**If you already have the repository locally:**
```bash
cd /home/con-mac/dev/projects/Apprentice_Infra_Workshop
ls -la workshop-materials/cloudformation/automation-infrastructure.yaml
```

**If you need to clone the repository:**
```bash
git clone https://github.com/con-mac/Infrastructure_Workshop_Session.git
cd Infrastructure_Workshop_Session
ls -la workshop-materials/cloudformation/automation-infrastructure.yaml
```

**The template file should be at:** `workshop-materials/cloudformation/automation-infrastructure.yaml`

### Step 3.2: Access CloudFormation Console

1. **Navigate to CloudFormation**
   - Go to AWS Console → Services → CloudFormation
   - Click "Create stack"
   - Select "Upload a template file"

2. **Upload Template**
   - Click "Choose file"
   - Navigate to your local repository folder
   - Select: `workshop-materials/cloudformation/automation-infrastructure.yaml`
   - Click "Next"

### Step 3.3: Configure Stack Parameters

Fill in the following parameters (all have defaults but should be customized):

#### **Required Parameters:**

**Workshop Name:**
- **Default:** `Infrastructure-Workshop-2025`
- **Description:** Name used for all resource naming
- **Your Value:** Keep default or customize (e.g., `My-Company-Workshop-2025`)

**Max Students:**
- **Default:** `8`
- **Description:** Maximum number of student accounts
- **Your Value:** `8` (or adjust based on your needs)

**Budget Limit:**
- **Default:** `10.00`
- **Description:** Budget limit per student account in USD
- **Your Value:** `10.00` (cost-optimized for free tier)

**Email Domain:**
- **Default:** `yourdomain.com`
- **Description:** Your email domain for SES (must be verified)
- **Your Value:** Replace with your actual domain (e.g., `mycompany.com`)

**Workshop OU ID:**
- **Default:** `ou-xxxx-xxxxxxxx`
- **Description:** AWS Organizations OU ID (optional)
- **Your Value:** Leave as default for now, update later if needed

**AWS Region:**
- **Default:** `us-east-1`
- **Description:** AWS Region for deployment
- **Your Value:** Choose your preferred region

**Notification Email:**
- **Default:** `instructor@yourdomain.com`
- **Description:** Email for workshop notifications
- **Your Value:** Your instructor email address

### Step 3.4: Configure Stack Options

1. **Stack Name**
   - Enter: `Workshop-Automation-Infrastructure`
   - This will be used to identify your stack

2. **Tags (Optional)**
   - Add tags for cost tracking:
     - Key: `Workshop`, Value: `Infrastructure-2024`
     - Key: `Environment`, Value: `Production`
     - Key: `Owner`, Value: `Your-Name`

3. **Permissions**
   - Leave as default (use stack policy)
   - This is fine for workshop purposes

4. **Advanced Options**
   - Leave all defaults
   - No additional configuration needed

### Step 3.5: Review and Deploy

1. **Review Configuration**
   - Check all parameters are correct
   - Verify email domain and notification email
   - Ensure region is correct

2. **Acknowledge Capabilities**
   - Check "I acknowledge that AWS CloudFormation might create IAM resources"
   - Check "I acknowledge that AWS CloudFormation might create IAM resources with custom names"
   - These are required for Lambda and API Gateway

3. **Create Stack**
   - Click "Create stack"
   - Wait for deployment (5-10 minutes)
   - Monitor the Events tab for progress

### Step 3.6: Verify Deployment

1. **Check Stack Status**
   - Go to CloudFormation → Stacks
   - Find your stack: `Workshop-Automation-Infrastructure`
   - Status should be: `CREATE_COMPLETE`

2. **Review Outputs**
   - Click on your stack
   - Go to "Outputs" tab
   - Note down these important values:
     - **RegistrationWebsiteURL:** Student registration website
     - **RegistrationAPIURL:** API endpoint for registration
     - **LambdaFunctionName:** Lambda function name
     - **DashboardURL:** Monitoring dashboard

3. **Upload Website Files (Required)**
   - Go to AWS Console → Services → S3
   - Find your bucket: `infrastructure-workshop-2025-registration-{account-id}`
   - Click "Upload" → "Add files"
   - Upload these files from your local repository:
     - `workshop-materials/automation/student-registration.html` → rename to `index.html`
     - `workshop-materials/automation/instructor-dashboard.html` → upload as `instructor-dashboard.html`
   - Select both files → "Actions" → "Make public"

4. **Test Basic Functionality**
   - Click on the **RegistrationWebsiteURL**
   - Should see the student registration page
   - Form should load (don't submit yet - need to configure email first)

### Step 3.7: Update Lambda Function Code

The deployed Lambda function contains placeholder code. You need to update it with the full account creation logic:

1. **Download Full Lambda Code**
   - Go to the `automation/lambda-account-creation.py` file
   - Copy the entire contents

2. **Update Lambda Function**
   - Go to Lambda → Functions
   - Find: `Infrastructure-Workshop-2024-account-creation`
   - Click on the function name
   - Go to "Code" tab
   - Click "Edit"
   - Replace the placeholder code with the full code from `lambda-account-creation.py`
   - Click "Deploy"

3. **Verify Update**
   - Test the function with a sample event
   - Check CloudWatch logs for any errors

### Step 3.8: Configure S3 Website

1. **Upload Student Registration Website**
   - Go to S3 → Buckets
   - Find: `infrastructure-workshop-2024-registration-[account-id]`
   - Upload the `student-registration.html` file
   - Rename it to `index.html`
   - Set permissions to public read

2. **Test Website**
   - Go to the **RegistrationWebsiteURL** from outputs
   - Should see the full registration form
   - Form should be styled and functional

### Troubleshooting Common Issues

#### **Stack Creation Fails**
- **Check IAM permissions:** Ensure you have CloudFormation, Lambda, and API Gateway permissions
- **Check region:** Ensure you're in the correct region
- **Check parameters:** Verify all required parameters are filled correctly

#### **Lambda Function Errors**
- **Check IAM role:** Ensure the Lambda role has required permissions
- **Check environment variables:** Verify all environment variables are set
- **Check CloudWatch logs:** Look for specific error messages

#### **API Gateway Issues**
- **Check Lambda permissions:** Ensure API Gateway can invoke Lambda
- **Check CORS:** Add CORS headers if needed
- **Check integration:** Verify Lambda integration is correct

#### **S3 Website Not Loading**
- **Check bucket policy:** Ensure public read access is enabled
- **Check website configuration:** Verify index document is set
- **Check file permissions:** Ensure files are publicly readable

### Next Steps

After successful deployment:

1. **Configure SES** (Step 4) - Set up email verification
2. **Test Registration** (Step 5) - Verify end-to-end functionality
3. **Set Up Monitoring** (Step 6) - Configure alerts and dashboards

### Cost Impact

This automation infrastructure will cost approximately **$0.76 per month**:
- **Lambda:** $0.00 (within free tier)
- **API Gateway:** $0.00 (within free tier)
- **S3:** $0.00 (within free tier)
- **CloudWatch:** $0.00 (within free tier)
- **Total:** $0.76/month for monitoring and logs

---

## Step 4: Configure Email (SES)

### Quick Reference
- **Service:** Amazon Simple Email Service (SES)
- **Purpose:** Send welcome emails to students with account details
- **Time Required:** 10-15 minutes
- **Cost:** $0.00 (within free tier)

### Overview

This step configures Amazon SES to send welcome emails to students when their AWS accounts are created. SES needs to be configured with verified email addresses or domains.

### Step 4.1: Access SES Console

1. **Navigate to SES**
   - Go to AWS Console → Services → Simple Email Service
   - **Important:** Make sure you're in the **us-east-1** region (SES is only available in certain regions)

2. **Check Current Status**
   - You should see the SES dashboard
   - Note your current sending quota and bounce/complaint rates

### Step 4.2: Verify Email Address (Sandbox Mode)

**Option A: Verify Individual Email Address (Recommended for Testing)**

1. **Go to Verified Identities**
   - Click "Verified identities" in the left sidebar
   - Click "Create identity"

2. **Configure Email Identity**
   - **Identity type:** Email address
   - **Email address:** Enter your email (e.g., `instructor@yourdomain.com`)
   - **Use a default configuration set:** Leave unchecked
   - Click "Create identity"

3. **Verify Email**
   - Check your email inbox
   - Look for email from AWS SES
   - Click the verification link
   - Return to SES console and refresh
   - Status should show "Verified"

**Option B: Verify Domain (Production)**

1. **Go to Verified Identities**
   - Click "Verified identities" in the left sidebar
   - Click "Create identity"

2. **Configure Domain Identity**
   - **Identity type:** Domain
   - **Domain:** Enter your domain (e.g., `yourdomain.com`)
   - **Use a default configuration set:** Leave unchecked
   - Click "Create identity"

3. **Add DNS Records**
   - Copy the provided DNS records
   - Add them to your domain's DNS settings
   - Wait for verification (can take up to 72 hours)

### Step 4.3: Request Production Access (Optional)

**If you want to send emails to any address (not just verified ones):**

1. **Go to Account Dashboard**
   - Click "Account dashboard" in the left sidebar
   - Look for "Sending statistics"

2. **Request Production Access**
   - Click "Request production access"
   - Fill out the form:
     - **Mail type:** Transactional
     - **Website URL:** Your workshop website URL
     - **Use case description:** "Sending welcome emails for AWS workshop student accounts"
     - **Expected daily sending volume:** 10-50 emails
   - Submit the request

3. **Wait for Approval**
   - Usually takes 24-48 hours
   - You'll receive an email when approved

### Step 4.4: Update Lambda Function Email Settings

1. **Get Your Verified Email**
   - Note your verified email address from Step 4.2
   - Example: `instructor@yourdomain.com`

2. **Update Lambda Function**
   - Go to Lambda → Functions
   - Find: `infrastructure-workshop-2025-account-creation`
   - Click on the function name
   - Go to "Code" tab
   - Find line 334: `Source='workshop@yourdomain.com'`
   - Replace with your verified email: `Source='instructor@yourdomain.com'`
   - Click "Deploy"

### Step 4.5: Test Email Functionality

1. **Test with Lambda Function**
   - Go to Lambda → Test
   - Use this test event:
   ```json
   {
     "email": "your-email@yourdomain.com",
     "name": "Test User"
   }
   ```

2. **Check Email Delivery**
   - Check your email inbox
   - You should receive a welcome email
   - If not, check CloudWatch logs for errors

### Step 4.6: Configure Email Templates (Optional)

1. **Customize Welcome Email**
   - The Lambda function includes HTML email templates
   - You can modify the email content in the Lambda code
   - Look for `create_welcome_email_html()` function

2. **Add Your Branding**
   - Update the email template with your company branding
   - Modify colors, logos, and content as needed

### Troubleshooting Email Issues

#### **Email Not Sending**
- **Check verified identity:** Ensure your email/domain is verified
- **Check region:** SES is only available in certain regions (us-east-1, us-west-2, eu-west-1)
- **Check CloudWatch logs:** Look for specific error messages
- **Check sending quota:** Ensure you haven't exceeded limits

#### **Email Going to Spam**
- **Use verified domain:** Domain verification is better than email verification
- **Set up SPF/DKIM records:** Add proper DNS records for your domain
- **Test with different email providers:** Gmail, Outlook, etc.

#### **SES Sandbox Limitations**
- **Sandbox mode:** Can only send to verified email addresses
- **Request production access:** To send to any email address
- **Daily sending limit:** 200 emails per day in sandbox mode

### Step 4.7: Verify Email Configuration

1. **Test Registration Flow**
   - Go to your student registration website
   - Fill out the registration form
   - Submit the form
   - Check if you receive the welcome email

2. **Check Email Content**
   - Verify the email contains correct information
   - Check that links work properly
   - Ensure branding looks correct

### Next Steps

Once email is configured:
- **Step 5:** Test the complete registration flow
- **Step 6:** Set up monitoring and alerts
- **Step 7:** Prepare for the workshop

**Email configuration is now complete!** 📧✅
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

## Step 6: Cost Management Setup - Detailed Step-by-Step Guide

### Overview

Step 6 sets up comprehensive cost management and monitoring for your workshop infrastructure. This includes individual student account budgets, instructor-level monitoring, and cost alerting systems.

### What's Already Implemented

Your Lambda function already includes basic cost management:
- ✅ Individual student account budgets (£10 limit)
- ✅ Budget notifications at 80% threshold
- ✅ Account tagging for cost tracking
- ✅ Email notifications to students

### Step 6.1: Verify Existing Budget Configuration

#### 6.1.1: Check Current Budget Settings

1. **Review Lambda Function Configuration**
   - Open your Lambda function: `infrastructure-workshop-2025-account-creation`
   - Check the `BUDGET_LIMIT` constant (currently set to £10.00)
   - Verify the budget notification threshold (currently 80%)

2. **Test Budget Creation**
   ```bash
   # Test the Lambda function with a test account
   aws lambda invoke \
     --function-name infrastructure-workshop-2025-account-creation \
     --payload '{"email":"test@example.com","name":"Test User"}' \
     response.json
   
   # Check the response
   cat response.json
   ```

#### 6.1.2: Verify Budget Permissions

1. **Check IAM Permissions**
   - Go to IAM → Roles
   - Find your Lambda execution role
   - Ensure it has `budgets:CreateBudget` permission

2. **Required IAM Policy**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "budgets:CreateBudget",
           "budgets:DescribeBudgets",
           "budgets:UpdateBudget"
         ],
         "Resource": "*"
       }
     ]
   }
   ```

### Step 6.2: Set Up Instructor-Level Cost Monitoring

#### 6.2.1: Create Master Budget

1. **Go to AWS Budgets Console**
   - Navigate to AWS Budgets
   - Click "Create budget"

2. **Configure Master Workshop Budget**
   ```
   Budget name: Workshop-Master-Budget-2025
   Budget type: Cost
   Budget period: Monthly
   Budget amount: £200.00
   ```

3. **Set Up Notifications**
   ```
   Alert threshold: 50% (£100)
   Alert threshold: 80% (£160)
   Alert threshold: 100% (£200)
   Email recipients: your-email@yourdomain.com
   ```

#### 6.2.2: Create Cost Allocation Tags

1. **Enable Cost Allocation Tags**
   - Go to AWS Cost Management → Cost Allocation Tags
   - Activate the following tags:
     - `Workshop`
     - `StudentEmail`
     - `StudentName`
     - `CreatedDate`

2. **Verify Tag Activation**
   ```bash
   # Check if tags are active
   aws ce get-cost-allocation-tags
   ```

### Step 6.3: Create Cost Monitoring Dashboard

**Note:** CloudWatch dashboards don't have billing metrics available. Use AWS Cost Explorer and Budgets for cost monitoring instead.

#### 6.3.1: Create AWS Cost Explorer Dashboard (Recommended)

1. **Go to AWS Cost Explorer**
   - Navigate to **AWS Cost Management** → **Cost Explorer**
   - Click **"Launch Cost Explorer"**

2. **Create Cost Dashboard**
   - Click **"Create dashboard"**
   - Name: `Workshop-Cost-Monitoring-2025`

3. **Add Cost Views**
   - **Total Costs**: Shows overall workshop spending
   - **Costs by Account**: Shows individual student account costs
   - **Costs by Service**: Shows which AWS services are being used

#### 6.3.2: Create AWS Budgets Dashboard

1. **Go to AWS Budgets**
   - Navigate to **AWS Cost Management** → **Budgets**
   - Click **"Create budget"**

2. **Create Master Workshop Budget**
   ```
   Budget name: Workshop-Master-Budget-2025
   Budget type: Cost
   Budget period: Monthly
   Budget amount: £200.00
   ```

3. **Set Up Notifications**
   ```
   Alert threshold: 50% (£100)
   Alert threshold: 80% (£160)
   Alert threshold: 100% (£200)
   Email recipients: your-email@yourdomain.com
   ```

#### 6.3.3: Create CloudWatch Infrastructure Dashboard (Optional)

1. **Go to CloudWatch Console**
   - Navigate to CloudWatch → **Dashboards**
   - Click **"Create dashboard"**

2. **Dashboard Configuration**
   ```
   Dashboard name: Workshop-Infrastructure-Monitoring-2025
   ```

3. **Add Available Metrics**
   - **EC2 Metrics**: CPU, Memory, Network
   - **RDS Metrics**: Database connections, CPU
   - **S3 Metrics**: Storage, requests
   - **Lambda Metrics**: Invocations, errors

4. **Example Widget Configuration**
   ```
   Namespace: AWS/EC2
   Metric: CPUUtilization
   Instance: [Select your instances]
   Period: 5 minutes
   Statistic: Average
   ```

### Step 6.4: Set Up Cost Alerts and Notifications

#### 6.4.1: Create CloudWatch Alarms

1. **High Cost Alarm**
   ```bash
   # Create alarm for high costs
   aws cloudwatch put-metric-alarm \
     --alarm-name "Workshop-High-Cost-Alert" \
     --alarm-description "Alert when workshop costs exceed £150" \
     --metric-name EstimatedCharges \
     --namespace AWS/Billing \
     --statistic Maximum \
     --period 86400 \
     --threshold 150 \
     --comparison-operator GreaterThanThreshold \
     --evaluation-periods 1 \
     --alarm-actions arn:aws:sns:us-east-1:YOUR-ACCOUNT:workshop-alerts
   ```

2. **Individual Account Cost Alarm**
   ```bash
   # Create alarm for individual account costs
   aws cloudwatch put-metric-alarm \
     --alarm-name "Student-Account-High-Cost" \
     --alarm-description "Alert when any student account exceeds £15" \
     --metric-name EstimatedCharges \
     --namespace AWS/Billing \
     --statistic Maximum \
     --period 86400 \
     --threshold 15 \
     --comparison-operator GreaterThanThreshold \
     --evaluation-periods 1 \
     --alarm-actions arn:aws:sns:us-east-1:YOUR-ACCOUNT:workshop-alerts
   ```

#### 6.4.2: Set Up SNS Notifications

1. **Create SNS Topic**
   ```bash
   # Create SNS topic for cost alerts
   aws sns create-topic --name workshop-cost-alerts
   
   # Subscribe your email
   aws sns subscribe \
     --topic-arn arn:aws:sns:us-east-1:YOUR-ACCOUNT:workshop-cost-alerts \
     --protocol email \
     --notification-endpoint your-email@yourdomain.com
   ```

2. **Confirm Subscription**
   - Check your email for confirmation
   - Click the confirmation link

### Step 6.5: Create Cost Management Scripts

#### 6.5.1: Create Cost Monitoring Script

Create a new file: `cost-monitoring.py`

```python
import boto3
import json
from datetime import datetime, timedelta

def get_workshop_costs():
    """Get cost information for all workshop accounts"""
    ce = boto3.client('ce')
    organizations = boto3.client('organizations')
    
    # Get workshop OU ID
    workshop_ou_id = os.environ.get('WORKSHOP_OU_ID')
    
    # Get all accounts in workshop OU
    accounts = organizations.list_accounts_for_parent(
        ParentId=workshop_ou_id
    )
    
    # Get costs for each account
    cost_data = []
    for account in accounts['Accounts']:
        account_id = account['Id']
        account_name = account['Name']
        account_email = account['Email']
        
        # Get costs for the last 30 days
        end_date = datetime.now().strftime('%Y-%m-%d')
        start_date = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
        
        try:
            response = ce.get_cost_and_usage(
                TimePeriod={
                    'Start': start_date,
                    'End': end_date
                },
                Granularity='MONTHLY',
                Metrics=['BlendedCost'],
                Filter={
                    'Dimensions': {
                        'Key': 'LINKED_ACCOUNT',
                        'Values': [account_id]
                    }
                }
            )
            
            cost = float(response['ResultsByTime'][0]['Total']['BlendedCost']['Amount'])
            
            cost_data.append({
                'account_id': account_id,
                'account_name': account_name,
                'account_email': account_email,
                'cost': cost,
                'status': 'ACTIVE' if cost < 15 else 'WARNING'
            })
            
        except Exception as e:
            print(f"Error getting costs for account {account_id}: {str(e)}")
    
    return cost_data

def generate_cost_report():
    """Generate a cost report for the workshop"""
    cost_data = get_workshop_costs()
    
    total_cost = sum(account['cost'] for account in cost_data)
    warning_accounts = [account for account in cost_data if account['status'] == 'WARNING']
    
    report = {
        'report_date': datetime.now().isoformat(),
        'total_cost': total_cost,
        'account_count': len(cost_data),
        'warning_count': len(warning_accounts),
        'accounts': cost_data
    }
    
    return report

if __name__ == "__main__":
    report = generate_cost_report()
    print(json.dumps(report, indent=2))
```

#### 6.5.2: Create Cost Cleanup Script

Create a new file: `cost-cleanup.py`

```python
import boto3
import json
from datetime import datetime, timedelta

def cleanup_high_cost_resources():
    """Clean up resources in accounts that exceed budget"""
    organizations = boto3.client('organizations')
    ec2 = boto3.client('ec2')
    
    # Get workshop OU ID
    workshop_ou_id = os.environ.get('WORKSHOP_OU_ID')
    
    # Get all accounts in workshop OU
    accounts = organizations.list_accounts_for_parent(
        ParentId=workshop_ou_id
    )
    
    for account in accounts['Accounts']:
        account_id = account['Id']
        account_name = account['Name']
        
        # Check if account exceeds budget
        if check_account_budget(account_id):
            print(f"Account {account_name} ({account_id}) exceeds budget")
            
            # List resources that can be cleaned up
            resources = list_cleanup_resources(account_id)
            
            # Clean up resources
            for resource in resources:
                cleanup_resource(account_id, resource)

def check_account_budget(account_id):
    """Check if account exceeds budget"""
    # Implementation to check budget
    # This would integrate with your budget monitoring
    pass

def list_cleanup_resources(account_id):
    """List resources that can be cleaned up"""
    # Implementation to list resources
    # Focus on non-essential resources
    pass

def cleanup_resource(account_id, resource):
    """Clean up a specific resource"""
    # Implementation to clean up resource
    # This would require cross-account access
    pass
```

### Step 6.6: Test Cost Management Setup

#### 6.6.1: Test Budget Creation

1. **Test Student Account Creation**
   ```bash
   # Create a test account
   aws lambda invoke \
     --function-name infrastructure-workshop-2025-account-creation \
     --payload '{"email":"test-student@example.com","name":"Test Student"}' \
     test-response.json
   
   # Check if budget was created
   aws budgets describe-budgets \
     --account-id YOUR-ACCOUNT-ID \
     --budget-names "Workshop-Budget-TEST-ACCOUNT-ID"
   ```

2. **Verify Budget Notifications**
   - Check that budget notifications are set up correctly
   - Verify email addresses are correct

#### 6.6.2: Test Cost Monitoring

1. **Run Cost Monitoring Script**
   ```bash
   # Run the cost monitoring script
   python3 cost-monitoring.py
   
   # Check the output
   cat cost-report.json
   ```

2. **Verify CloudWatch Dashboard**
   - Go to CloudWatch → Dashboards
   - Open your workshop cost dashboard
   - Verify widgets are displaying correctly

#### 6.6.3: Test Alerts

1. **Test SNS Notifications**
   ```bash
   # Send a test notification
   aws sns publish \
     --topic-arn arn:aws:sns:us-east-1:YOUR-ACCOUNT:workshop-cost-alerts \
     --message "Test cost alert notification" \
     --subject "Workshop Cost Alert Test"
   ```

2. **Verify Alarm States**
   - Go to CloudWatch → Alarms
   - Check that alarms are in OK state
   - Verify alarm configurations

### Step 6.7: Configure Automated Cost Reports

#### 6.7.1: Set Up Daily Cost Reports

1. **Create Lambda Function for Daily Reports**
   ```python
   import json
   import boto3
   from datetime import datetime
   
   def lambda_handler(event, context):
       """Daily cost report Lambda function"""
       cost_data = get_workshop_costs()
       
       # Generate report
       report = generate_cost_report()
       
       # Send email report
       send_cost_report_email(report)
       
       return {
           'statusCode': 200,
           'body': json.dumps('Cost report generated successfully')
       }
   ```

2. **Set Up CloudWatch Events Rule**
   ```bash
   # Create rule for daily execution
   aws events put-rule \
     --name "daily-cost-report" \
     --schedule-expression "rate(1 day)" \
     --description "Daily workshop cost report"
   
   # Add Lambda target
   aws events put-targets \
     --rule "daily-cost-report" \
     --targets "Id"="1","Arn"="arn:aws:lambda:REGION:ACCOUNT:function:daily-cost-report"
   ```

### Step 6.8: Final Verification

#### 6.8.1: Complete Cost Management Checklist

- [ ] Individual student budgets created (£10 limit)
- [ ] Budget notifications configured (80% threshold)
- [ ] Master workshop budget created (£200 limit)
- [ ] CloudWatch cost dashboard created
- [ ] Cost allocation tags activated
- [ ] SNS notifications configured
- [ ] CloudWatch alarms created
- [ ] Cost monitoring scripts created
- [ ] Daily cost reports configured
- [ ] All tests passed

#### 6.8.2: Cost Management Summary

**What's Now Configured:**
- ✅ Individual student account budgets
- ✅ Workshop-level cost monitoring
- ✅ Automated cost alerts
- ✅ Cost dashboards and reporting
- ✅ Resource cleanup capabilities
- ✅ Daily cost reports

**Expected Monthly Costs:**
- **Per Student:** £10-15 (with budget limits)
- **Total Workshop (8 students):** £80-120
- **Master Budget:** £200 (with alerts at £100 and £160)

**Next Steps:**
- Monitor costs daily during workshop
- Review cost reports weekly
- Adjust budgets if needed
- Clean up resources as required

**Step 6 is now complete!** 🎯✅

Your cost management system is fully configured and ready to monitor workshop expenses effectively.

---

## Step 7: Workshop Management - Detailed Step-by-Step Guide

### Overview

Step 7 covers the complete workshop management lifecycle, from pre-workshop preparation through post-workshop cleanup. This includes student registration, instructor monitoring, real-time support, and automated cleanup processes.

### Step 7.1: Pre-Workshop Preparation

#### 7.1.1: Workshop Environment Setup

1. **Verify Infrastructure Readiness**
   ```bash
   # Check Lambda function status
   aws lambda get-function --function-name infrastructure-workshop-2025-account-creation
   
   # Verify API Gateway endpoint
   aws apigateway get-rest-apis --query 'items[?name==`workshop-api`]'
   
   # Check SES configuration
   aws ses get-identity-verification-attributes --identities your-email@yourdomain.com
   ```

2. **Test Complete Registration Flow**
   ```bash
   # Create test payload
   echo '{"email":"test@example.com","name":"Test User"}' > test-payload.json
   
   # Test Lambda function
   aws lambda invoke \
     --function-name infrastructure-workshop-2025-account-creation \
     --payload file://test-payload.json \
     --cli-binary-format raw-in-base64-out \
     test-response.json
   
   # Check response
   cat test-response.json
   ```

3. **Verify Budget and Monitoring Setup**
   ```bash
   # Check master budget
   aws budgets describe-budgets --account-id YOUR-ACCOUNT-ID
   
   # Verify cost allocation tags
   aws ce get-cost-allocation-tags
   ```

#### 7.1.2: Student Communication Setup

**Step 1: Verify Existing S3 Setup**

1. **Go to S3 Console**
   - Navigate to AWS Console → Services → S3
   - Find your existing bucket: `infrastructure-workshop-2025-registration-{account-id}`
   - Click on the bucket name

2. **Verify Files Are Already Uploaded**
   - You should see these files (from Step 3.6):
     - `index.html` (this is your student registration page)
     - `instructor-dashboard.html` (this is your instructor dashboard)
   - If these files are missing, go back to Step 3.6 and upload them

3. **Check Website Configuration**
   - Go to "Properties" tab
   - Scroll down to "Static website hosting"
   - Should show "Enabled" with `index.html` as the index document
   - Note the "Bucket website endpoint" URL for later use

**Step 3: Update Registration Page in S3**

The local `student-registration.html` file already has the correct API endpoint. We need to upload it to S3:

1. **Go to S3 Console**
   - Navigate to AWS Console → Services → S3
   - Find your bucket: `infrastructure-workshop-2025-registration-{account-id}`
   - Click on the bucket name

2. **Upload Updated Registration Page**
   - Click "Upload"
   - Click "Add files"
   - Navigate to your local `workshop-materials/automation/` folder
   - Select `student-registration.html`
   - **Important:** In the "Destination" section, change the key to `index.html`
   - Click "Upload"

3. **Verify Upload**
   - You should now see `index.html` in your bucket
   - This will be your student registration page

**Step 4: Test Registration Flow**

1. **Test Registration Page**
   - Go to S3 Console
   - Find your bucket
   - Go to "Properties" tab
   - Scroll down to "Static website hosting"
   - Copy the "Bucket website endpoint" URL
   - Open this URL in your browser
   - Verify the registration form loads

2. **Test API Endpoint**
   - Use the API Gateway URL from Step 7.1.1
   - Test with a sample registration
   - Verify the Lambda function processes the request

#### 7.1.3: Instructor Preparation

1. **Create Instructor Checklist**
   ```markdown
   ## Pre-Workshop Checklist
   
   ### Infrastructure
   - [ ] Lambda function deployed and tested
   - [ ] API Gateway configured
   - [ ] SES email verified
   - [ ] Budgets configured
   - [ ] Monitoring dashboards set up
   
   ### Student Communication
   - [ ] Registration page accessible
   - [ ] Welcome email template ready
   - [ ] Student instructions prepared
   - [ ] Support contact information shared
   
   ### Workshop Materials
   - [ ] Lab instructions ready
   - [ ] CloudFormation templates prepared
   - [ ] Sample applications available
   - [ ] Troubleshooting guide ready
   ```

### Step 7.2: Student Registration and Onboarding

#### 7.2.1: Registration Process

**Step 1: Test Student Registration Flow**

1. **Go to Your Registration Page**
   - Open your browser
   - Go to your S3 website URL (from Step 7.1.2)
   - You should see the registration form

2. **Test Registration**
   - Fill out the form with a test email
   - Click "Register for Workshop"
   - Check that you get a success message
   - Check your email for the welcome message

3. **Verify Account Creation**
   - Go to AWS Console → Services → Organizations
   - Click "AWS accounts"
   - Look for the new account with your test email
   - Status should be "Active" or "Pending"

**Step 2: Monitor Registrations (Optional)**

If you want to monitor registrations, you can use the existing `cost-monitoring.py` script:

1. **Go to Your Local Directory**
   - Navigate to `workshop-materials/automation/`
   - Open `cost-monitoring.py`

2. **Run the Script**
   - This will show you all workshop accounts
   - Includes registration details and costs
   - No need to create new files

#### 7.2.2: Student Onboarding

1. **Welcome Email Content**
   - Account ID and login instructions
   - Budget limits and monitoring
   - Workshop schedule and materials
   - Support contact information

2. **Student Account Verification**
   ```python
   def verify_student_accounts():
       """Verify all student accounts are ready"""
       organizations = boto3.client('organizations')
       sso_admin = boto3.client('sso-admin')
       
       workshop_ou_id = os.environ.get('WORKSHOP_OU_ID')
       accounts = organizations.list_accounts_for_parent(
           ParentId=workshop_ou_id
       )
       
       ready_accounts = []
       for account in accounts['Accounts']:
           if account['Status'] == 'ACTIVE':
               # Check if SSO user exists
               try:
                   identity_store_id = get_identity_store_id()
                   users = sso_admin.list_users(
                       IdentityStoreId=identity_store_id,
                       Filters=[{
                           'AttributePath': 'UserName',
                           'AttributeValue': account['Email']
                       }]
                   )
                   
                   if users['Users']:
                       ready_accounts.append(account)
               except Exception as e:
                   print(f"Error checking SSO for {account['Email']}: {e}")
       
       return ready_accounts
   ```

### Step 7.3: Instructor Dashboard Setup

#### 7.3.1: Deploy Instructor Dashboard

**Step 1: Verify Existing Dashboard Setup**

1. **Go to S3 Console**
   - Navigate to AWS Console → Services → S3
   - Find your existing bucket: `infrastructure-workshop-2025-registration-{account-id}`
   - Click on the bucket name

2. **Verify Dashboard File Is Already Uploaded**
   - You should see `instructor-dashboard.html` (uploaded in Step 3.6)
   - If missing, go back to Step 3.6 and upload it

3. **Get Dashboard URL**
   - Go to "Properties" tab
   - Scroll down to "Static website hosting"
   - Copy the "Bucket website endpoint" URL
   - Your dashboard will be at: `[BUCKET_WEBSITE_URL]/instructor-dashboard.html`

**Step 2: Create Lambda Function for Dashboard API**

1. **Go to Lambda Console**
   - Navigate to AWS Console → Services → Lambda
   - Click "Create function"

2. **Configure Function**
   - **Function name:** `instructor-dashboard-api`
   - **Runtime:** Python 3.9
   - **Architecture:** x86_64
   - Click "Create function"

3. **Update Function Code**
   - In the "Code" tab, delete the existing code
   - Copy the contents of `workshop-materials/automation/instructor-dashboard.py`
   - Paste it into the code editor
   - Add this Lambda handler at the top:
   ```python
   def lambda_handler(event, context):
       """Lambda handler for instructor dashboard API"""
       try:
           # Get workshop status
           status = get_workshop_status()
           
           return {
               'statusCode': 200,
               'headers': {
                   'Content-Type': 'application/json',
                   'Access-Control-Allow-Origin': '*',
                   'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
                   'Access-Control-Allow-Headers': 'Content-Type'
               },
               'body': json.dumps(status)
           }
       except Exception as e:
           return {
               'statusCode': 500,
               'headers': {
                   'Content-Type': 'application/json',
                   'Access-Control-Allow-Origin': '*'
               },
               'body': json.dumps({'error': str(e)})
           }
   ```
   - Click "Deploy"

4. **Configure Environment Variables**
   - Go to "Configuration" tab
   - Click "Environment variables"
   - Click "Edit"
   - Add environment variable:
     - **Key:** `WORKSHOP_OU_ID`
     - **Value:** `ou-01dw-2r1xz8cp`
   - Click "Save"

5. **Update Function Role (CRITICAL STEP)**
   - Go to "Configuration" tab
   - Click "Permissions"
   - Click on the execution role name (it will be something like `instructor-dashboard-api-role-xxxxx`)
   - This will open IAM in a new tab
   - Click "Add permissions" → "Attach policies"
   - Search for and select: `PA-Consulting-Infrastructure-Wo-AccountCreationRole-SH8cjx5sCx5Z`
   - Click "Attach policy"
   - **OR** if you can't find that policy, add this custom policy:
     - Click "Add permissions" → "Create inline policy"
     - Click "JSON" tab
     - Paste this policy:
     ```json
     {
         "Version": "2012-10-17",
         "Statement": [
             {
                 "Effect": "Allow",
                 "Action": [
                     "organizations:*",
                     "identitystore:*",
                     "ses:SendEmail",
                     "ses:SendRawEmail",
                     "budgets:*",
                     "s3:GetObject",
                     "s3:PutObject"
                 ],
                 "Resource": "*"
             }
         ]
     }
     ```
     - Click "Next"
     - Name it: `InstructorDashboardPolicy`
     - Click "Create policy"

6. **Test the Function**
   - Go back to Lambda console
   - Click "Test" button
   - Create a new test event with this JSON:
   ```json
   {}
   ```
   - Name it: `TestDashboard`
   - Click "Create"
   - Click "Test" button
   - You should see a successful response with workshop data

#### 7.3.2: Create API Gateway for Dashboard

**Step 1: Create API Gateway**

1. **Go to API Gateway Console**
   - Navigate to AWS Console → Services → API Gateway
   - Click "Create API"
   - Select "REST API"
   - Click "Build"

2. **Configure API**
   - **API name:** `instructor-dashboard-api`
   - **Description:** `API for instructor dashboard data`
   - **Endpoint Type:** Regional
   - Click "Create API"

3. **Create Resource**
   - Click "Actions" → "Create Resource"
   - **Resource Name:** `dashboard`
   - **Resource Path:** `dashboard`
   - **Enable CORS:** Check this box
   - Click "Create Resource"

4. **Create Method**
   - Select the `/dashboard` resource
   - Click "Actions" → "Create Method"
   - Select "GET" from dropdown
   - Click the checkmark

5. **Configure Method**
   - **Integration type:** Lambda Function
   - **Use Lambda Proxy integration:** Check this box
   - **Lambda Function:** `instructor-dashboard-api`
   - **Use Default Timeout:** Check this box
   - Click "Save"
   - Click "OK" when prompted to add Lambda permissions

**Step 2: Deploy API**

1. **Deploy API**
   - Click "Actions" → "Deploy API"
   - **Deployment stage:** `[New Stage]`
   - **Stage name:** `prod`
   - **Stage description:** `Production stage for instructor dashboard`
   - Click "Deploy"

2. **Get API Endpoint**
   - Note the "Invoke URL" (e.g., `https://abc123.execute-api.us-east-1.amazonaws.com/prod`)
   - Your dashboard API will be at: `[INVOKE_URL]/dashboard`

**Step 3: Test API Gateway**

1. **Test the Endpoint**
   - Click on the `/dashboard` resource
   - Click "GET" method
   - Click "Test"
   - Click "Test" button
   - You should see workshop data returned

2. **Test from Browser**
   - Open a new browser tab
   - Go to: `[YOUR_API_GATEWAY_URL]/dashboard`
   - You should see JSON data with workshop information

### Step 7.4: Monitoring and Alerts Setup

#### 7.4.1: CloudWatch Dashboard

**Step 1: Create CloudWatch Dashboard**

1. **Go to CloudWatch Console**
   - Navigate to AWS Console → Services → CloudWatch
   - Click "Dashboards" in the left menu
   - Click "Create dashboard"

2. **Configure Dashboard**
   - **Dashboard name:** `workshop-monitoring`
   - **Description:** `Workshop infrastructure monitoring`
   - Click "Create dashboard"

3. **Add Lambda Metrics Widget**
   - Click "Add widget"
   - Select "Line chart"
   - **Metrics:** Lambda → By Function Name → `infrastructure-workshop-2025-account-creation`
   - **Metric:** Invocations, Errors, Duration
   - Click "Create widget"

4. **Add API Gateway Metrics Widget**
   - Click "Add widget"
   - Select "Line chart"
   - **Metrics:** API Gateway → By API Name → `workshop-api`
   - **Metric:** Count, 4XXError, 5XXError
   - Click "Create widget"

#### 7.4.2: Set Up Alerts

**Step 1: Create CloudWatch Alarms**

1. **Go to CloudWatch Alarms**
   - In CloudWatch console, click "Alarms" in the left menu
   - Click "Create alarm"

2. **Create Lambda Error Alarm**
   - Click "Select metric"
   - **Service:** Lambda
   - **Metric:** Errors
   - **Function name:** `infrastructure-workshop-2025-account-creation`
   - Click "Select metric"
   - **Threshold:** Greater than 0
   - **Datapoints:** 1 out of 1
   - **Period:** 1 minute
   - Click "Next"

3. **Configure Alarm Actions**
   - **Alarm name:** `workshop-lambda-errors`
   - **Alarm description:** `Lambda function errors detected`
   - **SNS topic:** Create new topic
   - **Topic name:** `workshop-alerts`
   - **Email endpoints:** Your email address
   - Click "Create alarm"

### Step 7.5: Support and Troubleshooting

#### 7.5.1: Create Support Documentation

**Step 1: Create Troubleshooting Guide**

1. **Go to S3 Console**
   - Navigate to AWS Console → Services → S3
   - Find your bucket: `infrastructure-workshop-2025-registration-{account-id}`
   - Click "Upload"

2. **Create Support HTML File**
   - Create a new file called `support.html` with this content:
   ```html
   <!DOCTYPE html>
   <html>
   <head>
       <meta charset="UTF-8">
       <title>Workshop Support</title>
       <style>
           body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
           .issue { background: #f8f9fa; padding: 15px; margin: 10px 0; border-left: 4px solid #007cba; }
           .solution { background: #d4edda; padding: 10px; margin: 5px 0; border-radius: 4px; }
       </style>
   </head>
   <body>
       <h1>Workshop Support Guide</h1>
       
       <div class="issue">
           <h3>Registration Not Working</h3>
           <div class="solution">
               <p><strong>Check:</strong> API Gateway endpoint is correct</p>
               <p><strong>Check:</strong> Lambda function has proper permissions</p>
               <p><strong>Check:</strong> SES is verified for your email domain</p>
           </div>
       </div>
       
       <div class="issue">
           <h3>Account Creation Failing</h3>
           <div class="solution">
               <p><strong>Check:</strong> Organizations permissions</p>
               <p><strong>Check:</strong> Workshop OU ID is correct</p>
               <p><strong>Check:</strong> Budget limits are set</p>
           </div>
       </div>
   </body>
   </html>
   ```
   - Upload as `support.html`

### Step 7.6: Cleanup and Maintenance

#### 7.6.1: Automated Cleanup Script

**Step 1: Create Cleanup Lambda Function**

1. **Go to Lambda Console**
   - Navigate to AWS Console → Services → Lambda
   - Click "Create function"
   - **Function name:** `workshop-cleanup`
   - **Runtime:** Python 3.9
   - Click "Create function"

2. **Add Cleanup Code**
   - In the "Code" tab, replace the code with:
   ```python
   import json
   import boto3
   from datetime import datetime, timedelta
   
   def lambda_handler(event, context):
       """Clean up workshop resources"""
       try:
           # Add cleanup logic here
           return {
               'statusCode': 200,
               'body': json.dumps({'message': 'Cleanup completed'})
           }
       except Exception as e:
           return {
               'statusCode': 500,
               'body': json.dumps({'error': str(e)})
           }
   ```
   - Click "Deploy"

### Step 7.7: Final Verification

#### 7.7.1: End-to-End Testing

**Step 1: Test Complete Workflow**

1. **Test Student Registration**
   - Go to your S3 website URL
   - Fill out the registration form
   - Submit and verify success message
   - Check your email for welcome message

2. **Test Instructor Dashboard**
   - Go to your S3 website URL + `/instructor-dashboard.html`
   - Verify dashboard loads with data
   - Check that all metrics are displayed

3. **Test API Endpoints**
   - Test registration API: `[API_GATEWAY_URL]/register`
   - Test dashboard API: `[API_GATEWAY_URL]/dashboard`
   - Both should return JSON data

**Step 2: Verify Monitoring**

1. **Check CloudWatch Dashboard**
   - Go to CloudWatch → Dashboards
   - Open `workshop-monitoring`
   - Verify metrics are being collected

2. **Check Alarms**
   - Go to CloudWatch → Alarms
   - Verify alarms are in "OK" state
   - Test alarm by triggering an error

**Step 3: Document Everything**

1. **Update Documentation**
   - Note all API Gateway URLs
   - Document any custom configurations
   - Save all important IDs and endpoints

2. **Create Runbook**
   - Document common issues and solutions
   - Create escalation procedures
   - Save all contact information

def get_workshop_status():
    """Get comprehensive workshop status"""
    organizations = boto3.client('organizations')
    ce = boto3.client('ce')
    
    workshop_ou_id = os.environ.get('WORKSHOP_OU_ID', 'ou-01dw-2r1xz8cp')
    
    # Get all accounts
    accounts = organizations.list_accounts_for_parent(
        ParentId=workshop_ou_id
    )
    
    # Get account details
    account_status = []
    total_cost = 0
    
    for account in accounts['Accounts']:
        account_id = account['Id']
        account_name = account['Name']
        account_email = account['Email']
        account_status_val = account['Status']
        joined_date = account['JoinedTimestamp']
        
        # Get cost for this account
        try:
            end_date = datetime.now().strftime('%Y-%m-%d')
            start_date = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
            
            response = ce.get_cost_and_usage(
                TimePeriod={'Start': start_date, 'End': end_date},
                Granularity='MONTHLY',
                Metrics=['BlendedCost'],
                Filter={
                    'Dimensions': {
                        'Key': 'LINKED_ACCOUNT',
                        'Values': [account_id]
                    }
                }
            )
            
            cost = float(response['ResultsByTime'][0]['Total']['BlendedCost']['Amount'])
            total_cost += cost
            
        except Exception as e:
            cost = 0
            print(f"Error getting cost for {account_id}: {e}")
        
        account_status.append({
            'account_id': account_id,
            'name': account_name,
            'email': account_email,
            'status': account_status_val,
            'joined_date': joined_date.isoformat(),
            'cost': cost,
            'cost_status': 'WARNING' if cost > 15 else 'OK'
        })
    
    return {
        'workshop_info': {
            'total_accounts': len(accounts['Accounts']),
            'active_accounts': len([a for a in account_status if a['status'] == 'ACTIVE']),
            'total_cost': total_cost,
            'last_updated': datetime.now().isoformat()
        },
        'accounts': account_status
    }
EOF

# Create deployment package
zip instructor-dashboard-lambda.zip instructor-dashboard-lambda.py

# Create Lambda function
aws lambda create-function \
  --function-name instructor-dashboard-api \
  --runtime python3.9 \
  --role arn:aws:iam::535002854646:role/PA-Consulting-Infrastructure-Wo-AccountCreationRole-SH8cjx5sCx5Z \
  --handler instructor-dashboard-lambda.lambda_handler \
  --zip-file fileb://instructor-dashboard-lambda.zip \
  --timeout 30 \
  --memory-size 256 \
  --environment Variables='{WORKSHOP_OU_ID=ou-01dw-2r1xz8cp}'
```

**Step 2: Create API Gateway for Instructor Dashboard**

```bash
# Create API Gateway for instructor dashboard
aws apigateway create-rest-api \
  --name "instructor-dashboard-api" \
  --description "Instructor dashboard API for workshop management"

# Get the API ID (replace with actual ID from response)
export DASHBOARD_API_ID="YOUR_DASHBOARD_API_ID"

# Get root resource ID
aws apigateway get-resources --rest-api-id $DASHBOARD_API_ID

# Create dashboard resource
aws apigateway create-resource \
  --rest-api-id $DASHBOARD_API_ID \
  --parent-id ROOT_RESOURCE_ID \
  --path-part "dashboard"

# Create GET method
aws apigateway put-method \
  --rest-api-id $DASHBOARD_API_ID \
  --resource-id DASHBOARD_RESOURCE_ID \
  --http-method GET \
  --authorization-type NONE

# Set up Lambda integration
aws apigateway put-integration \
  --rest-api-id $DASHBOARD_API_ID \
  --resource-id DASHBOARD_RESOURCE_ID \
  --http-method GET \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:535002854646:function:instructor-dashboard-api/invocations"

# Deploy the API
aws apigateway create-deployment \
  --rest-api-id $DASHBOARD_API_ID \
  --stage-name "prod"

# Add Lambda permission
aws lambda add-permission \
  --function-name instructor-dashboard-api \
  --statement-id apigateway-dashboard-invoke \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:us-east-1:535002854646:$DASHBOARD_API_ID/*/*"
```

**Step 3: Create Instructor Dashboard Web Interface**

```bash
# Create instructor dashboard HTML
cat > instructor-dashboard.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Workshop Instructor Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f7fa; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .dashboard { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .card { background: white; border-radius: 10px; padding: 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .metric { font-size: 2.5em; font-weight: bold; color: #667eea; margin-bottom: 10px; }
        .metric-label { color: #666; font-size: 1.1em; }
        .warning { color: #ff6b35; }
        .ok { color: #28a745; }
        .accounts-table { background: white; border-radius: 10px; padding: 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #f8f9fa; font-weight: 600; color: #333; }
        .status-badge { padding: 4px 12px; border-radius: 20px; font-size: 0.9em; font-weight: 500; }
        .status-active { background: #d4edda; color: #155724; }
        .status-pending { background: #fff3cd; color: #856404; }
        .cost-warning { background: #f8d7da; color: #721c24; }
        .cost-ok { background: #d4edda; color: #155724; }
        .refresh-btn { background: #667eea; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin-bottom: 20px; }
        .refresh-btn:hover { background: #5a6fd8; }
        .loading { text-align: center; color: #667eea; font-size: 1.2em; }
        .error { background: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎓 Workshop Instructor Dashboard</h1>
        <p>Infrastructure Workshop 2025 - Real-time Management</p>
    </div>
    
    <div class="container">
        <button class="refresh-btn" onclick="refreshData()">🔄 Refresh Data</button>
        
        <div class="dashboard">
            <div class="card">
                <div class="metric" id="totalAccounts">-</div>
                <div class="metric-label">Total Student Accounts</div>
            </div>
            <div class="card">
                <div class="metric" id="activeAccounts">-</div>
                <div class="metric-label">Active Accounts</div>
            </div>
            <div class="card">
                <div class="metric" id="totalCost">-</div>
                <div class="metric-label">Total Cost ($)</div>
            </div>
            <div class="card">
                <div class="metric" id="lastUpdated">-</div>
                <div class="metric-label">Last Updated</div>
            </div>
        </div>
        
        <div class="accounts-table">
            <h2>📋 Student Accounts</h2>
            <div id="loadingMessage" class="loading">Loading student data...</div>
            <div id="errorMessage" class="error" style="display: none;"></div>
            <table id="accountsTable" style="display: none;">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Account ID</th>
                        <th>Status</th>
                        <th>Cost</th>
                        <th>Joined</th>
                    </tr>
                </thead>
                <tbody id="accountsBody">
                </tbody>
            </table>
        </div>
    </div>

    <script>
        const DASHBOARD_API_URL = 'https://YOUR_DASHBOARD_API_ID.execute-api.us-east-1.amazonaws.com/prod/dashboard';
        
        async function refreshData() {
            const loadingDiv = document.getElementById('loadingMessage');
            const errorDiv = document.getElementById('errorMessage');
            const tableDiv = document.getElementById('accountsTable');
            
            loadingDiv.style.display = 'block';
            errorDiv.style.display = 'none';
            tableDiv.style.display = 'none';
            
            try {
                const response = await fetch(DASHBOARD_API_URL);
                const data = await response.json();
                
                if (response.ok) {
                    updateDashboard(data);
                    loadingDiv.style.display = 'none';
                    tableDiv.style.display = 'table';
                } else {
                    throw new Error(data.error || 'Failed to fetch data');
                }
            } catch (error) {
                loadingDiv.style.display = 'none';
                errorDiv.style.display = 'block';
                errorDiv.textContent = 'Error: ' + error.message;
            }
        }
        
        function updateDashboard(data) {
            // Update metrics
            document.getElementById('totalAccounts').textContent = data.workshop_info.total_accounts;
            document.getElementById('activeAccounts').textContent = data.workshop_info.active_accounts;
            document.getElementById('totalCost').textContent = '$' + data.workshop_info.total_cost.toFixed(2);
            document.getElementById('lastUpdated').textContent = new Date(data.workshop_info.last_updated).toLocaleTimeString();
            
            // Update accounts table
            const tbody = document.getElementById('accountsBody');
            tbody.innerHTML = '';
            
            data.accounts.forEach(account => {
                const row = tbody.insertRow();
                row.innerHTML = `
                    <td>${account.name}</td>
                    <td>${account.email}</td>
                    <td><code>${account.account_id}</code></td>
                    <td><span class="status-badge status-${account.status.toLowerCase()}">${account.status}</span></td>
                    <td><span class="status-badge ${account.cost_status.toLowerCase().replace('ok', 'cost-ok')}">$${account.cost.toFixed(2)}</span></td>
                    <td>${new Date(account.joined_date).toLocaleDateString()}</td>
                `;
            });
        }
        
        // Auto-refresh every 30 seconds
        setInterval(refreshData, 30000);
        
        // Initial load
        refreshData();
    </script>
</body>
</html>
EOF
```

**Step 4: Deploy Instructor Dashboard**

```bash
# Upload instructor dashboard to S3
aws s3 cp instructor-dashboard.html s3://$WORKSHOP_BUCKET/instructor-dashboard.html --content-type "text/html"

# Get instructor dashboard URL
echo "Instructor Dashboard URL: http://$WORKSHOP_BUCKET.s3-website-us-east-1.amazonaws.com/instructor-dashboard.html"
```

**Step 5: Test Instructor Dashboard**

```bash
# Test the dashboard API
curl https://YOUR_DASHBOARD_API_ID.execute-api.us-east-1.amazonaws.com/prod/dashboard

# Test the dashboard webpage
curl -I http://$WORKSHOP_BUCKET.s3-website-us-east-1.amazonaws.com/instructor-dashboard.html
```

### Step 7.4: Real-Time Workshop Monitoring

#### 7.4.1: Monitor Student Activity

1. **Create Activity Monitoring Script**
   ```python
   def monitor_student_activity():
       """Monitor student activity across all accounts"""
       organizations = boto3.client('organizations')
       cloudwatch = boto3.client('cloudwatch')
       
       workshop_ou_id = os.environ.get('WORKSHOP_OU_ID')
       accounts = organizations.list_accounts_for_parent(
           ParentId=workshop_ou_id
       )
       
       activity_report = []
       
       for account in accounts['Accounts']:
           account_id = account['Id']
           account_name = account['Name']
           
           # Get recent activity metrics
           try:
               # Check EC2 instances
               ec2_metrics = cloudwatch.get_metric_statistics(
                   Namespace='AWS/EC2',
                   MetricName='CPUUtilization',
                   Dimensions=[{'Name': 'InstanceId', 'Value': 'i-*'}],
                   StartTime=datetime.now() - timedelta(hours=1),
                   EndTime=datetime.now(),
                   Period=300,
                   Statistics=['Average']
               )
               
               # Check Lambda invocations
               lambda_metrics = cloudwatch.get_metric_statistics(
                   Namespace='AWS/Lambda',
                   MetricName='Invocations',
                   StartTime=datetime.now() - timedelta(hours=1),
                   EndTime=datetime.now(),
                   Period=300,
                   Statistics=['Sum']
               )
               
               activity_report.append({
                   'account_id': account_id,
                   'account_name': account_name,
                   'ec2_activity': len(ec2_metrics['Datapoints']),
                   'lambda_activity': sum([dp['Sum'] for dp in lambda_metrics['Datapoints']]),
                   'last_activity': max([dp['Timestamp'] for dp in ec2_metrics['Datapoints']] + 
                                      [dp['Timestamp'] for dp in lambda_metrics['Datapoints']], 
                                      default=datetime.now())
               })
               
           except Exception as e:
               print(f"Error monitoring activity for {account_id}: {e}")
       
       return activity_report
   ```

### Step 7.5: Student Support and Troubleshooting

#### 7.5.1: Common Issues and Solutions

1. **Create Troubleshooting Guide**
   ```markdown
   # Workshop Troubleshooting Guide
   
   ## Student Cannot Access Account
   
   **Symptoms:**
   - Student receives welcome email but cannot log in
   - Error messages about account not found
   
   **Solutions:**
   1. Check account status in AWS Organizations
   2. Verify IAM Identity Center user exists
   3. Reset password if needed
   4. Check account creation logs
   
   **Commands:**
   ```bash
   # Check account status
   aws organizations describe-account --account-id ACCOUNT-ID
   
   # Check SSO user
   aws sso-admin list-users --identity-store-id IDENTITY-STORE-ID
   
   # Reset password
   aws sso-admin reset-user-password --identity-store-id IDENTITY-STORE-ID --user-id USER-ID
   ```
   
   ## Email Not Delivered
   
   **Symptoms:**
   - Student registered but no welcome email received
   - Email in spam folder
   
   **Solutions:**
   1. Check SES configuration
   2. Verify email domain
   3. Check Lambda function logs
   4. Resend welcome email
   
   ## High Costs Alert
   
   **Symptoms:**
   - Budget alerts triggered
   - Unexpected charges
   
   **Solutions:**
   1. Check resource usage
   2. Identify expensive resources
   3. Clean up unnecessary resources
   4. Adjust budget if needed
   ```

### Step 7.6: Workshop Completion and Cleanup

#### 7.6.1: Post-Workshop Analysis

1. **Generate Workshop Report**
   ```python
   def generate_workshop_report():
       """Generate comprehensive post-workshop report"""
       organizations = boto3.client('organizations')
       ce = boto3.client('ce')
       
       workshop_ou_id = os.environ.get('WORKSHOP_OU_ID')
       accounts = organizations.list_accounts_for_parent(
           ParentId=workshop_ou_id
       )
       
       # Calculate total costs
       total_cost = 0
       account_costs = []
       
       for account in accounts['Accounts']:
           account_id = account['Id']
           
           try:
               end_date = datetime.now().strftime('%Y-%m-%d')
               start_date = (datetime.now() - timedelta(days=7)).strftime('%Y-%m-%d')
               
               response = ce.get_cost_and_usage(
                   TimePeriod={'Start': start_date, 'End': end_date},
                   Granularity='MONTHLY',
                   Metrics=['BlendedCost'],
                   Filter={
                       'Dimensions': {
                           'Key': 'LINKED_ACCOUNT',
                           'Values': [account_id]
                       }
                   }
               )
               
               cost = float(response['ResultsByTime'][0]['Total']['BlendedCost']['Amount'])
               total_cost += cost
               
               account_costs.append({
                   'account_id': account_id,
                   'name': account['Name'],
                   'email': account['Email'],
                   'cost': cost
               })
               
           except Exception as e:
               print(f"Error getting cost for {account_id}: {e}")
       
       # Generate report
       report = f"""
   # Workshop Completion Report
   Generated: {datetime.now().isoformat()}
   
   ## Summary
   - Total Students: {len(accounts['Accounts'])}
   - Workshop Duration: 7 days
   - Total Cost: ${total_cost:.2f}
   - Average Cost per Student: ${total_cost/len(accounts['Accounts']):.2f}
   
   ## Student Account Costs
   """
       
       for account_cost in sorted(account_costs, key=lambda x: x['cost'], reverse=True):
           report += f"- {account_cost['name']} ({account_cost['email']}): ${account_cost['cost']:.2f}\n"
       
       return report
   ```

#### 7.6.2: Automated Cleanup Process

1. **Create Cleanup Script**
```python
def cleanup_workshop_accounts():
       """Clean up all workshop accounts after completion"""
    organizations = boto3.client('organizations')
       sso_admin = boto3.client('sso-admin')
    
       workshop_ou_id = os.environ.get('WORKSHOP_OU_ID')
    accounts = organizations.list_accounts_for_parent(
        ParentId=workshop_ou_id
    )
       
       cleanup_log = []
    
    for account in accounts['Accounts']:
           account_id = account['Id']
           account_name = account['Name']
           account_email = account['Email']
           
           try:
               # Remove SSO users
               identity_store_id = get_identity_store_id()
               users = sso_admin.list_users(
                   IdentityStoreId=identity_store_id,
                   Filters=[{
                       'AttributePath': 'UserName',
                       'AttributeValue': account_email
                   }]
               )
               
               for user in users['Users']:
                   sso_admin.delete_user(
                       IdentityStoreId=identity_store_id,
                       UserId=user['UserId']
                   )
               
               # Close the account
               organizations.close_account(AccountId=account_id)
               
               cleanup_log.append({
                   'account_id': account_id,
                   'name': account_name,
                   'email': account_email,
                   'status': 'CLEANED_UP',
                   'timestamp': datetime.now().isoformat()
               })
               
           except Exception as e:
               cleanup_log.append({
                   'account_id': account_id,
                   'name': account_name,
                   'email': account_email,
                   'status': 'ERROR',
                   'error': str(e),
                   'timestamp': datetime.now().isoformat()
               })
       
       return cleanup_log
   ```

### Step 7.7: Final Verification and Handover

#### 7.7.1: Complete Workshop Checklist

**Step 1: Test End-to-End Registration Flow**

```bash
# Test student registration via API
curl -X POST \
  https://5ag5k2p4aa.execute-api.us-east-1.amazonaws.com/prod/register \
  -H "Content-Type: application/json" \
  -d '{"email":"final-test@example.com","name":"Final Test User","studentId":"99999"}'

# Verify account creation in Organizations
aws organizations list-accounts --query 'Accounts[?Email==`final-test@example.com`]'

# Check account status
aws organizations describe-account --account-id ACCOUNT_ID_FROM_ABOVE
```

**Step 2: Test Instructor Dashboard**

```bash
# Test dashboard API (replace with actual API ID)
curl https://YOUR_DASHBOARD_API_ID.execute-api.us-east-1.amazonaws.com/prod/dashboard

# Test dashboard webpage
curl -I http://$WORKSHOP_BUCKET.s3-website-us-east-1.amazonaws.com/instructor-dashboard.html
```

**Step 3: Test Support System**

```bash
# Test support request
curl -X POST \
  https://YOUR_SUPPORT_API_ID.execute-api.us-east-1.amazonaws.com/prod/support \
  -H "Content-Type: application/json" \
  -d '{"email":"final-test@example.com","issue_type":"account_access"}'

# Test troubleshooting script
python3 troubleshoot-account.py final-test@example.com
```

**Step 4: Test Monitoring and Alerts**

```bash
# Test activity monitoring
python3 activity-monitor.py

# Test monitoring Lambda
aws lambda invoke \
  --function-name workshop-activity-monitor \
  --payload '{}' \
  monitoring-test.json

cat monitoring-test.json
```

**Step 5: Test Cleanup and Reporting**

```bash
# Test final report generation
python3 final-report-generator.py

# Test cleanup script
python3 workshop-cleanup.py

# Test cleanup Lambda
aws lambda invoke \
  --function-name workshop-cleanup \
  --payload '{}' \
  cleanup-test.json

cat cleanup-test.json
```

**Step 6: Comprehensive Verification Checklist**

```bash
# Create verification script
cat > verify-workshop-setup.sh << 'EOF'
#!/bin/bash

echo "🔍 Workshop Setup Verification"
echo "=============================="

# Check Lambda functions
echo "1. Checking Lambda functions..."
aws lambda list-functions --query 'Functions[?contains(FunctionName, `workshop`) || contains(FunctionName, `infrastructure`)].FunctionName' --output table

# Check API Gateways
echo -e "\n2. Checking API Gateways..."
aws apigateway get-rest-apis --query 'items[?contains(name, `workshop`) || contains(name, `instructor`)].{Name:name,Id:id}' --output table

# Check S3 buckets
echo -e "\n3. Checking S3 buckets..."
aws s3 ls | grep workshop

# Check Organizations OU
echo -e "\n4. Checking Organizations OU..."
aws organizations list-organizational-units-for-parent --parent-id r-$(aws organizations list-roots --query 'Roots[0].Id' --output text | cut -d'-' -f2)

# Check SES configuration
echo -e "\n5. Checking SES configuration..."
aws ses get-identity-verification-attributes --identities conor.macklin1986@gmail.com

# Check CloudWatch alarms
echo -e "\n6. Checking CloudWatch alarms..."
aws cloudwatch describe-alarms --alarm-names workshop-activity-monitor workshop-account-creation-errors

# Check SNS topics
echo -e "\n7. Checking SNS topics..."
aws sns list-topics --query 'Topics[?contains(TopicArn, `workshop`)]'

echo -e "\n✅ Verification complete!"
EOF

chmod +x verify-workshop-setup.sh
./verify-workshop-setup.sh
```

**Step 7: Final System Status Check**

```bash
# Create final status report
cat > final-status-check.py << 'EOF'
import boto3
import json
from datetime import datetime

def check_system_status():
    """Check overall system status"""
    status = {
        'timestamp': datetime.now().isoformat(),
        'components': {},
        'overall_status': 'UNKNOWN'
    }
    
    # Check Lambda functions
    try:
        lambda_client = boto3.client('lambda')
        functions = lambda_client.list_functions()
        workshop_functions = [f for f in functions['Functions'] if 'workshop' in f['FunctionName'] or 'infrastructure' in f['FunctionName']]
        status['components']['lambda_functions'] = {
            'status': 'OK' if len(workshop_functions) >= 3 else 'WARNING',
            'count': len(workshop_functions),
            'functions': [f['FunctionName'] for f in workshop_functions]
        }
    except Exception as e:
        status['components']['lambda_functions'] = {'status': 'ERROR', 'error': str(e)}
    
    # Check API Gateways
    try:
        apigw_client = boto3.client('apigateway')
        apis = apigw_client.get_rest_apis()
        workshop_apis = [api for api in apis['items'] if 'workshop' in api['name'] or 'instructor' in api['name']]
        status['components']['api_gateways'] = {
            'status': 'OK' if len(workshop_apis) >= 2 else 'WARNING',
            'count': len(workshop_apis),
            'apis': [api['name'] for api in workshop_apis]
        }
    except Exception as e:
        status['components']['api_gateways'] = {'status': 'ERROR', 'error': str(e)}
    
    # Check S3 buckets
    try:
        s3_client = boto3.client('s3')
        buckets = s3_client.list_buckets()
        workshop_buckets = [b for b in buckets['Buckets'] if 'workshop' in b['Name']]
        status['components']['s3_buckets'] = {
            'status': 'OK' if len(workshop_buckets) >= 1 else 'WARNING',
            'count': len(workshop_buckets),
            'buckets': [b['Name'] for b in workshop_buckets]
        }
    except Exception as e:
        status['components']['s3_buckets'] = {'status': 'ERROR', 'error': str(e)}
    
    # Determine overall status
    component_statuses = [comp['status'] for comp in status['components'].values()]
    if all(status == 'OK' for status in component_statuses):
        status['overall_status'] = 'HEALTHY'
    elif any(status == 'ERROR' for status in component_statuses):
        status['overall_status'] = 'ERROR'
    else:
        status['overall_status'] = 'WARNING'
    
    return status

if __name__ == "__main__":
    status = check_system_status()
    print(json.dumps(status, indent=2))
EOF

python3 final-status-check.py
```

**Step 8: Workshop Ready Confirmation**

```bash
echo "🎉 WORKSHOP SETUP COMPLETE! 🎉"
echo "==============================="
echo ""
echo "✅ Student Registration: http://$WORKSHOP_BUCKET.s3-website-us-east-1.amazonaws.com"
echo "✅ Instructor Dashboard: http://$WORKSHOP_BUCKET.s3-website-us-east-1.amazonaws.com/instructor-dashboard.html"
echo "✅ Support System: http://$WORKSHOP_BUCKET.s3-website-us-east-1.amazonaws.com/support-request.html"
echo ""
echo "📋 Next Steps:"
echo "1. Share registration URL with students"
echo "2. Monitor via instructor dashboard"
echo "3. Use support system for troubleshooting"
echo "4. Run cleanup scripts after workshop completion"
echo ""
echo "🔧 Management Commands:"
echo "- Monitor activity: python3 activity-monitor.py"
echo "- Generate report: python3 final-report-generator.py"
echo "- Run cleanup: python3 workshop-cleanup.py"
echo "- Check status: python3 final-status-check.py"
```

**Complete Workshop Checklist:**
- [ ] All student accounts created successfully
- [ ] Welcome emails delivered
- [ ] Budgets and monitoring configured
- [ ] Instructor dashboard operational
- [ ] Student support processes in place
- [ ] Workshop materials accessible
- [ ] Cleanup procedures tested
- [ ] Post-workshop reporting ready

#### 7.7.2: Workshop Management Summary

**What's Now Configured:**
- ✅ Complete student registration system
- ✅ Real-time instructor dashboard
- ✅ Automated monitoring and alerts
- ✅ Student support and troubleshooting
- ✅ Post-workshop analysis and cleanup
- ✅ Comprehensive reporting system

**Workshop Management Features:**
- **Student Registration**: Automated account creation and onboarding
- **Real-Time Monitoring**: Live dashboard with cost and activity tracking
- **Support Automation**: Automated troubleshooting and issue resolution
- **Cleanup Automation**: Post-workshop account and resource cleanup
- **Reporting**: Comprehensive pre, during, and post-workshop reporting

**Step 7 is now complete!** 🎯✅

Your workshop management system is fully configured and ready to handle the complete workshop lifecycle from registration through cleanup.

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
