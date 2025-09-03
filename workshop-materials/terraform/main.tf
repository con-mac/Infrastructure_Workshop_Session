# IT Infrastructure Workshop - Main Terraform Configuration
# University Apprenticeship Programme

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Workshop     = "Infrastructure-2024"
      Student      = var.student_name
      Environment  = var.environment
      Owner        = var.student_email
      CostCenter   = "Workshop-Infrastructure"
      CreatedBy    = "Terraform"
    }
  }
}

# Data sources for latest AMIs
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# TODO: Create VPC
# Hint: Use cidr_block = "10.0.0.0/16"
resource "aws_vpc" "main" {
  cidr_block           = "___"  # TODO: Fill in CIDR block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.student_name}-${var.environment}-vpc"
  }
}

# TODO: Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.student_name}-${var.environment}-igw"
  }
}

# TODO: Create Public Subnet
# Hint: Use cidr_block = "10.0.1.0/24"
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "___"  # TODO: Fill in CIDR block
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.student_name}-${var.environment}-public-subnet"
    Type = "Public"
  }
}

# TODO: Create Private Subnet for Database
# Hint: Use cidr_block = "10.0.2.0/24"
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "___"  # TODO: Fill in CIDR block
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.student_name}-${var.environment}-private-subnet"
    Type = "Private"
  }
}

# TODO: Create Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.student_name}-${var.environment}-public-rt"
  }
}

# TODO: Associate Public Subnet with Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# TODO: Create Security Group for Web Tier
# Hint: Allow HTTP (port 80) and HTTPS (port 443) from anywhere
resource "aws_security_group" "web" {
  name_prefix = "${var.student_name}-web-"
  vpc_id      = aws_vpc.main.id

  # TODO: Add ingress rule for HTTP
  ingress {
    from_port   = ___  # TODO: Fill in port number
    to_port     = ___  # TODO: Fill in port number
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access from internet"
  }

  # TODO: Add ingress rule for HTTPS
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

# TODO: Create Security Group for App Tier
# Hint: Allow traffic from web tier only (port 8080)
resource "aws_security_group" "app" {
  name_prefix = "${var.student_name}-app-"
  vpc_id      = aws_vpc.main.id

  # TODO: Add ingress rule for app traffic from web tier
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

# TODO: Create Security Group for Database Tier
# Hint: Allow MySQL traffic (port 3306) from app tier only
resource "aws_security_group" "db" {
  name_prefix = "${var.student_name}-db-"
  vpc_id      = aws_vpc.main.id

  # TODO: Add ingress rule for MySQL from app tier
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

# TODO: Create Application Load Balancer
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

# TODO: Create Target Group for Web Servers
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
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.student_name}-${var.environment}-web-tg"
  }
}

# TODO: Create Load Balancer Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# TODO: Create Launch Template for Web Servers
resource "aws_launch_template" "web" {
  name_prefix   = "${var.student_name}-${var.environment}-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    student_name = var.student_name
    environment  = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.student_name}-${var.environment}-web-server"
    }
  }

  tags = {
    Name = "${var.student_name}-${var.environment}-web-lt"
  }
}

# TODO: Create Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                = "${var.student_name}-${var.environment}-web-asg"
  vpc_zone_identifier = [aws_subnet.public.id]
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 1
  max_size         = 3
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.student_name}-${var.environment}-web-asg"
    propagate_at_launch = false
  }
}

# TODO: Create RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.student_name}-${var.environment}-db-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.public.id]

  tags = {
    Name = "${var.student_name}-${var.environment}-db-subnet-group"
  }
}

# TODO: Create RDS Instance
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

# TODO: Create CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.student_name}-${var.environment}-dashboard"

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
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.web.arn_suffix],
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.web.arn_suffix]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Load Balancer Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.main.id],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.main.id]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Database Metrics"
        }
      }
    ]
  })
}
