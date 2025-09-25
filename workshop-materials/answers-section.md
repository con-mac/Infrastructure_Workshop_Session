# AWS Infrastructure Workshop - Answers Section
## Solutions and Explanations for All Challenges

---

## Table of Contents

1. [Challenge 1: NACL Misconfiguration](#challenge-1-nacl-misconfiguration)
2. [Challenge 2: Security Group Issues](#challenge-2-security-group-issues)
3. [Challenge 3: IAM Permission Problems](#challenge-3-iam-permission-problems)
4. [Challenge 4: Load Balancer Configuration](#challenge-4-load-balancer-configuration)
5. [Challenge 5: Blue-Green Deployment](#challenge-5-blue-green-deployment)
6. [Instructor Notes and Tips](#instructor-notes-and-tips)
7. [Common Troubleshooting Scenarios](#common-troubleshooting-scenarios)
8. [Best Practices Summary](#best-practices-summary)

---

## Challenge 1: NACL Misconfiguration

### Problem Summary
**Issue:** Network ACL rules are blocking inbound HTTP traffic, preventing the application from being accessible from the internet.

**Root Cause:** NACL rules 100 and 110 explicitly deny TCP traffic on ports 80 and 443.

### Solution Steps

#### Step 1: Identify the Problem
1. **Access the application URL** - Should fail with connection timeout
2. **Check EC2 instance status** - Should show as running
3. **Verify Security Groups** - Should be correctly configured
4. **Examine Network ACLs** - Find the problematic rules

#### Step 2: Locate the Misconfigured NACL
1. **Navigate to VPC → Network ACLs**
2. **Find the workshop NACL** (tagged with student name)
3. **Review the Inbound rules tab**
4. **Identify problematic rules:**
   - Rule 100: Deny TCP port 80 (HTTP)
   - Rule 110: Deny TCP port 443 (HTTPS)

#### Step 3: Fix the NACL Rules
1. **Select the problematic NACL**
2. **Go to "Inbound rules" tab**
3. **Click "Edit inbound rules"**
4. **Delete the deny rules:**
   - Remove Rule 100 (Deny TCP port 80)
   - Remove Rule 110 (Deny TCP port 443)
5. **Save changes**

#### Step 4: Verify the Fix
1. **Wait 1-2 minutes** for changes to propagate
2. **Test application access** - Should now work
3. **Confirm application loads** with proper content

### Technical Explanation

**NACL vs Security Groups:**
- **Network ACLs:** Operate at subnet level, stateless, evaluated in order
- **Security Groups:** Operate at instance level, stateful, all rules evaluated

**Rule Evaluation:**
- NACLs evaluate rules in numerical order (lowest to highest)
- First matching rule wins
- Default rules (32767) allow all traffic if no explicit deny

**Why This Happens:**
- Misconfigured NACL rules can override Security Group permissions
- Common mistake when setting up restrictive network policies
- NACLs are stateless, so outbound responses need explicit rules

### Learning Outcomes
- Understanding of AWS networking layers
- NACL troubleshooting methodology
- Difference between NACLs and Security Groups
- Network troubleshooting best practices

---

## Challenge 2: Security Group Issues

### Problem Summary
**Issue:** Load balancer health checks are failing because the web tier security group doesn't allow traffic from the load balancer security group.

**Root Cause:** Security group rule only allows traffic from CIDR range `10.0.0.0/16`, but ALB health checks come from the ALB's security group.

### Solution Steps

#### Step 1: Identify the Problem
1. **Access LoadBalancerURL** - Should fail or timeout
2. **Check target group health** - Should show unhealthy targets
3. **Verify direct instance access** - Should work (if you can find the IP)

#### Step 2: Investigate Load Balancer Health
1. **Navigate to EC2 → Load Balancers**
2. **Click on workshop load balancer**
3. **Go to "Target groups" tab**
4. **Click on target group**
5. **Check "Targets" tab** - Should show unhealthy status

#### Step 3: Examine Security Groups
1. **Navigate to EC2 → Security Groups**
2. **Find web tier security group** (tagged with "web-sg")
3. **Review inbound rules**
4. **Identify the issue:**
   - HTTP rule allows `10.0.0.0/16` CIDR
   - Missing rule for ALB security group

#### Step 4: Fix the Security Group
1. **Select web tier security group**
2. **Go to "Inbound rules" tab**
3. **Click "Edit inbound rules"**
4. **Add new rule:**
   - **Type:** HTTP
   - **Source:** Load balancer security group (select from dropdown)
   - **Description:** "Allow ALB health checks"
5. **Save changes**

#### Step 5: Verify the Fix
1. **Wait 2-3 minutes** for health checks to pass
2. **Check target group health** - Should show healthy
3. **Test LoadBalancerURL** - Should now work

### Technical Explanation

**Load Balancer Health Checks:**
- ALB performs health checks on targets before routing traffic
- Health checks come from ALB's own security group
- Targets must allow health check traffic to be marked healthy

**Security Group References:**
- Security groups can reference other security groups as sources
- More secure than using IP addresses
- Automatically handles IP changes

**Health Check Process:**
1. ALB sends health check requests to targets
2. Targets respond with health status
3. ALB marks targets as healthy/unhealthy
4. Traffic only routes to healthy targets

### Learning Outcomes
- Understanding of load balancer health checks
- Security group source references
- ALB troubleshooting methodology
- Health check configuration best practices

---

## Challenge 3: IAM Permission Problems

### Problem Summary
**Issue:** EC2 instance role lacks permissions to access S3 and CloudWatch Logs, causing application failures.

**Root Cause:** EC2 instance role has no attached policies, preventing access to required AWS services.

### Solution Steps

#### Step 1: Identify the Problem
1. **Access the application URL**
2. **Look for permission error messages**
3. **Check service access status** on the page
4. **Note which services are failing** (S3, CloudWatch Logs)

#### Step 2: Investigate IAM Role
1. **Navigate to IAM → Roles**
2. **Find EC2 instance role** (tagged with student name and "ec2-role")
3. **Click on the role name**
4. **Review "Permissions" tab**
5. **Identify missing policies**

#### Step 3: Add Required Managed Policies
1. **Select the EC2 instance role**
2. **Go to "Permissions" tab**
3. **Click "Attach policies"**
4. **Add these managed policies:**
   - `CloudWatchAgentServerPolicy`
   - `AmazonS3ReadOnlyAccess`
5. **Click "Attach policies"**

#### Step 4: Create Custom S3 Policy
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
4. **Replace `your-bucket-name`** with actual bucket name from CloudFormation outputs
5. **Name the policy:** `[StudentName]-S3Access`
6. **Create the policy**

#### Step 5: Attach Custom Policy
1. **Go back to EC2 instance role**
2. **Attach the custom S3 policy**
3. **Save changes**

#### Step 6: Verify the Fix
1. **Wait 1-2 minutes** for policy changes to take effect
2. **Refresh the application page**
3. **Check service access status** - Should show "Success" for all services

### Technical Explanation

**IAM Roles vs Users:**
- **Roles:** For AWS services (EC2, Lambda, etc.)
- **Users:** For people and applications
- **Instance Profiles:** Connect EC2 instances to IAM roles

**Policy Types:**
- **Managed Policies:** AWS-provided, reusable policies
- **Custom Policies:** User-created, specific to needs
- **Inline Policies:** Embedded directly in roles/users

**Least Privilege Principle:**
- Grant only necessary permissions
- Regular review and cleanup
- Use specific resource ARNs when possible

### Learning Outcomes
- Understanding of IAM roles and policies
- EC2 instance profile configuration
- Policy troubleshooting methodology
- AWS service permission requirements

---

## Challenge 4: Load Balancer Configuration

### Problem Summary
**Issue:** Load balancer target group health check is configured for port 80, but the health check endpoint is actually on port 8080.

**Root Cause:** Mismatch between health check port configuration and actual application setup.

### Solution Steps

#### Step 1: Identify the Problem
1. **Access LoadBalancerURL** - Should fail
2. **Check target group health** - Should show unhealthy targets
3. **Verify direct instance access** - Should work

#### Step 2: Investigate Target Group Health
1. **Navigate to EC2 → Target Groups**
2. **Click on workshop target group**
3. **Go to "Targets" tab**
4. **Check health status** - Should show unhealthy
5. **Click on a target** to see health check details

#### Step 3: Review Health Check Configuration
1. **Stay in target group**
2. **Go to "Health checks" tab**
3. **Review settings:**
   - Health check path: `/health-check`
   - Health check port: `80` (incorrect)
   - Protocol: `HTTP`

#### Step 4: Test Health Check Endpoint
1. **Find instance public IP** (EC2 → Instances)
2. **Test the health check endpoint:**
   ```bash
   curl http://[INSTANCE-IP]/health-check
   ```
3. **Should work** - confirms endpoint exists

#### Step 5: Fix Target Group Configuration
1. **Select the target group**
2. **Go to "Health checks" tab**
3. **Click "Edit health check settings"**
4. **Change health check port** from `80` to `8080`
5. **Save changes**

#### Step 6: Verify the Fix
1. **Wait 2-3 minutes** for health checks to pass
2. **Check target health** - Should show healthy
3. **Test LoadBalancerURL** - Should now work

### Technical Explanation

**Health Check Configuration:**
- Must match actual application setup
- Port, path, and protocol must be correct
- Timeout and interval settings affect responsiveness

**Application Setup:**
- Main application runs on port 80
- Health check endpoint runs on port 8080
- Apache configured with virtual hosts

**Health Check Process:**
1. ALB sends requests to health check port/path
2. Application responds with status
3. ALB evaluates response and marks target healthy/unhealthy
4. Only healthy targets receive traffic

### Learning Outcomes
- Understanding of load balancer health checks
- Application architecture troubleshooting
- Health check configuration best practices
- Port and service configuration alignment

---

## Challenge 5: Blue-Green Deployment

### Problem Summary
**Objective:** Demonstrate zero-downtime deployment strategy by switching traffic between Blue (v1.0) and Green (v2.0) application versions.

### Solution Steps

#### Step 1: Deploy Blue Version
1. **Deploy blue-green template with blue version:**
   - Stack name: `[StudentName]-blue-version`
   - Parameter: `DeploymentVersion: blue`
2. **Wait for deployment completion**
3. **Access ApplicationURL**
4. **Verify Blue Version** (blue theme, v1.0 features)

#### Step 2: Deploy Green Version
1. **Deploy blue-green template with green version:**
   - Stack name: `[StudentName]-green-version`
   - Parameter: `DeploymentVersion: green`
2. **Wait for deployment completion**
3. **Access Green Version URL**
4. **Verify Green Version** (green theme, v2.0 features)

#### Step 3: Switch Traffic to Green
1. **Navigate to EC2 → Load Balancers**
2. **Click on workshop load balancer**
3. **Go to "Listeners" tab**
4. **Click on HTTP listener**
5. **Click "Edit"**
6. **Change default action** from Blue target group to Green target group
7. **Save changes**

#### Step 4: Verify Traffic Switch
1. **Wait 1-2 minutes** for changes to take effect
2. **Access original Blue Version URL**
3. **Verify you now see Green Version**
4. **Confirm new features are available**

#### Step 5: Demonstrate Rollback
1. **Switch traffic back to Blue** using same process
2. **Access the URL again**
3. **Verify you see Blue Version**
4. **Confirm rollback successful**

### Technical Explanation

**Blue-Green Deployment Strategy:**
- **Blue:** Current production environment
- **Green:** New version environment
- **Traffic Switch:** Load balancer routes traffic between environments
- **Zero Downtime:** Users don't experience service interruption

**Load Balancer Configuration:**
- Two separate target groups (blue and green)
- Listener rules control traffic routing
- Instant switching between target groups

**Benefits:**
- **Zero Downtime:** No service interruption during deployment
- **Quick Rollback:** Instant reversion if issues occur
- **Environment Isolation:** Complete separation between versions
- **Risk Mitigation:** Test new version before switching traffic

### Learning Outcomes
- Understanding of deployment strategies
- Load balancer traffic management
- Blue-green deployment implementation
- Zero-downtime deployment concepts

---

## Instructor Notes and Tips

### Pre-Workshop Preparation

#### 1. Test All Challenges
- **Deploy each template** and verify issues exist
- **Test solutions** to ensure they work
- **Document any variations** in your environment
- **Prepare backup solutions** for common issues

#### 2. Student Account Setup
- **Test account creation** process thoroughly
- **Verify email delivery** works correctly
- **Check budget alerts** are functioning
- **Prepare manual account creation** as backup

#### 3. Environment Validation
- **Verify service limits** are sufficient
- **Test cost monitoring** and alerts
- **Check cleanup procedures** work correctly
- **Prepare troubleshooting guides** for common issues

### During Workshop

#### 1. Challenge Introduction
- **Explain the scenario** clearly
- **Set expectations** for troubleshooting time
- **Provide hints** without giving away solutions
- **Encourage collaboration** between students

#### 2. Troubleshooting Guidance
- **Ask leading questions** to guide thinking
- **Help students understand** the troubleshooting process
- **Encourage systematic** problem-solving approach
- **Celebrate successes** and learning moments

#### 3. Technical Support
- **Monitor student progress** and provide hints
- **Help with AWS console** navigation
- **Assist with technical** issues
- **Ensure all students** complete challenges

### Common Student Questions

#### Q: "My stack failed to deploy"
**A:** Check the Events tab in CloudFormation for specific error messages. Common issues include parameter validation, resource limits, or template syntax errors.

#### Q: "I can't find the resource you mentioned"
**A:** Use the AWS console search function and check resource tags. All workshop resources should be tagged with your name and "Workshop: Infrastructure-2024".

#### Q: "The application still doesn't work after my fix"
**A:** Wait 2-3 minutes for changes to propagate, then test again. Some AWS changes take time to take effect.

#### Q: "I'm getting permission errors"
**A:** Check your IAM role permissions and ensure you're using the correct AWS account. Each student has their own isolated account.

### Assessment Criteria

#### Technical Skills (70%)
- **Troubleshooting Methodology:** Systematic approach to problem-solving
- **AWS Console Navigation:** Ability to find and use AWS services
- **Solution Implementation:** Correctly applying fixes
- **Understanding:** Explaining what was wrong and why the fix works

#### Problem-Solving Skills (20%)
- **Root Cause Analysis:** Identifying the actual problem
- **Critical Thinking:** Logical reasoning through issues
- **Persistence:** Continuing to work through challenges
- **Documentation:** Recording troubleshooting process

#### Professional Skills (10%)
- **Communication:** Explaining issues and solutions clearly
- **Collaboration:** Working with other students
- **Time Management:** Completing challenges within time limits
- **Learning Attitude:** Asking questions and seeking help when needed

---

## Common Troubleshooting Scenarios

### Scenario 1: CloudFormation Stack Fails

**Symptoms:**
- Stack shows "CREATE_FAILED" status
- Error messages in Events tab
- Resources not created

**Common Causes:**
1. **Parameter validation errors**
2. **Resource limit exceeded**
3. **Template syntax errors**
4. **Service unavailability**

**Solutions:**
1. **Check Events tab** for specific error messages
2. **Validate parameters** match requirements
3. **Check service limits** in AWS console
4. **Contact instructor** for template issues

### Scenario 2: Application Not Accessible

**Symptoms:**
- URL returns connection timeout
- Browser shows "This site can't be reached"
- Load balancer shows unhealthy targets

**Troubleshooting Steps:**
1. **Check EC2 instance status** - should be running
2. **Verify Security Group rules** - allow HTTP traffic
3. **Check Network ACL rules** - not blocking traffic
4. **Test direct instance access** - if you can find the IP
5. **Check load balancer health** - if using ALB

### Scenario 3: Permission Denied Errors

**Symptoms:**
- IAM permission errors in application
- Cannot access AWS services
- Access denied messages

**Troubleshooting Steps:**
1. **Check IAM role permissions** - ensure policies are attached
2. **Verify resource ARNs** - in custom policies
3. **Check service availability** - ensure services are enabled
4. **Review policy syntax** - for custom policies

### Scenario 4: Load Balancer Health Check Failures

**Symptoms:**
- Targets show as unhealthy
- Load balancer not routing traffic
- Application not accessible via ALB

**Troubleshooting Steps:**
1. **Check health check configuration** - port, path, protocol
2. **Verify application setup** - health endpoint exists
3. **Check Security Group rules** - allow ALB health checks
4. **Test health endpoint directly** - using curl or browser

---

## Best Practices Summary

### Security Best Practices

#### 1. Network Security
- **Use Security Groups** for instance-level access control
- **Use NACLs sparingly** and test thoroughly
- **Reference Security Groups** instead of IP addresses
- **Regular review** of network rules

#### 2. Access Management
- **Follow least privilege** principle
- **Use IAM roles** for EC2 instances
- **Regular permission review** and cleanup
- **Monitor access logs** for anomalies

#### 3. Resource Management
- **Tag all resources** for cost tracking
- **Set up budgets** and alerts
- **Regular cleanup** of unused resources
- **Monitor costs** regularly

### Operational Best Practices

#### 1. Monitoring and Logging
- **Enable CloudWatch** for all resources
- **Set up alerts** for critical issues
- **Monitor costs** and usage
- **Review logs** regularly

#### 2. Backup and Recovery
- **Enable automated backups** for databases
- **Test restore procedures** regularly
- **Document recovery** processes
- **Plan for disaster recovery**

#### 3. Change Management
- **Use Infrastructure as Code** (CloudFormation)
- **Test changes** in non-production first
- **Document all changes**
- **Use version control** for templates

### Cost Optimization

#### 1. Resource Right-Sizing
- **Use appropriate instance types** for workload
- **Monitor resource utilisation**
- **Scale down** unused resources
- **Use spot instances** where appropriate

#### 2. Storage Optimization
- **Use appropriate storage classes**
- **Implement lifecycle policies**
- **Regular cleanup** of unused data
- **Monitor storage costs**

#### 3. Network Optimization
- **Use appropriate bandwidth** for needs
- **Monitor data transfer** costs
- **Optimise data transfer** patterns
- **Use CloudFront** for static content

---

## Conclusion

This answers section provides comprehensive solutions and explanations for all workshop challenges. The key learning outcomes include:

### Technical Skills
- **AWS Console Navigation:** Finding and using AWS services effectively
- **Troubleshooting Methodology:** Systematic approach to problem-solving
- **Service Configuration:** Understanding and fixing AWS service settings
- **Architecture Understanding:** How AWS services work together

### Problem-Solving Skills
- **Root Cause Analysis:** Identifying the actual problem
- **Critical Thinking:** Logical reasoning through complex issues
- **Persistence:** Working through challenges systematically
- **Documentation:** Recording and explaining solutions

### Professional Skills
- **Communication:** Explaining technical concepts clearly
- **Collaboration:** Working effectively with others
- **Time Management:** Completing tasks within deadlines
- **Continuous Learning:** Seeking knowledge and improvement

### Real-World Application
These challenges simulate common issues encountered in production AWS environments. The troubleshooting skills and AWS knowledge gained will directly apply to professional cloud engineering roles.

**Remember:** The goal is not just to fix the immediate problem, but to understand why it happened and how to prevent similar issues in the future. This systematic approach to troubleshooting is valuable in any technical role.

---

**Congratulations on completing the AWS Infrastructure Workshop! 🎉**

You now have hands-on experience with real AWS troubleshooting scenarios and the knowledge to handle similar challenges in your professional career.
