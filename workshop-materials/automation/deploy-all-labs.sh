#!/bin/bash

# Complete Lab Environment Deployment Script
# Deploys main infrastructure + all lab challenges

set -e  # Exit on any error

# Configuration
STACK_PREFIX="Student1"
CLOUDFORMATION_DIR="workshop-materials/cloudformation"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed or not in PATH"
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured or credentials are invalid"
        exit 1
    fi
    
    print_success "AWS CLI is configured and working"
}

# Function to check if we're in the right account
check_account() {
    local account_id=$(aws sts get-caller-identity --query Account --output text)
    print_status "Current account ID: $account_id"
    
    if [ "$account_id" = "535002854646" ]; then
        print_warning "You're in the master account. Please switch to a student account first."
        exit 1
    fi
    
    print_success "You're in a student account: $account_id"
}

# Function to deploy a CloudFormation stack
deploy_stack() {
    local stack_name=$1
    local template_file=$2
    local capabilities=$3
    
    print_status "Deploying stack: $stack_name"
    
    if [ ! -f "$template_file" ]; then
        print_error "Template file not found: $template_file"
        return 1
    fi
    
    # Check if stack already exists
    if aws cloudformation describe-stacks --stack-name "$stack_name" &> /dev/null; then
        print_warning "Stack $stack_name already exists. Updating..."
        aws cloudformation update-stack \
            --stack-name "$stack_name" \
            --template-body "file://$template_file" \
            --capabilities $capabilities \
            --output json > /dev/null
    else
        print_status "Creating new stack: $stack_name"
        aws cloudformation create-stack \
            --stack-name "$stack_name" \
            --template-body "file://$template_file" \
            --capabilities $capabilities \
            --output json > /dev/null
    fi
    
    # Wait for stack to complete
    print_status "Waiting for stack $stack_name to complete..."
    aws cloudformation wait stack-create-complete --stack-name "$stack_name" 2>/dev/null || \
    aws cloudformation wait stack-update-complete --stack-name "$stack_name" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        print_success "Stack $stack_name deployed successfully!"
    else
        print_error "Stack $stack_name deployment failed!"
        return 1
    fi
}

# Function to deploy main infrastructure
deploy_main_infrastructure() {
    print_status "=== DEPLOYING MAIN INFRASTRUCTURE ==="
    
    deploy_stack \
        "${STACK_PREFIX}-Lab-Infrastructure" \
        "$CLOUDFORMATION_DIR/working-2-tier-app.yaml" \
        "CAPABILITY_IAM"
}

# Function to deploy all lab challenges
deploy_lab_challenges() {
    print_status "=== DEPLOYING ALL LAB CHALLENGES ==="
    
    # List of challenge templates
    local challenges=(
        "iam-challenge:iam-challenge.yaml"
        "load-balancer-challenge:load-balancer-challenge.yaml"
        "nacl-challenge:nacl-challenge.yaml"
        "security-group-challenge:security-group-challenge.yaml"
        "blue-green-deployment:blue-green-deployment.yaml"
    )
    
    for challenge in "${challenges[@]}"; do
        local stack_name=$(echo "$challenge" | cut -d':' -f1)
        local template_file="$CLOUDFORMATION_DIR/$(echo "$challenge" | cut -d':' -f2)"
        
        deploy_stack "$stack_name" "$template_file" "CAPABILITY_IAM"
    done
}

# Function to verify all deployments
verify_deployments() {
    print_status "=== VERIFYING ALL DEPLOYMENTS ==="
    
    # Check main infrastructure
    print_status "Checking main infrastructure..."
    aws cloudformation describe-stacks \
        --stack-name "${STACK_PREFIX}-Lab-Infrastructure" \
        --query 'Stacks[0].StackStatus' \
        --output text
    
    # Check all challenge stacks
    print_status "Checking challenge stacks..."
    aws cloudformation list-stacks \
        --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
        --query 'StackSummaries[?contains(StackName, `challenge`) || contains(StackName, `blue-green`)].{Name:StackName,Status:StackStatus}' \
        --output table
    
    # Check resources
    print_status "Checking EC2 instances..."
    aws ec2 describe-instances \
        --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' \
        --output table
    
    print_status "Checking RDS databases..."
    aws rds describe-db-instances \
        --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]' \
        --output table
    
    print_status "Checking Load Balancers..."
    aws elbv2 describe-load-balancers \
        --query 'LoadBalancers[*].[LoadBalancerName,State.Code]' \
        --output table
}

# Function to get application URLs
get_application_urls() {
    print_status "=== APPLICATION URLs ==="
    
    # Get Load Balancer DNS names
    aws elbv2 describe-load-balancers \
        --query 'LoadBalancers[*].[LoadBalancerName,DNSName]' \
        --output table
    
    # Get EC2 instance public IPs
    print_status "EC2 Instance Public IPs:"
    aws ec2 describe-instances \
        --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress]' \
        --output table
}

# Function to create summary report
create_summary_report() {
    local account_id=$(aws sts get-caller-identity --query Account --output text)
    
    print_status "=== CREATING SUMMARY REPORT ==="
    
    cat > "lab-deployment-summary.txt" << EOF
=== LAB DEPLOYMENT SUMMARY ===
Account ID: $account_id
Deployment Date: $(date)
Stack Prefix: $STACK_PREFIX

=== DEPLOYED STACKS ===
Main Infrastructure: ${STACK_PREFIX}-Lab-Infrastructure
Lab Challenges:
- iam-challenge
- load-balancer-challenge
- nacl-challenge
- security-group-challenge
- blue-green-deployment

=== APPLICATION URLs ===
EOF

    # Add Load Balancer URLs
    aws elbv2 describe-load-balancers \
        --query 'LoadBalancers[*].[LoadBalancerName,DNSName]' \
        --output text >> "lab-deployment-summary.txt"
    
    print_success "Summary report created: lab-deployment-summary.txt"
}

# Main execution
main() {
    print_status "=== COMPLETE LAB ENVIRONMENT DEPLOYMENT ==="
    print_status "This will deploy main infrastructure + all lab challenges"
    echo ""
    
    # Check prerequisites
    check_aws_cli
    check_account
    
    echo ""
    print_status "Starting complete lab deployment..."
    echo ""
    
    # Deploy everything
    deploy_main_infrastructure
    echo ""
    
    deploy_lab_challenges
    echo ""
    
    # Verify deployments
    verify_deployments
    echo ""
    
    # Get URLs
    get_application_urls
    echo ""
    
    # Create summary
    create_summary_report
    
    print_success "=== DEPLOYMENT COMPLETE! ==="
    print_status "All lab infrastructure and challenges are now deployed"
    print_status "Students can access the pre-deployed lab environment"
    print_status "Check lab-deployment-summary.txt for details"
}

# Run the script
main "$@"
