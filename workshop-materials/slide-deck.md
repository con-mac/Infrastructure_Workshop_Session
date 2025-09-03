# IT Infrastructure Workshop
## University Apprenticeship Programme
### Friday 3rd October, 12:00–16:30

---

## Workshop Overview

**Duration:** 4.5 hours  
**Format:** Theory (2 hours) + Practical Labs (2.5 hours)  
**Target:** First-year university apprentices  
**Focus:** IT Infrastructure with public cloud emphasis  

**Learning Objectives:**
- Understand what infrastructure means in modern tech delivery
- Explore cloud platforms and their capabilities
- Learn about deployment environments and lifecycle management
- Understand containers, virtual machines, and their use cases
- Gain insight into CI/CD pipelines and deployment strategies
- Learn monitoring, logging, and incident response basics
- Understand security and access management fundamentals

---

## Part 1: Theory Session (2 hours)

---

## 1. Introduction to Infrastructure (15 minutes)

### What is Infrastructure?

**Traditional Definition:**
- Physical servers, networks, storage, and data centres
- Hardware that runs applications and services

**Modern Definition:**
- Everything that supports application delivery
- Physical + Virtual + Cloud resources
- Code, configurations, and automation

### Infrastructure in Tech Delivery Context

**Why Infrastructure Matters:**
- **Scalability:** Handle growing user demand
- **Reliability:** Keep services running 24/7
- **Performance:** Fast response times
- **Security:** Protect data and systems
- **Cost:** Optimise resource usage

### Infrastructure Evolution

```
Traditional → Virtualised → Cloud → Cloud-Native
    ↓            ↓           ↓         ↓
Physical      VMs        IaaS      Containers
Servers       Hypervisor PaaS      Microservices
              SaaS       Serverless
```

---

## 2. Cloud Platforms Overview (30 minutes)

### The Big Three Cloud Providers

#### Amazon Web Services (AWS)
- **Market Leader:** 32% market share
- **Strengths:** Comprehensive services, global reach
- **Key Services:** EC2, S3, Lambda, RDS
- **Use Cases:** Startups to enterprises

#### Microsoft Azure
- **Enterprise Focus:** Strong Microsoft integration
- **Strengths:** Hybrid cloud, enterprise tools
- **Key Services:** Virtual Machines, Azure SQL, Functions
- **Use Cases:** Microsoft-centric organisations

#### Google Cloud Platform (GCP)
- **Innovation Leader:** AI/ML, data analytics
- **Strengths:** Kubernetes, machine learning
- **Key Services:** Compute Engine, BigQuery, Cloud Functions
- **Use Cases:** Data-heavy applications

### Cloud Service Models

#### Infrastructure as a Service (IaaS)
- **What you get:** Virtual machines, storage, networking
- **What you manage:** OS, middleware, applications
- **Examples:** AWS EC2, Azure VMs, GCP Compute Engine

#### Platform as a Service (PaaS)
- **What you get:** Runtime environment, development tools
- **What you manage:** Applications and data only
- **Examples:** AWS Elastic Beanstalk, Azure App Service

#### Software as a Service (SaaS)
- **What you get:** Complete application
- **What you manage:** Configuration and data
- **Examples:** Office 365, Salesforce, Gmail

### Cloud Benefits

**Cost Efficiency:**
- Pay-as-you-go pricing
- No upfront hardware costs
- Automatic scaling

**Scalability:**
- Scale up/down based on demand
- Global infrastructure
- Elastic resources

**Reliability:**
- Built-in redundancy
- Multiple availability zones
- Disaster recovery

---

## 3. Environments & Lifecycle (20 minutes)

### Development Lifecycle Environments

#### Development (Dev)
- **Purpose:** Individual developer work
- **Characteristics:** Fast, cheap, disposable
- **Data:** Synthetic or anonymised
- **Access:** Developers only

#### Testing/QA
- **Purpose:** Quality assurance and testing
- **Characteristics:** Stable, reproducible
- **Data:** Test datasets
- **Access:** QA team, developers

