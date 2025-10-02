# Test with Existing Account Guide

## 🎯 Overview

Since we've hit the AWS Organizations account creation limit (5 per day), let's use one of your existing accounts to build and test the complete lab functionality today. This approach allows us to:

- ✅ Test everything immediately
- ✅ Have a working demo for the workshop
- ✅ Fix any issues before creating all accounts
- ✅ Create remaining accounts tomorrow when limits reset

## 📋 Prerequisites

- Existing AWS account (not the master account)
- AWS CLI configured
- Access to the existing account

## 🚀 Step-by-Step Implementation

### Step 1: Identify Existing Account

1. **List your existing accounts**
   ```bash
   aws organizations list-accounts --query 'Accounts[?Status==`ACTIVE`]'
   ```

2. **Choose a test account**
   - Pick an account that's not the master account
   - Note the Account ID
   - We'll use this as "Student1" for testing

### Step 2: Switch to Test Account

1. **Switch to the test account using AWS Organizations Console**
   - Go to AWS Organizations console
   - Find your test account
   - Click "Switch role" or "Access account"
   - Use OrganizationAccountAccessRole

2. **Verify account access**
   ```bash
   aws sts get-caller-identity
   ```
   - You should now be in the test account (not master account)
   - Note the Account ID for later use

### Step 3: Deploy Lab Infrastructure (As Root User)

**You're now in the test account as root user (via OrganizationAccountAccessRole)**

1. **Deploy CloudFormation Stack**
   ```bash
   aws cloudformation create-stack \
     --stack-name "Student1-Lab-Infrastructure" \
     --template-body file://workshop-materials/cloudformation/working-2-tier-app.yaml \
     --capabilities CAPABILITY_IAM
   ```

2. **Monitor deployment**
   ```bash
   aws cloudformation describe-stacks \
     --stack-name "Student1-Lab-Infrastructure" \
     --query 'Stacks[0].StackStatus'
   ```

3. **Verify resources**
   ```bash
   # Check EC2 instances
   aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name]'
   
   # Check RDS database
   aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]'
   
   # Check Load Balancer
   aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,State.Code]'
   ```

4. **Get Application URL**
   ```bash
   # Get Load Balancer DNS name
   aws elbv2 describe-load-balancers \
     --query 'LoadBalancers[0].DNSName' \
     --output text
   ```

### Step 4: Create IAM User for Student Lab Work

**Still in the test account as root user - creating IAM user for student**

1. **Create IAM User**
   ```bash
   aws iam create-user --user-name "student1"
   ```

2. **Set Console Password**
   ```bash
   aws iam create-login-profile \
     --user-name "student1" \
     --password "Workshop2025!" \
     --password-reset-required
   ```

3. **Attach PowerUserAccess Policy**
   ```bash
   aws iam attach-user-policy \
     --user-name "student1" \
     --policy-arn "arn:aws:iam::aws:policy/PowerUserAccess"
   ```

4. **Verify IAM User Creation**
   ```bash
   aws iam get-user --user-name "student1"
   ```

### Step 5: Generate Direct Console Link

**Still in the test account as root user - generating access info for student**

1. **Get Account ID**
   ```bash
   ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
   echo "Account ID: $ACCOUNT_ID"
   ```

2. **Generate Console URL**
   ```bash
   CONSOLE_URL="https://${ACCOUNT_ID}.signin.aws.amazon.com/console"
   echo "Console URL: $CONSOLE_URL"
   echo "Username: student1"
   echo "Password: Workshop2025!"
   ```

3. **Document Access Information**
   ```bash
   echo "=== STUDENT ACCESS INFORMATION ===" > student-access.txt
   echo "Console URL: $CONSOLE_URL" >> student-access.txt
   echo "Username: student1" >> student-access.txt
   echo "Password: Workshop2025!" >> student-access.txt
   echo "Account ID: $ACCOUNT_ID" >> student-access.txt
   ```

### Step 6: Test Student Workflow (As IAM User)

**Now switch to the IAM user to test the student experience**

1. **Test Console Login**
   - Open the console URL: `https://ACCOUNT_ID.signin.aws.amazon.com/console`
   - Login with student1 credentials
   - Verify no MFA required
   - Test basic navigation

2. **Test Lab Infrastructure**
   - Verify 2-tier app is deployed
   - Test application access
   - Check resource availability
   - Verify you can see all lab resources

3. **Test Lab Workflow**
   - Complete a sample lab challenge
   - Verify all required resources are available
   - Test any lab-specific functionality
   - Verify you can modify resources as needed

4. **Verify Security**
   - Confirm you're logged in as student1 (not root)
   - Check that you have appropriate permissions
   - Verify you can't access root-level functions

### Step 7: Update Dashboard for Monitoring

1. **Modify Dashboard Lambda Function**
   - Update to monitor the test account
   - Add account health checks
   - Test monitoring functionality

2. **Test Dashboard**
   - Verify account monitoring works
   - Check lab progress tracking
   - Test any dashboard features

### Step 8: Document Process

1. **Create Setup Documentation**
   - Document all steps taken
   - Record any customizations
   - Note any issues encountered

2. **Create Student Instructions**
   - Simple login instructions
   - Lab access guide
   - Troubleshooting tips

## 🔧 Troubleshooting

### Common Issues

1. **Account Access Issues**
   - Verify account ID is correct
   - Check IAM user permissions
   - Verify console URL format

2. **CloudFormation Deployment Issues**
   - Check template syntax
   - Verify parameter values
   - Check resource limits

3. **Lab Infrastructure Issues**
   - Verify all resources are created
   - Check security group rules
   - Test application connectivity

### Support Resources

- AWS CloudFormation troubleshooting
- IAM user management guide
- EC2 and RDS documentation

## 📊 Success Criteria

- ✅ Test account identified and accessible
- ✅ Lab infrastructure deployed successfully
- ✅ IAM user created with console access
- ✅ Direct console link working
- ✅ Student workflow tested and verified
- ✅ Dashboard monitoring functional
- ✅ Complete process documented

## 🎯 Next Steps

1. **Today:** Complete this test setup
2. **Tomorrow:** Create remaining 9 student accounts
3. **Deploy:** Same setup to all new accounts
4. **Workshop:** Ready to go!

## 📝 Notes

- **Root user** deploys lab infrastructure (full permissions for setup)
- **IAM user** completes lab challenges (restricted permissions for security)
- **Better security** - root user not used for lab work
- **AWS best practices** - separation of setup vs. lab work
- **Working system today** - no waiting for account limits
- **Tomorrow** - create remaining accounts with same process

---

**Ready to start? Begin with Step 1: Identify Existing Account**
