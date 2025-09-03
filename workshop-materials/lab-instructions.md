# IT Infrastructure Workshop - Lab Instructions
## University Apprenticeship Programme
### Friday 3rd October, 12:00–16:30

---

## Lab Overview

**Duration:** 2.5 hours  
**Format:** Hands-on practical exercises  
**Prerequisites:** Basic command line knowledge, web browser access  
**Objective:** Deploy a 3-tier web application using Infrastructure as Code  

### Learning Outcomes
By the end of this lab, you will be able to:
- Deploy infrastructure using Terraform
- Understand 3-tier architecture components
- Configure security groups and networking
- Set up monitoring and health checks
- Deploy to multiple environments
- Integrate with CI/CD workflows

---

## Pre-Lab Setup (15 minutes)

### Step 1: Access Your Environment

**Option A: AWS Educate (Recommended)**
1. Navigate to: `https://awseducate.com`
2. Login with your university email
3. Access AWS Console
4. Verify you have credits available

**Option B: Shared AWS Account**
1. Login with provided credentials
2. Access AWS Console
3. Verify permissions

### Step 2: Install Required Tools

**Check if tools are already installed:**
```bash
# Check Terraform
terraform --version
# Expected: Terraform v1.5+

# Check AWS CLI
aws --version
# Expected: aws-cli/2.0+

# Check Git
git --version
# Expected: git version 2.30+
```

**If tools are missing, install them:**
```bash
# Install Terraform (Linux/Mac)
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Install AWS CLI (Linux/Mac)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Step 3: Configure AWS Credentials

```bash
# Configure AWS CLI
aws configure
# Enter your access key, secret key, region (us-west-2), and output format (json)

# Test configuration
aws sts get-caller-identity
# Should return your AWS account information
```

### Step 4: Clone Workshop Repository

```bash
# Clone the repository
git clone https://github.com/[workshop-repo]/infrastructure-workshop.git
cd infrastructure-workshop

# Verify files
ls -la
# Should see: terraform/, sample-app/, .github/, etc.
```

---

## Lab 1: Infrastructure as Code Basics (30 minutes)

### Objective
Learn Terraform fundamentals and deploy your first infrastructure components.

### Step 1: Explore Terraform Configuration

```bash
# Navigate to Terraform directory
cd terraform

# List files
ls -la
# You should see: main.tf, variables.tf, outputs.tf, dev.tfvars, prod.tfvars
```

### Step 2: Understand the Configuration

**Open `main.tf` and examine the structure:**
- Provider configuration
- Data sources for AMIs and availability zones
- Resource definitions with TODO comments

**Open `variables.tf` and understand:**
- Variable definitions and validation rules
- Default values
- Input requirements

### Step 3: Complete Your First Infrastructure

**Task 1: Create a VPC**
In `main.tf`, find the VPC resource and complete it:

```hcl
resource "aws_vpc" "main" {
  cidr_block           = "___"  # TODO: Use 10.0.0.0/16
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.student_name}-${var.environment}-vpc"
  }
}
```

**Task 2: Create Internet Gateway**
Complete the Internet Gateway resource:

```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.student_name}-${var.environment}-igw"
  }
}
```

**Task 3: Create Public Subnet**
Complete the public subnet:

```hcl
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "___"  # TODO: Use 10.0.1.0/24
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.student_name}-${var.environment}-public-subnet"
    Type = "Public"
  }
}
```

### Step 4: Initialize and Plan

```bash
# Initialize Terraform
terraform init

# Create your personal variables file
cp dev.tfvars student.tfvars

# Edit student.tfvars with your information
nano student.tfvars
# Update: student_name, student_email

# Plan your deployment
terraform plan -var-file="student.tfvars"
```

**Expected Output:**
- Plan should show resources to be created
- No errors should be present
- Review the plan carefully

### Step 5: Deploy Your First Resources

```bash
# Apply the configuration
terraform apply -var-file="student.tfvars"

# Type 'yes' when prompted
# Wait for resources to be created
```

**Verification:**
```bash
# Check what was created
terraform show