#### Staging
- **Purpose:** Pre-production validation
- **Characteristics:** Production-like
- **Data:** Production-like (anonymised)
- **Access:** Limited team access

#### Production (Prod)
- **Purpose:** Live user-facing systems
- **Characteristics:** High availability, secure
- **Data:** Real user data
- **Access:** Restricted, monitored

### Environment Promotion Strategy

```
Code → Dev → Test → Staging → Production
  ↓      ↓      ↓       ↓         ↓
Build  Deploy  Test   Validate   Release
```

**Key Principles:**
- **Immutable Infrastructure:** Rebuild, don't modify
- **Infrastructure as Code:** Version control everything
- **Automated Promotion:** Reduce human error
- **Rollback Capability:** Quick recovery from issues

---

## 4. Containers and Virtual Machines (25 minutes)

### Virtual Machines (VMs)

**What are VMs?**
- Complete virtual computer
- Runs on hypervisor
- Has its own OS
- Isolated from host and other VMs

**VM Architecture:**
```
Application
    ↓
Guest OS (Windows/Linux)
    ↓
Hypervisor (VMware/Hyper-V)
    ↓
Host OS
    ↓
Physical Hardware
```

**VM Benefits:**
- **Isolation:** Complete separation
- **Compatibility:** Run any OS
- **Resource Control:** Allocated CPU/memory
- **Maturity:** Well-established technology

**VM Drawbacks:**
- **Resource Overhead:** Full OS per VM
- **Slow Startup:** Minutes to boot
- **Large Size:** GBs of disk space
- **Management Complexity:** Many moving parts

### Containers

**What are Containers?**
- Lightweight, portable units
- Share host OS kernel
- Package application + dependencies
- Isolated processes

**Container Architecture:**
```
Application + Dependencies
    ↓
Container Runtime (Docker)
    ↓
Host OS (Linux/Windows)
    ↓
Physical Hardware
```

**Container Benefits:**
- **Lightweight:** MBs vs GBs
- **Fast Startup:** Seconds to start
- **Portable:** Run anywhere
- **Efficient:** Share OS resources

**Container Drawbacks:**
- **OS Dependency:** Must match host OS
- **Security:** Shared kernel risks
- **Complexity:** New technology stack
- **Learning Curve:** Different paradigms

### When to Use What?

**Use VMs when:**
- Need different OS types
- Require complete isolation
- Legacy application support
- Regulatory compliance needs

**Use Containers when:**
- Microservices architecture
- Cloud-native applications
- Rapid deployment needs
- Resource efficiency matters

---

## 5. CI/CD Pipelines and Deployment Strategies (30 minutes)
### *[Handoff to DevOps Team]*

### Continuous Integration (CI)
**Definition:** Automatically build and test code changes

**CI Process:**
```
Code Commit → Build → Test → Package → Artifact
```

**Benefits:**
- Early bug detection
- Consistent builds
- Automated testing
- Fast feedback

### Continuous Deployment (CD)
**Definition:** Automatically deploy tested code to environments

**CD Process:**
```
Artifact → Deploy → Validate → Monitor
```

### Deployment Strategies

#### Blue-Green Deployment
- **Two identical environments**
- **Switch traffic instantly**
- **Zero downtime**
- **Easy rollback**

#### Rolling Deployment
- **Gradual replacement**
- **Some downtime possible**
- **Resource efficient**
- **Gradual rollback**

#### Canary Deployment
- **Small percentage of traffic**
- **Monitor for issues**
- **Gradual rollout**
- **Quick rollback**

### Infrastructure as Code (IaC)
**Definition:** Managing infrastructure through code

**Benefits:**
- **Version Control:** Track changes
- **Reproducibility:** Consistent environments
- **Automation:** Reduce manual work
- **Documentation:** Self-documenting infrastructure

**Tools:**
- **Terraform:** Multi-cloud provisioning
- **CloudFormation:** AWS-native
- **ARM Templates:** Azure-native
- **Ansible:** Configuration management

