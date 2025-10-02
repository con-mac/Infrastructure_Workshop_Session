#!/bin/bash

# AWS Organizations Account Creation Script
# Creates 10 student accounts and moves them to Workshop-Students OU

set -e  # Exit on any error

# Configuration
OU_ID="ou-01dw-2r1xz8cp"
BASE_EMAIL="conor.macklin1986"
EMAIL_DOMAIN="@gmail.com"
ACCOUNT_COUNT=10
ROLE_NAME="OrganizationAccountAccessRole"

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

# Function to check current account creation status
check_account_limits() {
    print_status "Checking current account creation status..."
    
    # Get current account count in organization
    CURRENT_ACCOUNTS=$(aws organizations list-accounts --query 'Accounts[?Status==`ACTIVE`]' --output text | wc -l)
    print_status "Current active accounts in organization: $CURRENT_ACCOUNTS"
    
    # Check if we're approaching limits
    if [ $CURRENT_ACCOUNTS -gt 20 ]; then
        print_warning "You have many accounts in your organization. Consider cleanup if needed."
    fi
}

# Function to create a single account
create_account() {
    local student_num=$1
    local email="${BASE_EMAIL}+student${student_num}${EMAIL_DOMAIN}"
    local account_name="Student${student_num}-Workshop-2025"
    
    print_status "Creating account $student_num: $account_name ($email)"
    
    # Create the account
    local create_response=$(aws organizations create-account \
        --email "$email" \
        --account-name "$account_name" \
        --role-name "$ROLE_NAME" \
        --output json)
    
    local request_id=$(echo "$create_response" | jq -r '.CreateAccountStatus.Id')
    print_status "Account creation initiated. Request ID: $request_id"
    
    # Wait for account creation to complete
    print_status "Waiting for account creation to complete..."
    local max_attempts=60  # 10 minutes max wait
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        local status_response=$(aws organizations describe-create-account-status \
            --create-account-request-id "$request_id" \
            --output json)
        
        local status=$(echo "$status_response" | jq -r '.CreateAccountStatus.State')
        local account_id=$(echo "$status_response" | jq -r '.CreateAccountStatus.AccountId // empty')
        
        if [ "$status" = "SUCCEEDED" ]; then
            print_success "Account $student_num created successfully! Account ID: $account_id"
            echo "$account_id" >> "account-ids.txt"
            return 0
        elif [ "$status" = "FAILED" ]; then
            local failure_reason=$(echo "$status_response" | jq -r '.CreateAccountStatus.FailureReason')
            print_error "Account $student_num creation failed: $failure_reason"
            return 1
        else
            print_status "Account $student_num status: $status (attempt $((attempt + 1))/$max_attempts)"
            sleep 10
            attempt=$((attempt + 1))
        fi
    done
    
    print_error "Account $student_num creation timed out after $max_attempts attempts"
    return 1
}

# Function to move account to OU
move_account_to_ou() {
    local account_id=$1
    local student_num=$2
    
    print_status "Moving account $student_num ($account_id) to Workshop-Students OU..."
    
    aws organizations move-account \
        --account-id "$account_id" \
        --source-parent-id "r-$(aws organizations list-roots --query 'Roots[0].Id' --output text | cut -d'-' -f2)" \
        --destination-parent-id "$OU_ID" \
        --output json > /dev/null
    
    print_success "Account $student_num moved to Workshop-Students OU"
}

# Function to create all accounts
create_all_accounts() {
    print_status "Starting creation of $ACCOUNT_COUNT student accounts..."
    
    # Clear previous account IDs file
    > account-ids.txt
    
    local success_count=0
    local failed_accounts=()
    
    for i in $(seq 1 $ACCOUNT_COUNT); do
        if create_account $i; then
            success_count=$((success_count + 1))
            
            # Get the account ID from the file
            local account_id=$(tail -n 1 account-ids.txt)
            
            # Move account to OU
            if move_account_to_ou "$account_id" $i; then
                print_success "Account $i setup complete!"
            else
                print_error "Failed to move account $i to OU"
                failed_accounts+=($i)
            fi
        else
            print_error "Failed to create account $i"
            failed_accounts+=($i)
        fi
        
        # Add a small delay between account creations
        if [ $i -lt $ACCOUNT_COUNT ]; then
            print_status "Waiting 5 seconds before creating next account..."
            sleep 5
        fi
    done
    
    print_status "Account creation process completed!"
    print_success "Successfully created: $success_count accounts"
    
    if [ ${#failed_accounts[@]} -gt 0 ]; then
        print_warning "Failed accounts: ${failed_accounts[*]}"
    fi
}

# Function to display summary
display_summary() {
    print_status "=== ACCOUNT CREATION SUMMARY ==="
    
    if [ -f "account-ids.txt" ]; then
        local account_count=$(wc -l < account-ids.txt)
        print_success "Total accounts created: $account_count"
        
        echo ""
        print_status "Account Details:"
        echo "Account Name | Email | Account ID"
        echo "------------|-------|-----------"
        
        for i in $(seq 1 $ACCOUNT_COUNT); do
            if [ $i -le $account_count ]; then
                local account_id=$(sed -n "${i}p" account-ids.txt)
                local email="${BASE_EMAIL}+student${i}${EMAIL_DOMAIN}"
                local account_name="Student${i}-Workshop-2025"
                echo "$account_name | $email | $account_id"
            fi
        done
        
        echo ""
        print_status "Next steps:"
        echo "1. Deploy lab infrastructure to each account"
        echo "2. Create IAM users for direct console access"
        echo "3. Generate console access links"
        echo "4. Update dashboard for monitoring"
        
    else
        print_error "No accounts were created successfully"
    fi
}

# Main execution
main() {
    print_status "=== AWS Organizations Account Creation Script ==="
    print_status "Creating $ACCOUNT_COUNT student accounts"
    print_status "OU ID: $OU_ID"
    print_status "Base email: $BASE_EMAIL"
    echo ""
    
    # Check prerequisites
    check_aws_cli
    check_account_limits
    
    echo ""
    print_status "Starting account creation process..."
    echo ""
    
    # Create all accounts
    create_all_accounts
    
    echo ""
    display_summary
    
    print_success "Script completed!"
}

# Run the script
main "$@"