# Get outputs
terraform output
```

---

## Lab 2: Deploy 3-Tier Architecture (60 minutes)

### Objective
Deploy a complete 3-tier web application architecture with all components.

### Step 1: Complete Security Groups

**Task 4: Web Tier Security Group**
Complete the web security group to allow HTTP and HTTPS traffic:

```hcl
resource "aws_security_group" "web" {
  name_prefix = "${var.student_name}-web-"
  vpc_id      = aws_vpc.main.id

  # TODO: Add HTTP ingress rule (port 80)
  ingress {
    from_port   = ___  # TODO: Fill in port number
    to_port     = ___  # TODO: Fill in port number
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access from internet"
  }

  # TODO: Add HTTPS ingress rule (port 443)
  ingress {
    from_port   = ___  # TODO: Fill in port number
    to_port     = ___  # TODO: Fill in port number
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.student_name}-${var.environment}-web-sg"
  }
}
```

**Task 5: App Tier Security Group**
Complete the app security group to allow traffic from web tier:

```hcl
resource "aws_security_group" "app" {
  name_prefix = "${var.student_name}-app-"
  vpc_id      = aws_vpc.main.id

  # TODO: Add ingress rule for app traffic from web tier (port 8080)
  ingress {
    from_port       = ___  # TODO: Fill in port number
    to_port         = ___  # TODO: Fill in port number
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]  # TODO: Reference web security group
    description     = "App traffic from web tier"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.student_name}-${var.environment}-app-sg"
  }
}
```

**Task 6: Database Tier Security Group**
Complete the database security group:

```hcl
resource "aws_security_group" "db" {
  name_prefix = "${var.student_name}-db-"
  vpc_id      = aws_vpc.main.id

  # TODO: Add ingress rule for MySQL from app tier (port 3306)
  ingress {
    from_port       = ___  # TODO: Fill in port number
    to_port         = ___  # TODO: Fill in port number
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]  # TODO: Reference app security group
    description     = "MySQL access from app tier"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.student_name}-${var.environment}-db-sg"
  }
}
```

### Step 2: Complete Load Balancer Configuration

**Task 7: Application Load Balancer**
The ALB is already configured, but verify the configuration:

```hcl
resource "aws_lb" "web" {
  name               = "${var.student_name}-${var.environment}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets            = [aws_subnet.public.id]

  enable_deletion_protection = false

  tags = {
    Name = "${var.student_name}-${var.environment}-web-alb"
  }
}
```

**Task 8: Target Group Health Check**
Verify the target group configuration:

```hcl
resource "aws_lb_target_group" "web" {
  name     = "${var.student_name}-${var.environment}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"  # TODO: Update to your health check path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.student_name}-${var.environment}-web-tg"
  }
}
```

### Step 3: Complete Database Configuration

**Task 9: RDS Subnet Group**
Complete the RDS subnet group:

```hcl
resource "aws_db_subnet_group" "main" {
  name       = "${var.student_name}-${var.environment}-db-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.public.id]

  tags = {
    Name = "${var.student_name}-${var.environment}-db-subnet-group"
  }
}
```

**Task 10: RDS Instance**
Complete the RDS instance configuration:

```hcl
resource "aws_db_instance" "main" {
  identifier = "${var.student_name}-${var.environment}-db"
  
  # TODO: Set engine (Hint: Use "mysql")
  engine = "___"
  
  # TODO: Set engine version (Hint: Use "8.0")
  engine_version = "___"
  
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = "workshopdb"
  username = "admin"
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.student_name}-${var.environment}-db"
  }
}
```

### Step 4: Deploy the Complete Architecture

```bash
# Plan the complete deployment
terraform plan -var-file="student.tfvars"

# Review the plan carefully
# You should see: VPC, subnets, security groups, load balancer, RDS, etc.

# Apply the configuration
terraform apply -var-file="student.tfvars"

# Type 'yes' when prompted
# This will take 5-10 minutes to complete
```

### Step 5: Verify Your Deployment

```bash
# Get the application URL
terraform output application_url

# Test the application
curl $(terraform output -raw application_url)

# Check health endpoint
curl $(terraform output -raw application_url)/health

# Get all outputs
terraform output
```

**Expected Results:**
- Application should be accessible via load balancer
- Health check should return HTTP 200
- All resources should be in healthy state

---

## Lab 3: Multi-Environment Deployment (45 minutes)

### Objective
Deploy the same infrastructure to multiple environments with different configurations.

### Step 1: Understand Environment Strategy

**Environment Differences:**
- **Dev:** Small instances, minimal resources, auto-shutdown
- **Staging:** Medium instances, production-like, extended monitoring
- **Prod:** Larger instances, high availability, comprehensive monitoring

### Step 2: Deploy to Development Environment

```bash
# Ensure you're in the terraform directory
cd terraform

# Deploy to dev environment
terraform apply -var-file="dev.tfvars"

# Verify deployment
terraform output
```

### Step 3: Deploy to Production Environment

```bash
# Deploy to prod environment
terraform apply -var-file="prod.tfvars"

# Compare with dev deployment
terraform output
```

### Step 4: Use Terraform Workspaces

```bash
# Create workspace for dev
terraform workspace new dev

# Create workspace for prod
terraform workspace new prod

# Switch between workspaces
terraform workspace select dev
terraform workspace select prod

# List all workspaces
terraform workspace list
```

### Step 5: Compare Environments

```bash
# Switch to dev workspace
terraform workspace select dev
terraform output

# Switch to prod workspace
terraform workspace select prod
terraform output