---

## 6. Monitoring, Logging, and Incident Response (20 minutes)

### The Three Pillars of Observability

#### Metrics
**What:** Numerical data over time
**Examples:** CPU usage, response time, error rate
**Tools:** CloudWatch, Prometheus, Grafana

#### Logs
**What:** Event records with timestamps
**Examples:** Application logs, system logs, access logs
**Tools:** CloudWatch Logs, ELK Stack, Splunk

#### Traces
**What:** Request flow through systems
**Examples:** Distributed tracing, performance analysis
**Tools:** X-Ray, Jaeger, Zipkin

### Monitoring Strategy

**What to Monitor:**
- **Infrastructure:** CPU, memory, disk, network
- **Applications:** Response time, error rate, throughput
- **Business:** User activity, revenue, conversions

**Alerting Best Practices:**
- **Clear thresholds:** Avoid alert fatigue
- **Escalation paths:** Who gets notified when
- **Runbooks:** How to respond to alerts
- **Regular review:** Tune thresholds

### Incident Response

**Incident Lifecycle:**
```
Detection → Response → Resolution → Post-Mortem
```

**Key Roles:**
- **Incident Commander:** Overall coordination
- **Technical Lead:** Technical investigation
- **Communications:** Stakeholder updates
- **Documentation:** Record everything

**Post-Incident Process:**
- **Root Cause Analysis:** Why did it happen?
- **Action Items:** How to prevent recurrence?
- **Process Improvements:** Better procedures
- **Knowledge Sharing:** Team learning

---

## 7. Security and Access Management Basics (20 minutes)

### Security Fundamentals

#### Defence in Depth
**Multiple layers of security:**
- **Network:** Firewalls, VPNs, segmentation
- **Application:** Authentication, authorisation
- **Data:** Encryption, backup, retention
- **Physical:** Data centre security

#### Zero Trust Model
**"Never trust, always verify"**
- **Identity verification:** Multi-factor authentication
- **Least privilege:** Minimum required access
- **Continuous monitoring:** Always watching
- **Micro-segmentation:** Isolated network zones

### Access Management

#### Identity and Access Management (IAM)
**Core Concepts:**
- **Users:** People who need access
- **Groups:** Collections of users
- **Roles:** Sets of permissions
- **Policies:** Rules defining permissions

#### Authentication vs Authorisation
**Authentication:** "Who are you?"
- Username/password
- Multi-factor authentication
- Single sign-on (SSO)

**Authorisation:** "What can you do?"
- Role-based access control (RBAC)
- Attribute-based access control (ABAC)
- Principle of least privilege

### Security Best Practices

**Infrastructure Security:**
- **Network segmentation:** Isolate environments
- **Encryption:** Data in transit and at rest
- **Regular updates:** Patch management
- **Backup and recovery:** Disaster preparedness

**Access Control:**
- **Strong passwords:** Complex, unique
- **MFA everywhere:** Additional security layer
- **Regular access reviews:** Remove unused access
- **Audit logging:** Track all access

**Compliance:**
- **Data protection:** GDPR, CCPA compliance
- **Industry standards:** ISO 27001, SOC 2
- **Regular assessments:** Security audits
- **Documentation:** Policies and procedures

---

## Break (15 minutes)

---

## Part 2: Practical Labs (2.5 hours)

### Lab Environment Setup

**What you'll need:**
- Laptop with web browser
- GitHub account
- Cloud sandbox access (provided)
- Basic command line knowledge

**Lab Objectives:**
- Deploy a 3-tier web application
- Use Infrastructure as Code (Terraform)
- Implement multi-environment deployment
- Set up basic monitoring
- Understand CI/CD workflows

### Lab Structure

1. **Environment Setup** (15 mins)
2. **Infrastructure as Code Basics** (30 mins)
3. **Deploy 3-Tier Architecture** (60 mins)
4. **Multi-Environment Deployment** (45 mins)
5. **Monitoring & Validation** (20 mins)

---

