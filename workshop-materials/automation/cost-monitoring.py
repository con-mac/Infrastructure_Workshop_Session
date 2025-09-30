import boto3
import json
import os
from datetime import datetime, timedelta

def get_workshop_costs():
    """Get cost information for all workshop accounts"""
    ce = boto3.client('ce')
    organizations = boto3.client('organizations')
    
    # Get workshop OU ID
    workshop_ou_id = os.environ.get('WORKSHOP_OU_ID')
    
    # Get all accounts in workshop OU
    accounts = organizations.list_accounts_for_parent(
        ParentId=workshop_ou_id
    )
    
    # Get costs for each account
    cost_data = []
    for account in accounts['Accounts']:
        account_id = account['Id']
        account_name = account['Name']
        account_email = account['Email']
        
        # Get costs for the last 30 days
        end_date = datetime.now().strftime('%Y-%m-%d')
        start_date = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
        
        try:
            response = ce.get_cost_and_usage(
                TimePeriod={
                    'Start': start_date,
                    'End': end_date
                },
                Granularity='MONTHLY',
                Metrics=['BlendedCost'],
                Filter={
                    'Dimensions': {
                        'Key': 'LINKED_ACCOUNT',
                        'Values': [account_id]
                    }
                }
            )
            
            cost = float(response['ResultsByTime'][0]['Total']['BlendedCost']['Amount'])
            
            cost_data.append({
                'account_id': account_id,
                'account_name': account_name,
                'account_email': account_email,
                'cost': cost,
                'status': 'ACTIVE' if cost < 15 else 'WARNING'
            })
            
        except Exception as e:
            print(f"Error getting costs for account {account_id}: {str(e)}")
    
    return cost_data

def generate_cost_report():
    """Generate a cost report for the workshop"""
    cost_data = get_workshop_costs()
    
    total_cost = sum(account['cost'] for account in cost_data)
    warning_accounts = [account for account in cost_data if account['status'] == 'WARNING']
    
    report = {
        'report_date': datetime.now().isoformat(),
        'total_cost': total_cost,
        'account_count': len(cost_data),
        'warning_count': len(warning_accounts),
        'accounts': cost_data
    }
    
    return report

if __name__ == "__main__":
    report = generate_cost_report()
    print(json.dumps(report, indent=2))