# Compare the differences
```

**Expected Differences:**
- Instance types (t2.micro vs t2.small)
- Database instance classes (db.t3.micro vs db.t3.small)
- Auto scaling group sizes
- Monitoring configurations

---

## Lab 4: Monitoring and Validation (20 minutes)

### Objective
Set up monitoring and validate your infrastructure is working correctly.

### Step 1: Access CloudWatch Dashboard

```bash
# Get dashboard URL
terraform output dashboard_url

# Open the URL in your browser
# You should see metrics for your infrastructure
```

### Step 2: Test Application Health

```bash
# Get application URL
APP_URL=$(terraform output -raw application_url)

# Test main page
curl -I $APP_URL

# Test health endpoint
curl $APP_URL/health

# Test status endpoint
curl $APP_URL/status
```

### Step 3: Monitor Infrastructure

**Check Load Balancer:**
```bash
# Get load balancer ARN
ALB_ARN=$(terraform output -raw alb_arn)

# Check target group health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)
```

**Check Auto Scaling Group:**
```bash
# Get ASG name
ASG_NAME=$(terraform output -raw asg_name)

# Check ASG status
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $ASG_NAME
```

**Check Database:**
```bash
# Get database identifier
DB_ID=$(terraform output -raw db_endpoint | cut -d'.' -f1)

# Check database status
aws rds describe-db-instances --db-instance-identifier $DB_ID
```

### Step 4: Generate Health Report

```bash
# Create a health report
echo "=== Infrastructure Health Report ===" > health_report.txt
echo "Date: $(date)" >> health_report.txt
echo "Student: $(terraform output -raw workshop_info | jq -r '.student_name')" >> health_report.txt
echo "Environment: $(terraform output -raw workshop_info | jq -r '.environment')" >> health_report.txt
echo "" >> health_report.txt

echo "Application URL: $(terraform output -raw application_url)" >> health_report.txt
echo "Load Balancer: $(terraform output -raw alb_dns_name)" >> health_report.txt
echo "Database: $(terraform output -raw db_endpoint)" >> health_report.txt
echo "" >> health_report.txt

echo "Health Check Results:" >> health_report.txt
curl -s $(terraform output -raw application_url)/health >> health_report.txt

# View the report
cat health_report.txt
```

---

## Lab 5: Integration with DevOps (15 minutes)

### Objective
Understand how your infrastructure integrates with DevOps workflows.

### Step 1: Review GitHub Actions Workflows

```bash
# Navigate to workflows directory
cd ../.github/workflows

# List workflow files
ls -la

# Examine the workflows
cat terraform-plan.yml
cat terraform-apply.yml
cat devops-integration.yml
```

### Step 2: Understand Handoff Points

**Infrastructure Outputs for DevOps:**
```bash
# Get all outputs that DevOps team will use
terraform output alb_dns_name
terraform output db_endpoint
terraform output vpc_id
terraform output web_security_group_id
terraform output app_security_group_id
terraform output db_security_group_id
```

### Step 3: Test DevOps Integration

```bash
# Simulate DevOps workflow trigger
echo "Infrastructure ready for application deployment" > devops_handoff.txt
echo "Load Balancer: $(terraform output -raw alb_dns_name)" >> devops_handoff.txt
echo "Database: $(terraform output -raw db_endpoint)" >> devops_handoff.txt
echo "VPC: $(terraform output -raw vpc_id)" >> devops_handoff.txt

cat devops_handoff.txt
```

### Step 4: Prepare for DevOps Session

**Create Integration Summary:**
```bash
# Create summary for DevOps team
echo "=== DevOps Integration Summary ===" > devops_summary.md
echo "" >> devops_summary.md
echo "## Infrastructure Ready" >> devops_summary.md
echo "- VPC and networking configured" >> devops_summary.md
echo "- Security groups with proper access rules" >> devops_summary.md
echo "- Load balancer ready for application deployment" >> devops_summary.md
echo "- Database instance available" >> devops_summary.md
echo "- Monitoring dashboards configured" >> devops_summary.md
echo "" >> devops_summary.md
echo "## Next Steps for DevOps Team" >> devops_summary.md
echo "1. Deploy application containers" >> devops_summary.md
echo "2. Configure CI/CD pipelines" >> devops_summary.md
echo "3. Set up application monitoring" >> devops_summary.md
echo "4. Implement blue-green deployments" >> devops_summary.md