## Lab 1: Environment Setup (15 minutes)

### Step 1: Access Cloud Sandbox
1. Navigate to: `[Sandbox URL]`
2. Login with provided credentials
3. Verify access to AWS Console

### Step 2: Clone Repository
```bash
git clone https://github.com/[workshop-repo]/infrastructure-workshop.git
cd infrastructure-workshop
```

### Step 3: Verify Tools
```bash
# Check Terraform version
terraform --version

# Check AWS CLI
aws --version

# Check Git
git --version
```

**Expected Output:**
- Terraform v1.5+
- AWS CLI v2.0+
- Git v2.30+

---

## Lab 2: Infrastructure as Code Basics (30 minutes)

### Understanding Terraform

**What is Terraform?**
- Infrastructure as Code tool
- Declarative language (HCL)
- Multi-cloud support
- State management

### Basic Terraform Structure

```hcl
# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  
  tags = {
    Name = "WebServer"
  }
}
```

### Your First Infrastructure

**Task 1: Create a VPC**
```hcl
# TODO: Fill in the missing values
resource "aws_vpc" "main" {
  cidr_block = "___"  # Hint: Use 10.0.0.0/16
  
  tags = {
    Name = "___"  # Hint: Use "workshop-vpc"
  }
}
```

**Task 2: Create a Subnet**
```hcl
# TODO: Create a public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "___"  # Hint: Use 10.0.1.0/24
  
  tags = {
    Name = "___"  # Hint: Use "workshop-public-subnet"
  }
}
```

### Terraform Commands

```bash
# Initialise Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the changes
terraform apply

# Destroy resources
terraform destroy
```

---

## Lab 3: Deploy 3-Tier Architecture (60 minutes)

### Architecture Overview

```
Internet → Load Balancer → Web Tier → App Tier → Database Tier
```

### Tier 1: Web Tier (Load Balancer + Web Servers)

**Task 3: Create Security Groups**
```hcl
# TODO: Create security group for web tier
resource "aws_security_group" "web" {
  name_prefix = "web-"
  vpc_id      = aws_vpc.main.id

  # TODO: Add ingress rule for HTTP (port 80)
  ingress {
    from_port   = ___
    to_port     = ___
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}
```

**Task 4: Create Application Load Balancer**
```hcl
# TODO: Create ALB
resource "aws_lb" "web" {
  name               = "workshop-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets            = [aws_subnet.public.id]

  tags = {
    Name = "workshop-web-alb"
  }
}
```

### Tier 2: Application Tier

**Task 5: Create App Security Group**
```hcl
# TODO: Create security group for app tier
resource "aws_security_group" "app" {
  name_prefix = "app-"
  vpc_id      = aws_vpc.main.id

  # TODO: Allow traffic from web tier only
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [___]  # Hint: Reference web security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}
```

### Tier 3: Database Tier

**Task 6: Create RDS Instance**
```hcl
# TODO: Create RDS subnet group
resource "aws_db_subnet_group" "main" {
  name       = "workshop-db-subnet-group"
  subnet_ids = [aws_subnet.public.id]

  tags = {
    Name = "workshop-db-subnet-group"
  }
}

# TODO: Create RDS instance
resource "aws_db_instance" "main" {
  identifier = "workshop-db"
  
  # TODO: Set engine (Hint: Use "mysql")
  engine = "___"
  
  # TODO: Set engine version (Hint: Use "8.0")
  engine_version = "___"
  
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  
  db_name  = "workshopdb"
  username = "admin"
  password = "Workshop2024!"
  
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  skip_final_snapshot = true
  
  tags = {
    Name = "workshop-db"
  }
}
```

### Deploy and Test

```bash
# Deploy the infrastructure
terraform apply

# Get the load balancer URL
terraform output alb_dns_name

# Test the application
curl http://[ALB_DNS_NAME]
```

---

## Lab 4: Multi-Environment Deployment (45 minutes)

### Environment Strategy

**Goal:** Deploy the same infrastructure to multiple environments

