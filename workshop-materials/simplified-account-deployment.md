# Simplified Account Deployment Guide

## 🎯 Overview

This guide provides a step-by-step approach to create individual AWS accounts for students with pre-deployed lab infrastructure and direct console access. This approach bypasses the AWS Organizations account creation limits and eliminates MFA complexity while providing true account-level isolation.

## 📋 Prerequisites

- AWS Organizations master account access
- Existing Workshop-Students OU created
- CloudFormation template for 2-tier application
- Existing dashboard infrastructure
- 2-3 hours for complete setup

## 🚀 Step-by-Step Implementation

### Step 1: Manual Account Creation

**Objective:** Create individual AWS accounts for each student through the AWS Organizations console to bypass API limits.

#### 1.1 Access AWS Organizations Console

1. **Navigate to AWS Organizations**
   - Go to AWS Console → Services → AWS Organizations
   - Ensure you're in the master account (535002854646)

2. **Verify Organization Structure**
   - Confirm Workshop-Students OU exists
   - Note the OU ID: `ou-01dw-2r1xz8cp`

#### 1.2 Create Individual Accounts

**For each student (8 total), follow these steps:**

1. **Click "Add account"**
   - In AWS Organizations console
   - Select "Create account"

2. **Account Details**
   - **Account name:** `Student1-Workshop-2025` (replace 1 with student number)
   - **Email address:** `student1+workshop@yourdomain.com` (use your domain)
   - **IAM role name:** `OrganizationAccountAccessRole` (default)

3. **Create Account**
   - Click "Create account"
   - Wait for account creation (5-10 minutes)
   - Note the account ID when created

4. **Move Account to Workshop-Students OU**
   - Select the newly created account
   - Click "Move account"
   - Select "Workshop-Students" OU
   - Confirm move

**Repeat for all 8 students:**
- Student1-Workshop-2025
- Student2-Workshop-2025
- Student3-Workshop-2025
- Student4-Workshop-2025
- Student5-Workshop-2025
- Student6-Workshop-2025
- Student7-Workshop-2025
- Student8-Workshop-2025

#### 1.3 Document Account Information

Create a tracking document with:
- Account name
- Account ID
- Email address
- OU location
- Creation status

### Step 2: Pre-deploy Lab Infrastructure

**Objective:** Deploy the 2-tier application CloudFormation template in each student account.

#### 2.1 Prepare CloudFormation Template

1. **Locate Template**
   - Use existing template: `workshop-materials/cloudformation/working-2-tier-app.yaml`
   - Verify template is ready for deployment

2. **Template Modifications**
   - Add student-specific tags to all resources
   - Ensure all resources are tagged with student identifier
   - Verify resource naming conventions

#### 2.2 Deploy to Each Account

**For each student account:**

1. **Switch to Student Account**
   - Use AWS Organizations console
   - Click "Switch role" for the student account
   - Use OrganizationAccountAccessRole

2. **Deploy CloudFormation Stack**
   - Go to CloudFormation console
   - Click "Create stack"
   - Upload template: `working-2-tier-app.yaml`
   - Stack name: `Student1-Lab-Infrastructure`

3. **Configure Parameters**
   - Set appropriate parameters for the lab
   - Ensure all resources are tagged with student ID
   - Review and create stack

4. **Monitor Deployment**
   - Wait for stack creation to complete
   - Verify all resources are created successfully
   - Note any errors or issues

**Repeat for all 8 student accounts**

#### 2.3 Verify Infrastructure

1. **Check Resource Creation**
   - EC2 instances
   - RDS database
   - Load balancer
   - Security groups
   - VPC and subnets

2. **Test Application Access**
   - Verify application is accessible
   - Test basic functionality
   - Document access URLs

### Step 3: Create IAM Users for Direct Console Access

**Objective:** Create IAM users in each student account with appropriate permissions for lab work.

#### 3.1 Create IAM User in Each Account

**For each student account:**

1. **Switch to Student Account**
   - Use AWS Organizations console
   - Switch to the student account

2. **Create IAM User**
   - Go to IAM console
   - Click "Users" → "Add user"
   - **Username:** `student1` (replace with student number)
   - **Access type:** AWS Management Console access
   - **Console password:** Custom password
   - **Password:** `Workshop2025!` (or generate secure password)

3. **Attach Policies**
   - Attach `PowerUserAccess` policy
   - This provides access to most AWS services needed for labs

4. **Create User**
   - Review settings
   - Create user
   - Note the console login URL

#### 3.2 Generate Direct Console Links

**For each student account:**

1. **Console Login URL Format**
   ```
   https://ACCOUNT_ID.signin.aws.amazon.com/console
   ```

2. **Example URLs**
   - Student1: `https://123456789012.signin.aws.amazon.com/console`
   - Student2: `https://123456789013.signin.aws.amazon.com/console`
   - etc.

3. **Document Access Information**
   - Console URL
   - Username
   - Password
   - Account ID

### Step 4: Update Dashboard for Monitoring

**Objective:** Modify the existing dashboard to monitor all student accounts and their lab progress.

#### 4.1 Modify Dashboard Lambda Function

