# Lab Environment Setup Guide
## IT Infrastructure Workshop - University Apprenticeship Programme

---

## Overview

This guide outlines the recommended approach for setting up a lab environment that allows university apprentices to safely experiment with cloud infrastructure without incurring costs or security risks.

---

## Recommended Lab Environment Options

### Option 1: AWS Educate (Recommended)

**What is AWS Educate?**
- Free cloud computing education program
- Provides AWS credits for students
- No credit card required
- Educational resources included

**Setup Process:**
1. **Instructor Registration:**
   - Register as an educator at https://aws.amazon.com/education/awseducate/
   - Request classroom credits (typically $100-200 per student)
   - Set up course with student roster

2. **Student Onboarding:**
   - Students register with university email
   - Receive AWS credits (typically $75-100)
   - Access to AWS Console with limited permissions
   - 12-month access period

**Benefits:**
- ✅ No cost to students or institution
- ✅ Real AWS environment
- ✅ Educational support materials
- ✅ Built-in spending limits
- ✅ No credit card required

**Limitations:**
- ❌ Limited to educational use
- ❌ Some services may be restricted
- ❌ Requires instructor approval process

### Option 2: Shared AWS Account with IAM Users

**Setup Process:**
1. **Create Master Account:**
   - Set up AWS account with billing alerts
   - Configure IAM users for each student
   - Set up resource tagging for cost tracking

2. **IAM User Configuration:**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "ec2:*",
           "rds:*",
           "elbv2:*",
           "cloudwatch:*",
           "iam:PassRole"
         ],
         "Resource": "*",
         "Condition": {
           "StringEquals": {
             "aws:RequestedRegion": "us-west-2"
           }
         }
       }
     ]
   }
   ```

3. **Cost Management:**
   - Set up billing alerts at $10, $25, $50
   - Use resource tags for tracking
   - Automated cleanup scripts

**Benefits:**
- ✅ Full AWS access
- ✅ Real production environment
- ✅ Complete control over permissions
- ✅ Can be reused for multiple workshops

**Limitations:**
- ❌ Requires credit card
- ❌ Potential for unexpected costs
- ❌ More complex setup
- ❌ Security considerations

### Option 3: Local Development Environment

**Setup Process:**
1. **Docker Desktop:**
   - Install Docker Desktop
   - Use containers for application components
   - Local networking simulation

2. **LocalStack:**
   - AWS services simulation
   - No cloud costs
   - Limited service coverage

3. **Minikube:**
   - Local Kubernetes cluster
   - Container orchestration practice
   - No cloud dependencies

**Benefits:**
- ✅ No cloud costs
- ✅ No internet dependency
- ✅ Complete control
- ✅ Can work offline

**Limitations:**
- ❌ Not realistic cloud experience
- ❌ Limited scalability testing
- ❌ Missing cloud-specific features
- ❌ Setup complexity

---

## Recommended Approach: AWS Educate + Backup Plan

### Primary: AWS Educate Setup

**Pre-Workshop (2 weeks before):**
1. **Instructor Preparation:**
   ```bash
   # Create workshop preparation checklist
   - [ ] Register for AWS Educate educator account
   - [ ] Request classroom credits ($200 per student)
   - [ ] Create student roster with email addresses
   - [ ] Set up GitHub repository with workshop materials
   - [ ] Test lab exercises in personal AWS account
   - [ ] Prepare backup plan (shared account)
   ```

2. **Student Preparation:**
   ```bash
   # Student setup checklist
   - [ ] Register for AWS Educate with university email
   - [ ] Complete AWS Educate orientation
   - [ ] Access AWS Console and verify credits
   - [ ] Install required tools (Terraform, AWS CLI, Git)
   - [ ] Clone workshop repository
   - [ ] Complete pre-workshop survey
   ```

**Workshop Day Setup:**
1. **Environment Verification (15 minutes):**
   ```bash
   # Verification script for students
   #!/bin/bash
   echo "=== Workshop Environment Check ==="
   
   # Check AWS CLI
   aws --version
   aws sts get-caller-identity
   
   # Check Terraform
   terraform --version
   
   # Check Git
   git --version
   
   # Check AWS credits
   aws ce get-cost-and-usage --time-period Start=2024-10-01,End=2024-10-31 --granularity MONTHLY --metrics BlendedCost
   
   echo "=== Environment Check Complete ==="
   ```

2. **Resource Limits:**
   - Set up AWS Budgets with $50 limit per student
   - Configure CloudWatch billing alarms
   - Use t2.micro instances only
   - Single region (us-west-2)

### Backup Plan: Shared AWS Account

**If AWS Educate is unavailable:**
1. **Create Shared Account:**
   - Use company/organisation AWS account
   - Set up IAM users for each student
   - Configure strict spending limits

2. **Cost Management:**
   ```bash
   # Automated cleanup script
   #!/bin/bash
   # Run daily to clean up resources
   
   # Delete instances older than 24 hours
   aws ec2 describe-instances --query 'Reservations[*].Instances[?LaunchTime<`2024-10-02`].[InstanceId]' --output text | xargs -I {} aws ec2 terminate-instances --instance-ids {}
   
   # Delete unused security groups
   aws ec2 describe-security-groups --query 'SecurityGroups[?GroupName!=`default`].[GroupId]' --output text | xargs -I {} aws ec2 delete-security-group --group-id {}
   
   # Clean up unused volumes
   aws ec2 describe-volumes --query 'Volumes[?State==`available`].[VolumeId]' --output text | xargs -I {} aws ec2 delete-volume --volume-id {}
   ```

---

## Lab Environment Architecture

### Network Isolation
```
Student 1: 10.1.0.0/16
Student 2: 10.2.0.0/16
Student 3: 10.3.0.0/16
...
```

### Resource Naming Convention
```
{student-initials}-{environment}-{resource-type}
Example: jd-dev-web-server
```

### Tagging Strategy
```json
{
  "Workshop": "Infrastructure-2024",
  "Student": "john.doe",
  "Environment": "dev",
  "Owner": "john.doe@university.edu",
  "CostCenter": "Workshop-Infrastructure"
}
```

---

## Pre-Workshop Checklist

### For Instructors
- [ ] AWS Educate account approved
- [ ] Student roster confirmed
- [ ] Workshop materials tested
- [ ] Backup plan prepared
- [ ] Monitoring setup configured
- [ ] Cleanup procedures documented

### For Students
- [ ] AWS Educate account active
- [ ] Required tools installed
- [ ] Workshop repository cloned
- [ ] Pre-workshop reading completed
- [ ] Environment verification passed

---

## Post-Workshop Cleanup

### Automated Cleanup (Recommended)
```bash
#!/bin/bash
# Post-workshop cleanup script