### Step 1: Create Environment Variables

**Create `dev.tfvars`:**
```hcl
environment = "dev"
instance_type = "t2.micro"
db_instance_class = "db.t3.micro"
```

**Create `prod.tfvars`:**
```hcl
environment = "prod"
instance_type = "t2.small"
db_instance_class = "db.t3.small"
```

### Step 2: Update Main Configuration

**Task 7: Add Variables**
```hcl
# variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}
```

**Task 8: Update Resource Names**
```hcl
# TODO: Update VPC name to include environment
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "workshop-${var.environment}-vpc"
  }
}
```

### Step 3: Deploy to Multiple Environments

```bash
# Deploy to dev environment
terraform apply -var-file="dev.tfvars"

# Deploy to prod environment
terraform apply -var-file="prod.tfvars"
```

### Step 4: Workspace Management

```bash
# Create workspace for dev
terraform workspace new dev

# Create workspace for prod
terraform workspace new prod

# Switch between workspaces
terraform workspace select dev
terraform workspace select prod
```

---

## Lab 5: Monitoring & Validation (20 minutes)

### Basic Monitoring Setup

**Task 9: Create CloudWatch Dashboard**
```hcl
# TODO: Create CloudWatch dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "workshop-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "___"]  # TODO: Add instance ID
          ]
          period = 300
          stat   = "Average"
          region = "us-west-2"
          title  = "EC2 CPU Utilization"
        }
      }
    ]
  })
}
```

### Application Health Checks

**Task 10: Create Health Check**
```hcl
# TODO: Create target group health check
resource "aws_lb_target_group" "web" {
  name     = "workshop-web-tg"
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
}
```

### Validation Commands

```bash
# Check infrastructure status
terraform show

# Get outputs
terraform output

# Validate configuration
terraform validate

# Check for drift
terraform plan
```

---

## Integration with DevOps Session

### Handoff Points

**Infrastructure Team Responsibilities:**
- ✅ VPC and networking setup
- ✅ Security groups and IAM roles
- ✅ Database and storage provisioning
- ✅ Load balancer configuration
- ✅ Basic monitoring setup

**DevOps Team Responsibilities:**
- 🔄 Application deployment pipelines
- 🔄 Container orchestration (Kubernetes)
- 🔄 Advanced CI/CD workflows
- 🔄 Application monitoring and alerting
- 🔄 Blue-green deployment strategies

### Shared Resources

**Infrastructure Outputs for DevOps:**
```hcl
# outputs.tf
output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.web.dns_name
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
```

---

## Workshop Summary

### What We've Covered

**Theory:**
- Infrastructure fundamentals
- Cloud platforms and services
- Environment lifecycle
- Containers vs VMs
- CI/CD and deployment strategies
- Monitoring and observability
- Security and access management

**Practical:**
- Infrastructure as Code with Terraform
- 3-tier architecture deployment
- Multi-environment management
- Basic monitoring setup
- Integration with DevOps workflows

### Next Steps

**For Apprentices:**
1. **Practice:** Deploy infrastructure in your own AWS account
2. **Learn:** Explore more AWS services
3. **Experiment:** Try different deployment strategies
4. **Connect:** Join DevOps session for application deployment

**Resources:**
- AWS Free Tier: https://aws.amazon.com/free/
- Terraform Documentation: https://terraform.io/docs
- GitHub Actions: https://docs.github.com/actions
- Cloud Best Practices: https://aws.amazon.com/architecture/well-architected/

### Questions & Discussion

**Common Questions:**
- How do I choose between cloud providers?
- When should I use containers vs VMs?
- How do I handle secrets in infrastructure code?
- What's the difference between IaaS, PaaS, and SaaS?

---

## Thank You!

**Contact Information:**
- Infrastructure Team: [Your Email]
- DevOps Team: [Teammate Email]
- Workshop Repository: [GitHub URL]

**Feedback:**
Please complete the workshop feedback form to help us improve future sessions.

**Happy Learning! 🚀**