cat devops_summary.md
```

---

## Lab Completion Checklist

### Infrastructure Deployment
- [ ] VPC and subnets created
- [ ] Security groups configured
- [ ] Load balancer deployed
- [ ] Auto Scaling Group configured
- [ ] Database instance created
- [ ] Monitoring dashboard active

### Application Testing
- [ ] Application accessible via load balancer
- [ ] Health checks passing
- [ ] Status endpoints responding
- [ ] All tiers communicating properly

### Multi-Environment
- [ ] Dev environment deployed
- [ ] Prod environment deployed
- [ ] Workspaces configured
- [ ] Environment differences verified

### Monitoring and Validation
- [ ] CloudWatch dashboard accessible
- [ ] Health reports generated
- [ ] Infrastructure status verified
- [ ] Performance metrics collected

### DevOps Integration
- [ ] GitHub Actions workflows reviewed
- [ ] Handoff points identified
- [ ] Integration summary created
- [ ] Ready for DevOps session

---

## Troubleshooting Guide

### Common Issues and Solutions

**Issue 1: Terraform Authentication Errors**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Reconfigure if needed
aws configure
```

**Issue 2: Resource Creation Failures**
```bash
# Check AWS service limits
aws service-quotas get-service-quota --service-code ec2 --quota-code L-0263D0A3

# Check for existing resources
aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name!=`terminated`].[InstanceId,State.Name]'
```

**Issue 3: Application Not Accessible**
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids $(terraform output -raw web_security_group_id)

# Check load balancer status
aws elbv2 describe-load-balancers --load-balancer-arns $(terraform output -raw alb_arn)

# Check target group health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)
```

**Issue 4: Database Connection Issues**
```bash
# Check database status
aws rds describe-db-instances --db-instance-identifier $(terraform output -raw db_endpoint | cut -d'.' -f1)

# Check security group rules
aws ec2 describe-security-groups --group-ids $(terraform output -raw db_security_group_id)
```

### Debug Commands

**Infrastructure Debugging:**
```bash
# Check all resources
terraform show

# Check state
terraform state list

# Refresh state
terraform refresh

# Validate configuration
terraform validate
```

**Application Debugging:**
```bash
# Test connectivity
curl -v $(terraform output -raw application_url)

# Check logs (if SSH access available)
sudo tail -f /var/log/httpd/error_log
sudo tail -f /var/log/httpd/access_log
```

---

## Cleanup Instructions

### Important: Clean Up Resources

**To avoid charges, destroy your resources when done:**

```bash
# Destroy all resources
terraform destroy -var-file="student.tfvars"

# Type 'yes' when prompted
# Wait for all resources to be destroyed

# Verify cleanup
aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name!=`terminated`].[InstanceId,State.Name]'
aws rds describe-db-instances --query 'DBInstances[?DBInstanceStatus!=`deleted`].[DBInstanceIdentifier,DBInstanceStatus]'
```

### Selective Cleanup

```bash
# Destroy specific resources only
terraform destroy -target=aws_instance.web -var-file="student.tfvars"
terraform destroy -target=aws_db_instance.main -var-file="student.tfvars"
```

---

## Next Steps

### Immediate Actions
1. **Complete the Workshop:** Finish all lab exercises
2. **Test Your Infrastructure:** Verify everything works
3. **Join DevOps Session:** Learn about application deployment
4. **Practice More:** Try additional AWS services
5. **Clean Up:** Destroy resources to avoid charges

### Learning Continuation
1. **Explore AWS Console:** See your resources in the web interface
2. **Read Documentation:** Learn more about AWS services
3. **Try Advanced Features:** Experiment with additional configurations
4. **Join Community:** Connect with other learners
5. **Build Projects:** Apply your knowledge to real projects

### Career Development
1. **AWS Certifications:** Consider AWS Cloud Practitioner
2. **Terraform Certification:** Learn more about Infrastructure as Code
3. **DevOps Practices:** Explore CI/CD and automation
4. **Cloud Architecture:** Study well-architected frameworks
5. **Hands-on Practice:** Build your own projects

---

## Resources and Support

### Documentation
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)

### Tools
- [Terraform](https://terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- [AWS Console](https://console.aws.amazon.com/)

### Support
- **Workshop Instructors:** [Your Email]
- **DevOps Team:** [DevOps Email]
- **GitHub Issues:** [Repository Issues]
- **AWS Support:** [Support Contact]

---

## Workshop Feedback

Please complete the workshop feedback form to help us improve future sessions:

**Feedback Areas:**
- Content clarity and relevance
- Lab difficulty and pacing
- Tool and environment setup
- Instructor support and guidance
- Overall learning experience

**Suggestions for Improvement:**
- Additional topics to cover
- Better explanations needed
- Tools or resources to add
- Format or structure changes

---

## Congratulations! 🎉

You have successfully completed the IT Infrastructure Workshop! You now have hands-on experience with:

- ✅ Infrastructure as Code with Terraform
- ✅ 3-tier architecture deployment
- ✅ AWS services integration
- ✅ Security best practices
- ✅ Monitoring and observability
- ✅ Multi-environment management
- ✅ CI/CD workflow integration

**Remember to clean up your resources and join the DevOps session to learn about application deployment!**

---

**Happy Learning! 🚀**
