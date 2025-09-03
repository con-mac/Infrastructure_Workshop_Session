# Production Environment Configuration
# IT Infrastructure Workshop - University Apprenticeship Programme

# Student Information
student_name  = "prod-student"
student_email = "student@university.edu"

# Environment Configuration
environment = "prod"

# AWS Configuration
aws_region = "us-west-2"

# Instance Configuration (Larger for production)
instance_type = "t2.small"

# Database Configuration (Larger for production)
db_instance_class = "db.t3.small"

# Networking Configuration
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

# Auto Scaling Configuration (More instances for production)
min_size         = 2
max_size         = 5
desired_capacity = 3

# Monitoring Configuration
enable_detailed_monitoring = true
log_retention_days        = 30

# Security Configuration
allowed_cidr_blocks = ["0.0.0.0/0"]

# Backup Configuration (More backups for production)
backup_retention_period = 7

# Cost Management
enable_cost_optimization = true
auto_shutdown_schedule   = "0 0 * * 0"  # Never auto-shutdown in production
