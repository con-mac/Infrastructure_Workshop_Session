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

1. **Switch to the test account**
   ```bash
   # Use AWS Organizations console to switch role
   # Or use AWS CLI with assume role
   ```

2. **Verify account access**
   ```bash
   aws sts get-caller-identity
   ```

### Step 3: Deploy Lab Infrastructure

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

### Step 4: Create IAM User for Direct Console Access

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

### Step 5: Generate Direct Console Link

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

### Step 6: Test Student Workflow

1. **Test Console Login**
   - Open the console URL
   - Login with student1 credentials
   - Verify no MFA required
   - Test basic navigation

2. **Test Lab Infrastructure**
   - Verify 2-tier app is deployed
   - Test application access
   - Check resource availability

3. **Test Lab Workflow**
   - Complete a sample lab challenge
   - Verify all required resources are available
   - Test any lab-specific functionality

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

- This approach gives you a working system today
- You can test everything before creating all accounts
- Tomorrow you can create the remaining accounts
- Same process will be used for all student accounts

---

**Ready to start? Begin with Step 1: Identify Existing Account**
