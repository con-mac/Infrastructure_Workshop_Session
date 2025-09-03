# IT Infrastructure Workshop - Terraform Configuration
## University Apprenticeship Programme

This directory contains the Terraform configuration files for deploying a 3-tier web application architecture on AWS.

---

## Architecture Overview

```
Internet → Application Load Balancer → Auto Scaling Group → EC2 Instances (Web/App)
                                                              ↓
                                                         RDS MySQL (Database)
```

### Components:
- **Web Tier:** Application Load Balancer + Auto Scaling Group
- **Application Tier:** EC2 instances running Apache/PHP
- **Database Tier:** RDS MySQL instance
- **Networking:** VPC with public and private subnets
- **Security:** Security groups with least privilege access
- **Monitoring:** CloudWatch dashboard and metrics

---

## Files Structure

```
terraform/
├── main.tf          # Main infrastructure configuration
├── variables.tf     # Variable definitions
├── outputs.tf       # Output values
├── user_data.sh     # EC2 instance initialization script
├── dev.tfvars       # Development environment variables
├── prod.tfvars      # Production environment variables
└── README.md        # This file
```

---

## Prerequisites

### Required Tools:
- **Terraform:** >= 1.0
- **AWS CLI:** >= 2.0
- **Git:** >= 2.30

### AWS Requirements:
- AWS account with appropriate permissions
- AWS CLI configured with credentials
- Access to the following AWS services:
  - EC2 (instances, security groups, VPC)
  - RDS (database instances)
  - ELB (load balancers)
  - Auto Scaling
  - CloudWatch
  - IAM (for roles and policies)

---

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/[workshop-repo]/infrastructure-workshop.git
cd infrastructure-workshop/terraform
```

### 2. Configure Variables
Edit the appropriate `.tfvars` file for your environment:

**For Development:**
```bash
cp dev.tfvars student.tfvars
# Edit student.tfvars with your information
```

**For Production:**
```bash
cp prod.tfvars student.tfvars
# Edit student.tfvars with your information
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Plan the Deployment
```bash
terraform plan -var-file="student.tfvars"
```

### 5. Deploy the Infrastructure
```bash
terraform apply -var-file="student.tfvars"
```

### 6. Access Your Application
```bash
# Get the application URL
terraform output application_url

# Test the application
curl $(terraform output -raw application_url)
```

---

## Configuration Details

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `student_name` | Name for resource naming | "student" | No |
| `student_email` | Student email address | "student@university.edu" | No |
| `environment` | Environment (dev/staging/prod) | "dev" | No |
| `aws_region` | AWS region | "us-west-2" | No |
| `instance_type` | EC2 instance type | "t2.micro" | No |
| `db_instance_class` | RDS instance class | "db.t3.micro" | No |
| `vpc_cidr` | VPC CIDR block | "10.0.0.0/16" | No |
| `public_subnet_cidr` | Public subnet CIDR | "10.0.1.0/24" | No |
| `private_subnet_cidr` | Private subnet CIDR | "10.0.2.0/24" | No |

### Key Resources Created

#### Networking:
- VPC with DNS support
- Internet Gateway
- Public and private subnets
- Route tables and associations

#### Security:
- Security groups for web, app, and database tiers
- Least privilege access rules
- Encrypted database storage

#### Compute:
- Application Load Balancer
- Auto Scaling Group
- Launch Template with user data

#### Database:
- RDS MySQL instance
- Database subnet group
- Automated backups

#### Monitoring:
- CloudWatch dashboard
- Custom metrics
- Log groups

---

## Workshop Tasks

