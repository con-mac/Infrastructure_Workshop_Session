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
