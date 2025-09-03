# IT Infrastructure Workshop - Outputs
# University Apprenticeship Programme

# VPC Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Subnet Information
output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

# Load Balancer Information
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.web.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.web.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.web.arn
}

# Target Group Information
output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.web.arn
}

# Auto Scaling Group Information
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.web.arn
}

# Database Information
output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "RDS instance database name"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "RDS instance master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

# Security Group Information
output "web_security_group_id" {
  description = "ID of the web tier security group"
  value       = aws_security_group.web.id
}

output "app_security_group_id" {
  description = "ID of the app tier security group"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "ID of the database tier security group"
  value       = aws_security_group.db.id
}

# CloudWatch Dashboard Information
output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

# Application URL
output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.web.dns_name}"
}

# Workshop Information
output "workshop_info" {
  description = "Workshop and student information"
  value = {
    student_name    = var.student_name
    student_email   = var.student_email
    environment     = var.environment
    aws_region      = var.aws_region
    workshop_date   = "2024-10-03"
    workshop_name   = "IT Infrastructure Workshop"
  }
}

# Resource Summary
output "resource_summary" {
  description = "Summary of created resources"
  value = {
    vpc_created           = aws_vpc.main.id != null
    load_balancer_created = aws_lb.web.id != null
    database_created      = aws_db_instance.main.id != null
    auto_scaling_created  = aws_autoscaling_group.web.id != null
    dashboard_created     = aws_cloudwatch_dashboard.main.dashboard_name != null
  }
}

# Cost Estimation (Approximate)
output "estimated_monthly_cost" {
  description = "Estimated monthly cost for the infrastructure"
  value = {
    load_balancer = "$18.00"
    rds_instance  = "$15.00"
    ec2_instances = "$0.00 (t2.micro free tier)"
    data_transfer = "$5.00"
    total         = "$38.00"
    note          = "Costs are estimates and may vary based on usage"
  }
}

# Next Steps for Students
output "next_steps" {
  description = "Next steps for students after completing the workshop"
  value = {
    test_application = "Visit ${aws_lb.web.dns_name} to test your application"
    monitor_resources = "Check the CloudWatch dashboard for metrics"
    explore_aws_console = "Log into AWS Console to explore your resources"
    join_devops_session = "Attend the DevOps session to learn about application deployment"
    practice_more = "Try deploying additional resources in your AWS account"
    cleanup_resources = "Remember to run 'terraform destroy' when done to avoid charges"
  }
}