### Task 1: Complete the VPC Configuration
In `main.tf`, fill in the missing values:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "___"  # TODO: Use 10.0.0.0/16
  # ... rest of configuration
}
```

### Task 2: Configure Security Groups
Complete the security group rules:

```hcl
resource "aws_security_group" "web" {
  # TODO: Add HTTP (port 80) and HTTPS (port 443) rules
  ingress {
    from_port   = ___  # TODO: Fill in port number
    to_port     = ___  # TODO: Fill in port number
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Task 3: Set Up the Database
Configure the RDS instance:

```hcl
resource "aws_db_instance" "main" {
  engine = "___"  # TODO: Use "mysql"
  engine_version = "___"  # TODO: Use "8.0"
  # ... rest of configuration
}
```

### Task 4: Deploy to Multiple Environments
Use different variable files for different environments:

```bash
# Deploy to development
terraform apply -var-file="dev.tfvars"

# Deploy to production
terraform apply -var-file="prod.tfvars"
```

---

## Multi-Environment Deployment

### Using Workspaces
```bash
# Create workspace for dev
terraform workspace new dev

# Create workspace for prod
terraform workspace new prod

# Switch between workspaces
terraform workspace select dev
terraform workspace select prod
```

### Using Variable Files
```bash
# Deploy with specific environment
terraform apply -var-file="dev.tfvars"
terraform apply -var-file="prod.tfvars"
```

---

## Monitoring and Observability

### CloudWatch Dashboard
Access the dashboard URL from the outputs:
```bash
terraform output dashboard_url
```

### Health Checks
The application includes health check endpoints:
- `/health` - Simple health check
- `/health.php` - Detailed health information
- `/status` - Service status

### Logs
CloudWatch logs are configured for:
- Apache access logs
- Apache error logs
- System logs

---

## Security Best Practices

### Implemented:
- ✅ VPC with private subnets
- ✅ Security groups with least privilege
- ✅ Encrypted database storage
- ✅ No hardcoded credentials
- ✅ Resource tagging for cost tracking

### Additional Recommendations:
- Use AWS Secrets Manager for sensitive data
- Enable VPC Flow Logs
- Set up AWS Config for compliance
- Implement AWS WAF for web protection
- Use AWS Certificate Manager for SSL/TLS

---

## Cost Management

### Estimated Monthly Costs:
- **Load Balancer:** ~$18
- **RDS Instance:** ~$15
- **EC2 Instances:** $0 (t2.micro free tier)
- **Data Transfer:** ~$5
- **Total:** ~$38/month

### Cost Optimization:
- Use t2.micro instances (free tier)
- Enable auto-shutdown for non-production
- Use appropriate instance sizes
- Monitor usage with CloudWatch
- Clean up resources when done

---

## Troubleshooting

### Common Issues:

**1. Authentication Errors:**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Reconfigure if needed
aws configure
```

**2. Resource Limits:**
```bash
# Check service limits
aws service-quotas get-service-quota --service-code ec2 --quota-code L-0263D0A3
```

**3. Terraform State Issues:**
```bash
# Refresh state
terraform refresh

# Import existing resources
terraform import aws_instance.example i-1234567890abcdef0
```

**4. Application Not Accessible:**
- Check security group rules
- Verify load balancer health checks
- Check EC2 instance status
- Review CloudWatch logs

---

## Cleanup

### Destroy All Resources:
```bash
terraform destroy -var-file="student.tfvars"
```

### Selective Cleanup:
```bash
# Destroy specific resources
terraform destroy -target=aws_instance.web
terraform destroy -target=aws_db_instance.main
```

### Verify Cleanup:
```bash
# Check for remaining resources
aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name!=`terminated`].[InstanceId,State.Name]'
aws rds describe-db-instances --query 'DBInstances[?DBInstanceStatus!=`deleted`].[DBInstanceIdentifier,DBInstanceStatus]'
```

---

## Integration with DevOps Session

### Handoff Points:
This infrastructure provides the foundation for the DevOps session:

**Infrastructure Outputs for DevOps:**
```bash
# Get load balancer DNS name
terraform output alb_dns_name

# Get database endpoint
terraform output db_endpoint

# Get VPC ID
terraform output vpc_id
```

**DevOps Team Will:**
- Deploy application containers
- Set up CI/CD pipelines
- Configure application monitoring
- Implement blue-green deployments

---

## Learning Objectives

After completing this workshop, you should understand:

1. **Infrastructure as Code:** How to define infrastructure using Terraform
2. **3-Tier Architecture:** Web, application, and database tiers
3. **AWS Services:** EC2, RDS, ELB, Auto Scaling, CloudWatch
4. **Security:** Security groups, VPC, encryption
5. **Monitoring:** CloudWatch dashboards and metrics
6. **Multi-Environment:** Different configurations for dev/prod
7. **Best Practices:** Cost optimization, security, monitoring

---

## Resources

### Documentation:
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)

### Tools:
- [Terraform](https://terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- [AWS Console](https://console.aws.amazon.com/)

### Support:
- Workshop Instructors: [Your Email]
- AWS Support: [Support Contact]
- GitHub Issues: [Repository Issues]

---

## Next Steps

1. **Complete the Workshop Tasks:** Fill in all the TODO items
2. **Test Your Infrastructure:** Verify all components work
3. **Explore AWS Console:** See your resources in the web interface
4. **Join DevOps Session:** Learn about application deployment
5. **Practice More:** Try additional AWS services
6. **Clean Up:** Destroy resources to avoid charges

---

**Happy Learning! 🚀**
