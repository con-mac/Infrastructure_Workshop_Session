# AWS Infrastructure Workshop - Lab Guide
## Challenge-Based Learning for University Apprentices

---

## Table of Contents

1. [Pre-Workshop Setup](#pre-workshop-setup)
2. [AWS Console Navigation](#aws-console-navigation)
3. [Initial Deployment](#initial-deployment)
4. [Challenge 1: NACL Misconfiguration](#challenge-1-nacl-misconfiguration)
5. [Challenge 2: Security Group Issues](#challenge-2-security-group-issues)
6. [Challenge 3: IAM Permission Problems](#challenge-3-iam-permission-problems)
7. [Challenge 4: Load Balancer Configuration](#challenge-4-load-balancer-configuration)
8. [Challenge 5: Blue-Green Deployment](#challenge-5-blue-green-deployment)
9. [Monitoring and Validation](#monitoring-and-validation)
10. [Cleanup and Cost Management](#cleanup-and-cost-management)

---

## Pre-Workshop Setup

### Account Registration

**Objective:** Get access to your dedicated AWS account for the workshop.

**Steps:**
1. **Visit the registration page** provided by your instructor
2. **Enter your university email address**
3. **Check your email** for AWS account access details
4. **Follow the login instructions** in your email

**Expected Result:** You should be able to log into your dedicated AWS account.

**Troubleshooting:**
- If you don't receive an email within 5 minutes, check your spam folder
- Contact your instructor if you have login issues
- Ensure you're using the correct email address

### First Login

**Steps:**
1. **Click the AWS Console link** in your email
2. **Enter your temporary password**
3. **Set a new password** (follow AWS password requirements)
4. **Complete the initial setup** if prompted

**Security Note:** Your account is isolated from other students - you can only see your own resources.

---

## AWS Console Navigation

### Overview

**Learning Objective:** Familiarise yourself with the AWS console interface and key services.

**Time Estimate:** 15 minutes

### Key AWS Services You'll Use

1. **EC2 (Elastic Compute Cloud)** - Virtual servers
2. **VPC (Virtual Private Cloud)** - Networking
3. **S3 (Simple Storage Service)** - Object storage
4. **RDS (Relational Database Service)** - Managed databases
5. **CloudFormation** - Infrastructure as Code
6. **CloudWatch** - Monitoring and logging
7. **IAM (Identity and Access Management)** - Security and permissions

### Console Navigation Exercise

**Task:** Explore the AWS console and locate key services.

**Steps:**
1. **Log into AWS Console**
2. **Find the Services menu** (top-left corner)
3. **Search for "EC2"** and click on it
4. **Notice the EC2 dashboard** - this shows your virtual servers
5. **Search for "VPC"** and explore the networking section
6. **Search for "CloudFormation"** - this is where we'll deploy infrastructure
7. **Search for "CloudWatch"** - this shows monitoring and logs

**Key Areas to Explore:**
- **Dashboard views** for each service
- **Resource lists** (instances, volumes, etc.)
- **Service-specific navigation menus**
- **Search functionality** within services

---

## Initial Deployment

### Objective

Deploy a working 2-tier web application to understand the baseline architecture before troubleshooting challenges.

**Time Estimate:** 20 minutes

### Architecture Overview

```
Internet → Application Load Balancer → Auto Scaling Group → EC2 Instances
                                                              ↓
                                                         RDS MySQL
```

**Components:**
- **VPC:** Virtual network with public and private subnets
- **Load Balancer:** Distributes traffic across multiple servers
- **Auto Scaling Group:** Automatically manages server capacity
- **EC2 Instances:** Virtual servers running the web application
- **RDS Database:** Managed MySQL database

### Deployment Steps

**Step 1: Access CloudFormation**
1. **Navigate to CloudFormation** in the AWS console
2. **Click "Create stack"**
3. **Select "Upload a template file"**
4. **Upload the `working-2-tier-app.yaml` template**

**Step 2: Configure Stack Parameters**
1. **Stack name:** `[YourName]-working-app`
2. **StudentEmail:** Enter your email address
3. **Environment:** `workshop`
4. **InstanceType:** `t2.micro` (default)
5. **DBPassword:** `Workshop2024!` (or create your own)

**Step 3: Deploy the Stack**
1. **Click "Next"** through the configuration options
2. **Review the template** and click "Create stack"
3. **Wait for deployment** (5-10 minutes)
4. **Monitor the Events tab** for progress

**Step 4: Verify Deployment**
1. **Go to the Outputs tab** in CloudFormation
2. **Copy the ApplicationURL**
3. **Open the URL in your browser**
4. **Verify you see the working application page**

### Expected Results

- ✅ CloudFormation stack shows "CREATE_COMPLETE"
- ✅ Application loads in browser with green status indicators
- ✅ All architecture components are properly configured
- ✅ Health checks are passing

### Troubleshooting Initial Deployment

**If the stack fails:**
1. **Check the Events tab** for error messages
2. **Common issues:**
   - Parameter validation errors
   - Resource limit exceeded
   - Template syntax errors
3. **Contact instructor** if you can't resolve the issue

---

## Challenge 1: NACL Misconfiguration

### Objective

Identify and fix Network ACL (NACL) rules that are blocking inbound HTTP traffic.

**Time Estimate:** 30 minutes

### Problem Description

The application has been deployed, but it's not accessible from the internet. The issue is with the Network ACL configuration.

**Symptoms:**
- Application URL returns connection timeout or error
- EC2 instances are running and healthy
- Security Groups are correctly configured
- Network ACL is blocking traffic

### Troubleshooting Steps

**Step 1: Verify the Problem**
1. **Access your working application URL** from Challenge 0
2. **Note:** It should still be working
3. **Deploy the NACL challenge template:**
   - Stack name: `[YourName]-nacl-challenge`
   - Use the `nacl-challenge.yaml` template
4. **Try to access the new application URL**
5. **Confirm it's not accessible**

**Step 2: Investigate Network ACL**
1. **Navigate to VPC → Network ACLs**
2. **Find your workshop NACL** (should have your name in the tag)
3. **Click on the NACL ID**
4. **Go to the "Inbound rules" tab**
5. **Look for rules with "Deny" action**

**Step 3: Identify the Issue**
- **Look for Rule 100:** Denies TCP traffic on port 80
- **Look for Rule 110:** Denies TCP traffic on port 443
- **These rules block HTTP/HTTPS traffic**

**Step 4: Fix the NACL Rules**
1. **Select the problematic NACL**
2. **Go to "Inbound rules" tab**
3. **Click "Edit inbound rules"**
4. **Delete the deny rules for ports 80 and 443**
5. **Save changes**

**Step 5: Test the Fix**
1. **Wait 1-2 minutes** for changes to take effect
2. **Try accessing the application URL again**
3. **Verify the application loads successfully**

### Learning Points

- **Network ACLs vs Security Groups:** NACLs operate at subnet level, Security Groups at instance level
- **Rule Evaluation:** NACLs evaluate rules in order, first match wins
- **Stateful vs Stateless:** Security Groups are stateful, NACLs are stateless
- **Default Rules:** NACLs have default allow-all rules that can be overridden

### Expected Results

- ✅ NACL deny rules removed for HTTP/HTTPS
- ✅ Application accessible from internet
- ✅ Understanding of NACL troubleshooting process

---

## Challenge 2: Security Group Issues

### Objective

Fix Security Group configuration that's preventing load balancer health checks from reaching instances.

**Time Estimate:** 30 minutes

### Problem Description

The load balancer shows unhealthy targets, preventing the application from being accessible through the load balancer URL.

**Symptoms:**
- Load balancer target group shows unhealthy targets
- Direct EC2 access works but load balancer doesn't
- Health checks are failing
- Application not accessible via load balancer URL

### Troubleshooting Steps

**Step 1: Deploy the Challenge**
1. **Deploy the security group challenge template:**
   - Stack name: `[YourName]-sg-challenge`
   - Use the `security-group-challenge.yaml` template
2. **Wait for deployment completion**
3. **Note the LoadBalancerURL from outputs**

**Step 2: Verify the Problem**
1. **Try accessing the LoadBalancerURL**
2. **Confirm it's not working** (should timeout or show error)
3. **Check if direct EC2 access works** (if you can find the public IP)

**Step 3: Investigate Load Balancer Health**
1. **Navigate to EC2 → Load Balancers**
2. **Click on your workshop load balancer**
3. **Go to the "Target groups" tab**
4. **Click on the target group**
5. **Check the "Targets" tab**
6. **Note the health status** (should show "unhealthy")

**Step 4: Investigate Security Groups**
1. **Navigate to EC2 → Security Groups**
2. **Find the web tier security group** (should have "web-sg" in the name)
3. **Review the inbound rules**
4. **Look for the HTTP rule** (port 80)

**Step 5: Identify the Issue**
- **Security Group Rule:** Only allows traffic from `10.0.0.0/16` CIDR
- **Problem:** Load balancer health checks come from the ALB's security group, not from this CIDR range
- **Missing Rule:** No rule allowing ALB security group to reach instances

**Step 6: Fix the Security Group**
1. **Select the web tier security group**
2. **Go to "Inbound rules" tab**
3. **Click "Edit inbound rules"**
4. **Add a new rule:**
   - **Type:** HTTP
   - **Source:** Select the load balancer security group
   - **Description:** Allow ALB health checks
5. **Save changes**

**Step 7: Test the Fix**
1. **Wait 2-3 minutes** for health checks to pass
2. **Check target group health** again
3. **Try accessing the LoadBalancerURL**
4. **Verify application loads successfully**

### Learning Points

- **Security Group Sources:** Can reference other security groups, not just IP addresses
- **Load Balancer Health Checks:** Come from the ALB's security group
- **Health Check Process:** ALB checks target health before routing traffic
- **Rule Precedence:** More specific rules can override broader ones

### Expected Results

- ✅ Security group allows ALB health checks
- ✅ Target group shows healthy targets
- ✅ Application accessible via load balancer
- ✅ Understanding of ALB health check process

---

## Challenge 3: IAM Permission Problems

### Objective

Fix IAM role permissions that prevent the application from accessing required AWS services.

**Time Estimate:** 30 minutes

### Problem Description

The application is running but cannot access AWS services like S3 and CloudWatch Logs due to insufficient IAM permissions.

**Symptoms:**
- Application loads but shows permission errors
- Cannot access S3 buckets
- Cannot write to CloudWatch Logs
- IAM-related error messages in application

### Troubleshooting Steps

**Step 1: Deploy the Challenge**
1. **Deploy the IAM challenge template:**
   - Stack name: `[YourName]-iam-challenge`
   - Use the `iam-challenge.yaml` template
2. **Wait for deployment completion**
3. **Access the application URL** from the outputs

**Step 2: Verify the Problem**
1. **Open the application in your browser**
2. **Look for error messages** about AWS service access
3. **Note which services are failing** (S3, CloudWatch Logs)
4. **Check the service access status** displayed on the page

**Step 3: Investigate IAM Role**
1. **Navigate to IAM → Roles**
2. **Find your EC2 instance role** (should have your name and "ec2-role")
3. **Click on the role name**
4. **Review the "Permissions" tab**
5. **Note the attached policies**

**Step 4: Identify the Issue**
- **Missing Policies:** Role has no managed policies attached
- **No S3 Access:** Cannot access the application data bucket
- **No CloudWatch Access:** Cannot write logs to CloudWatch

**Step 5: Fix IAM Permissions**
1. **Select the EC2 instance role**
2. **Go to "Permissions" tab**
3. **Click "Attach policies"**
4. **Add the following managed policies:**
   - `CloudWatchAgentServerPolicy`
   - `AmazonS3ReadOnlyAccess`
5. **Click "Attach policies"**

**Step 6: Create Custom Policy for S3**
1. **Go to IAM → Policies**
2. **Click "Create policy"**
3. **Use JSON editor** and paste:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::your-bucket-name/*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::your-bucket-name"
        }
    ]
}
```
4. **Replace `your-bucket-name`** with your actual bucket name
5. **Name the policy:** `[YourName]-S3Access`
6. **Create the policy**

**Step 7: Attach Custom Policy**
1. **Go back to your EC2 role**
2. **Attach the custom S3 policy** you just created
3. **Save changes**

**Step 8: Test the Fix**
1. **Wait 1-2 minutes** for policy changes to take effect
2. **Refresh the application page**
3. **Check the service access status**
4. **Verify all services show "Success"**

### Learning Points

- **IAM Roles vs Users:** Roles are for AWS services, users are for people
- **Instance Profiles:** Connect EC2 instances to IAM roles
- **Policy Types:** Managed policies (AWS-provided) and custom policies
- **Least Privilege:** Only grant necessary permissions
- **Policy Evaluation:** Policies are evaluated in combination

### Expected Results

- ✅ IAM role has required managed policies
- ✅ Custom S3 policy attached
- ✅ Application can access S3 and CloudWatch Logs
- ✅ All service access status shows "Success"

---

## Challenge 4: Load Balancer Configuration

### Objective

Fix load balancer target group health check configuration that's preventing targets from being marked as healthy.

**Time Estimate:** 30 minutes

### Problem Description

The load balancer health checks are failing due to incorrect target group configuration, causing targets to be marked as unhealthy.

**Symptoms:**
- Load balancer target group shows unhealthy targets
- Health checks are failing
- Application not accessible via load balancer
- Direct instance access works fine

### Troubleshooting Steps

**Step 1: Deploy the Challenge**
1. **Deploy the load balancer challenge template:**
   - Stack name: `[YourName]-lb-challenge`
   - Use the `load-balancer-challenge.yaml` template
2. **Wait for deployment completion**
3. **Note the LoadBalancerURL from outputs**

**Step 2: Verify the Problem**
1. **Try accessing the LoadBalancerURL**
2. **Confirm it's not working**
3. **Check if you can access instances directly** (if you find the public IP)

**Step 3: Investigate Target Group Health**
1. **Navigate to EC2 → Target Groups**
2. **Click on your workshop target group**
3. **Go to the "Targets" tab**
4. **Check the health status** (should show "unhealthy")
5. **Click on a target** to see health check details
6. **Note the health check failures**

**Step 4: Investigate Health Check Configuration**
1. **Stay in the target group**
2. **Go to the "Health checks" tab**
3. **Review the health check settings:**
   - **Health check path:** `/health-check`
   - **Health check port:** `80`
   - **Protocol:** `HTTP`

**Step 5: Test Health Check Endpoint**
1. **Find an instance public IP** (EC2 → Instances)
2. **Test the health check endpoint:**
   ```bash
   curl http://[INSTANCE-IP]/health-check
   ```
3. **Note the response** (should work)

**Step 6: Identify the Issue**
- **Health Check Port:** Target group checks port 80
- **Actual Endpoint:** Health check endpoint is on port 8080
- **Mismatch:** Health checks fail because they're checking the wrong port

**Step 7: Fix Target Group Configuration**
1. **Select the target group**
2. **Go to "Health checks" tab**
3. **Click "Edit health check settings"**
4. **Change the health check port** from `80` to `8080`
5. **Save changes**

**Step 8: Test the Fix**
1. **Wait 2-3 minutes** for health checks to pass
2. **Check target health** in the target group
3. **Verify targets show as healthy**
4. **Try accessing the LoadBalancerURL**
5. **Confirm application loads successfully**

### Learning Points

- **Health Check Configuration:** Must match actual application setup
- **Port Mismatches:** Common cause of health check failures
- **Health Check Process:** ALB performs health checks before routing traffic
- **Target Group Settings:** Independent of load balancer listener settings

### Expected Results

- ✅ Target group health check port corrected to 8080
- ✅ Targets show as healthy
- ✅ Application accessible via load balancer
- ✅ Understanding of health check troubleshooting

---

## Challenge 5: Blue-Green Deployment

### Objective

Deploy and demonstrate blue-green deployment strategy for zero-downtime deployments.

**Time Estimate:** 45 minutes

### Problem Description

This is a demonstration challenge showing how to implement blue-green deployments using AWS load balancers.

**Scenario:**
- **Blue Version:** Current production application (v1.0)
- **Green Version:** New application version (v2.0) with enhanced features
- **Goal:** Switch traffic from Blue to Green without downtime

### Deployment Steps

**Step 1: Deploy Blue Version**
1. **Deploy the blue-green template with blue version:**
   - Stack name: `[YourName]-blue-version`
   - Use the `blue-green-deployment.yaml` template
   - Parameter: `DeploymentVersion: blue`
2. **Wait for deployment completion**
3. **Note the ApplicationURL from outputs**

**Step 2: Verify Blue Version**
1. **Access the ApplicationURL**
2. **Verify you see the Blue Version** (blue theme, v1.0 features)
3. **Note the current features** listed on the page
4. **Check the deployment status** (should show 100% traffic to Blue)

**Step 3: Deploy Green Version**
1. **Deploy the blue-green template with green version:**
   - Stack name: `[YourName]-green-version`
   - Use the same `blue-green-deployment.yaml` template
   - Parameter: `DeploymentVersion: green`
2. **Wait for deployment completion**
3. **Note the ApplicationURL from outputs**

**Step 4: Verify Green Version**
1. **Access the Green Version URL**
2. **Verify you see the Green Version** (green theme, v2.0 features)
3. **Note the new features** (Advanced Analytics, Real-time Chat, etc.)
4. **Check the deployment status** (should show 0% traffic to Green)

**Step 5: Switch Traffic to Green**
1. **Navigate to EC2 → Load Balancers**
2. **Click on your load balancer**
3. **Go to the "Listeners" tab**
4. **Click on the HTTP listener**
5. **Click "Edit"**
6. **Change the default action** from Blue target group to Green target group
7. **Save changes**

**Step 6: Verify Traffic Switch**
1. **Wait 1-2 minutes** for changes to take effect
2. **Access the original Blue Version URL**
3. **Verify you now see the Green Version** (traffic has switched)
4. **Confirm all new features are available**

**Step 7: Demonstrate Rollback**
1. **Switch traffic back to Blue** using the same process
2. **Access the URL again**
3. **Verify you see the Blue Version** (rollback successful)

### Learning Points

- **Blue-Green Deployment:** Maintains two identical environments
- **Traffic Switching:** Load balancer routes traffic between environments
- **Zero Downtime:** Users don't experience service interruption
- **Rollback Capability:** Quick reversion if issues occur
- **Environment Isolation:** Blue and Green are completely separate

### Expected Results

- ✅ Both Blue and Green versions deployed successfully
- ✅ Traffic switching works without downtime
- ✅ Rollback capability demonstrated
- ✅ Understanding of blue-green deployment benefits

---

## Monitoring and Validation

### Objective

Use AWS CloudWatch to monitor application performance and validate all challenges are working correctly.

**Time Estimate:** 15 minutes

### CloudWatch Dashboard

**Step 1: Access CloudWatch**
1. **Navigate to CloudWatch** in the AWS console
2. **Go to "Dashboards"**
3. **Find your workshop dashboard** (should have your name)

**Step 2: Review Metrics**
1. **Load Balancer Metrics:**
   - Target response time
   - Request count
   - Error rates
2. **Database Metrics:**
   - CPU utilisation
   - Database connections
   - Storage usage

**Step 3: Check Logs**
1. **Go to CloudWatch → Log groups**
2. **Find your application log group**
3. **Review recent log entries**
4. **Look for any error messages**

### Application Health Validation

**Step 1: Test All Applications**
1. **Working Application:** Should be accessible and functional
2. **NACL Challenge:** Should be fixed and accessible
3. **Security Group Challenge:** Should work via load balancer
4. **IAM Challenge:** Should show all services accessible
5. **Load Balancer Challenge:** Should work via load balancer
6. **Blue-Green Demo:** Should show current version correctly

**Step 2: Document Results**
1. **Create a summary** of each challenge
2. **Note any issues** encountered
3. **Document solutions** applied
4. **Record learning outcomes**

---

## Cleanup and Cost Management

### Objective

Clean up all resources to avoid ongoing charges and understand AWS cost management.

**Time Estimate:** 10 minutes

### Resource Cleanup

**Step 1: Delete CloudFormation Stacks**
1. **Go to CloudFormation**
2. **Select each stack** you created
3. **Click "Delete"**
4. **Confirm deletion**
5. **Wait for stacks to be deleted**

**Step 2: Verify Cleanup**
1. **Check EC2 → Instances** (should be empty)
2. **Check VPC → VPCs** (should be empty)
3. **Check S3 → Buckets** (should be empty)
4. **Check IAM → Roles** (custom roles should be deleted)

### Cost Management Learning

**Key Concepts:**
- **Pay-as-you-go:** Only pay for resources you use
- **Resource Tagging:** Helps track costs by project
- **Budget Alerts:** Notify when costs exceed limits
- **Service Limits:** Prevent accidental large deployments

**Best Practices:**
- Always clean up resources after testing
- Use appropriate instance types for the workload
- Monitor costs regularly
- Set up billing alerts

---

## Workshop Summary

### Learning Outcomes

By completing this workshop, you should have gained:

**Technical Skills:**
- ✅ AWS console navigation and service understanding
- ✅ CloudFormation template deployment and management
- ✅ Network troubleshooting (NACLs, Security Groups)
- ✅ IAM role and policy management
- ✅ Load balancer configuration and health checks
- ✅ Blue-green deployment implementation

**Problem-Solving Skills:**
- ✅ Systematic troubleshooting methodology
- ✅ AWS service relationship understanding
- ✅ Root cause analysis techniques
- ✅ Solution implementation and validation

**Professional Skills:**
- ✅ Infrastructure as Code concepts
- ✅ Cloud architecture understanding
- ✅ Cost management awareness
- ✅ Security best practices

### Next Steps

**Further Learning:**
- Explore additional AWS services
- Practice with more complex architectures
- Learn about containerisation (Docker, ECS, EKS)
- Study advanced networking concepts
- Understand monitoring and alerting

**Career Development:**
- Consider AWS certification paths
- Join AWS user groups and communities
- Contribute to open-source projects
- Build personal projects using AWS

### Feedback

Please provide feedback on:
- Workshop content and structure
- Challenge difficulty and clarity
- Learning outcomes achieved
- Suggestions for improvement

---

**Congratulations on completing the AWS Infrastructure Workshop! 🎉**

You've gained hands-on experience with real AWS services and troubleshooting scenarios that you'll encounter in your professional career. Keep practising and exploring AWS services to build your cloud expertise!
