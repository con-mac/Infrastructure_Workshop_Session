# Development Environment Configuration
# IT Infrastructure Workshop - University Apprenticeship Programme

# Student Information
student_name  = "dev-student"
student_email = "student@university.edu"

# Environment Configuration
environment = "dev"

# AWS Configuration
aws_region = "us-west-2"

# Instance Configuration (Small for development)
instance_type = "t2.micro"

# Database Configuration (Small for development)
db_instance_class = "db.t3.micro"

# Networking Configuration
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

# Auto Scaling Configuration (Minimal for development)
min_size         = 1
max_size         = 2
desired_capacity = 1

# Monitoring Configuration
enable_detailed_monitoring = false
log_retention_days        = 3

# Security Configuration
allowed_cidr_blocks = ["0.0.0.0/0"]

# Backup Configuration (Minimal for development)
backup_retention_period = 1

# Cost Management
enable_cost_optimization = true
auto_shutdown_schedule   = "0 18 * * 1-5"  # 6 PM on weekdays