1. **Update Lambda Function**
   - Modify `lambda-account-creation.py` to include account monitoring
   - Add functions to check account status
   - Add functions to monitor lab progress

2. **Add Account Monitoring Functions**
   ```python
   def get_all_student_accounts():
       # List all accounts in Workshop-Students OU
       # Return account details and status
   
   def check_account_health(account_id):
       # Check if account is active
       # Check if lab infrastructure is deployed
       # Return health status
   
   def get_lab_progress(account_id):
       # Check CloudFormation stack status
       # Check resource creation status
       # Return progress information
   ```

#### 4.2 Update Dashboard HTML

1. **Modify Dashboard Interface**
   - Add account monitoring section
   - Display account status for each student
   - Show lab progress indicators
   - Add cleanup controls

2. **Add New Dashboard Features**
   - Account health status
   - Lab deployment status
   - Resource usage monitoring
   - Cleanup progress tracking

#### 4.3 Test Dashboard Updates

1. **Verify Dashboard Functionality**
   - Test account monitoring
   - Verify lab progress tracking
   - Test cleanup controls

2. **Update Dashboard Access**
   - Ensure dashboard is accessible
   - Test all monitoring features

### Step 5: Testing and Verification

**Objective:** Test the complete student workflow to ensure everything works correctly.

#### 5.1 Test Student Access

1. **Test Console Login**
   - Use student1 credentials
   - Access console via direct link
   - Verify no MFA required
   - Test basic navigation

2. **Test Lab Infrastructure**
   - Verify 2-tier app is deployed
   - Test application access
   - Check resource availability

3. **Test Lab Workflow**
   - Complete a sample lab challenge
   - Verify all required resources are available
   - Test cleanup process

#### 5.2 Verify Dashboard Monitoring

1. **Check Dashboard Updates**
   - Verify account monitoring works
   - Check lab progress tracking
   - Test cleanup controls

2. **Test Monitoring Features**
   - Account health checks
   - Resource usage monitoring
   - Progress tracking

### Step 6: Cleanup Process Implementation

**Objective:** Implement automated cleanup process for post-workshop resource removal.

#### 6.1 Create Cleanup Lambda Function

1. **Create Cleanup Function**
   - New Lambda function for cleanup
   - Function to delete all student resources
   - Function to remove student accounts

2. **Cleanup Functions**
   ```python
   def cleanup_student_account(account_id):
       # Delete all resources in account
       # Remove IAM users
       # Clean up CloudFormation stacks
   
   def remove_account_from_org(account_id):
       # Remove account from organization
       # Handle account closure
   ```

#### 6.2 Implement Cleanup Dashboard

1. **Add Cleanup Controls**
   - Cleanup button for each account
   - Bulk cleanup option
   - Cleanup progress tracking

2. **Test Cleanup Process**
   - Test individual account cleanup
   - Test bulk cleanup
   - Verify complete resource removal

### Step 7: Final Verification and Documentation

**Objective:** Ensure everything is working correctly and document the complete setup.

#### 7.1 Complete System Test

1. **Test All Components**
   - Account creation
   - Lab infrastructure deployment
   - Student access
   - Dashboard monitoring
   - Cleanup process

2. **Verify Student Experience**
   - Test complete student workflow
   - Verify no MFA requirements
   - Test lab completion process

#### 7.2 Document Setup

1. **Create Setup Documentation**
   - Document all account details
   - Record access credentials
   - Note any customizations

2. **Create Student Instructions**
   - Simple login instructions
   - Lab access guide
   - Troubleshooting tips

## 🔧 Troubleshooting

### Common Issues

1. **Account Creation Fails**
   - Check AWS Organizations limits
   - Verify email addresses are unique
   - Ensure proper permissions

2. **CloudFormation Deployment Fails**
   - Check template syntax
   - Verify parameter values
   - Check resource limits

3. **Student Access Issues**
   - Verify IAM user creation
   - Check console URL format
   - Verify password settings

4. **Dashboard Monitoring Issues**
   - Check Lambda function permissions
   - Verify API Gateway configuration
   - Test dashboard connectivity

### Support Resources

- AWS Organizations documentation
- CloudFormation troubleshooting guide
- IAM user management guide
- Lambda function debugging

## 📊 Success Criteria

- ✅ 8 student accounts created and moved to Workshop-Students OU
- ✅ Lab infrastructure deployed in each account
- ✅ IAM users created with direct console access
- ✅ Dashboard monitoring all accounts
- ✅ Cleanup process implemented and tested
- ✅ Students can access labs without MFA
- ✅ Complete student workflow tested and verified

## 🎯 Next Steps

1. **Follow this guide step by step**
2. **Ask questions in chat as you implement**
3. **Test each step before proceeding**
4. **Document any issues or modifications**
5. **Verify complete system functionality**

## 📝 Notes

- This approach bypasses AWS Organizations API limits
- Students get direct console access without MFA
- Each student has isolated account-level environment
- Dashboard provides real-time monitoring
- Cleanup process ensures resource removal after workshop

---

**Ready to start? Begin with Step 1: Manual Account Creation**