echo "Starting workshop cleanup..."

# Get all resources with workshop tag
RESOURCES=$(aws resourcegroupstaggingapi get-resources --tag-filters Key=Workshop,Values=Infrastructure-2024 --query 'ResourceTagMappingList[*].ResourceARN' --output text)

for resource in $RESOURCES; do
    echo "Cleaning up: $resource"
    # Add specific cleanup logic based on resource type
done

echo "Cleanup complete!"
```

### Manual Cleanup Checklist
- [ ] Terminate all EC2 instances
- [ ] Delete RDS instances
- [ ] Remove load balancers
- [ ] Clean up security groups
- [ ] Delete unused volumes
- [ ] Remove IAM roles (if created)
- [ ] Clean up CloudWatch logs
- [ ] Verify billing dashboard

---

## Troubleshooting Guide

### Common Issues

**Issue: AWS Educate account not approved**
- **Solution:** Use backup shared account
- **Prevention:** Apply 2 weeks in advance

**Issue: Student can't access AWS Console**
- **Solution:** Check email verification, reset password
- **Prevention:** Send setup instructions 1 week early

**Issue: Terraform authentication errors**
- **Solution:** Reconfigure AWS credentials
- **Prevention:** Include credential setup in pre-workshop

**Issue: Unexpected costs**
- **Solution:** Immediate resource termination
- **Prevention:** Strict budgets and monitoring

### Support Contacts
- **AWS Educate Support:** aws-educate-support@amazon.com
- **Technical Issues:** [Your Email]
- **Workshop Coordinator:** [Coordinator Email]

---

## Cost Estimation

### Per Student Costs (AWS Educate)
- **EC2 Instances:** $0 (t2.micro free tier)
- **RDS Instance:** ~$15/month (db.t3.micro)
- **Load Balancer:** ~$18/month
- **Data Transfer:** ~$5/month
- **Total Estimated:** ~$38/month per student

### Workshop Total (20 students)
- **Estimated Cost:** $760/month
- **AWS Educate Credits:** $2,000 (covers workshop + practice)
- **Net Cost:** $0

---

## Security Considerations

### Data Protection
- No real user data in lab environment
- Use synthetic test data only
- Encrypt all data at rest and in transit
- Regular security group reviews

### Access Control
- Principle of least privilege
- Time-limited access (workshop duration)
- Regular access reviews
- Audit logging enabled

### Compliance
- Follow university data protection policies
- Document all data handling procedures
- Regular security assessments
- Incident response procedures

---

## Success Metrics

### Workshop Completion
- [ ] 90% of students complete all labs
- [ ] Average lab completion time < 2.5 hours
- [ ] < 5% technical issues requiring intervention
- [ ] Student satisfaction score > 4.0/5.0

### Learning Outcomes
- [ ] Students can deploy basic infrastructure
- [ ] Students understand IaC concepts
- [ ] Students can explain 3-tier architecture
- [ ] Students demonstrate security awareness

---

## Next Steps

1. **Choose Environment Option:** AWS Educate (recommended)
2. **Set Up Accounts:** 2 weeks before workshop
3. **Test Lab Exercises:** 1 week before workshop
4. **Prepare Students:** Send setup instructions
5. **Conduct Workshop:** Follow lab guide
6. **Clean Up Resources:** Post-workshop
7. **Gather Feedback:** Improve for next time

---

## Resources

- **AWS Educate:** https://aws.amazon.com/education/awseducate/
- **Terraform Documentation:** https://terraform.io/docs
- **AWS Free Tier:** https://aws.amazon.com/free/
- **Workshop Repository:** [GitHub URL]
- **Support Documentation:** [Internal Wiki URL]
