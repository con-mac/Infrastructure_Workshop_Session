import boto3
import json
from datetime import datetime, timedelta
import os

def get_workshop_status():
    """Get comprehensive workshop status"""
    organizations = boto3.client('organizations')
    budgets = boto3.client('budgets')
    ce = boto3.client('ce')
    
    workshop_ou_id = os.environ.get('WORKSHOP_OU_ID')
    
    # Get all accounts
    accounts = organizations.list_accounts_for_parent(
        ParentId=workshop_ou_id
    )
    
    # Get account details
    account_status = []
    total_cost = 0
    
    for account in accounts['Accounts']:
        account_id = account['Id']
        account_name = account['Name']
        account_email = account['Email']
        account_status_val = account['Status']
        joined_date = account['JoinedTimestamp']
        
        # Get cost for this account
        try:
            end_date = datetime.now().strftime('%Y-%m-%d')
            start_date = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
            
            response = ce.get_cost_and_usage(
                TimePeriod={'Start': start_date, 'End': end_date},
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
            total_cost += cost
            
        except Exception as e:
            cost = 0
            print(f"Error getting cost for {account_id}: {e}")
        
        account_status.append({
            'account_id': account_id,
            'name': account_name,
            'email': account_email,
            'status': account_status_val,
            'joined_date': joined_date.isoformat(),
            'cost': cost,
            'cost_status': 'WARNING' if cost > 15 else 'OK'
        })
    
    return {
        'workshop_info': {
            'total_accounts': len(accounts['Accounts']),
            'active_accounts': len([a for a in account_status if a['status'] == 'ACTIVE']),
            'total_cost': total_cost,
            'last_updated': datetime.now().isoformat()
        },
        'accounts': account_status
    }

def generate_workshop_report():
    """Generate comprehensive workshop report"""
    status = get_workshop_status()
    
    report = f"""
# Workshop Status Report
Generated: {status['workshop_info']['last_updated']}

## Summary
- Total Accounts: {status['workshop_info']['total_accounts']}
- Active Accounts: {status['workshop_info']['active_accounts']}
- Total Cost: ${status['workshop_info']['total_cost']:.2f}

## Account Details
"""
    
    for account in status['accounts']:
        report += f"""
### {account['name']} ({account['email']})
- Account ID: {account['account_id']}
- Status: {account['status']}
- Cost: ${account['cost']:.2f} ({account['cost_status']})
- Joined: {account['joined_date']}
"""
    
    return report

def monitor_student_activity():
    """Monitor student activity across all accounts"""
    organizations = boto3.client('organizations')
    cloudwatch = boto3.client('cloudwatch')
    
    workshop_ou_id = os.environ.get('WORKSHOP_OU_ID')
    accounts = organizations.list_accounts_for_parent(
        ParentId=workshop_ou_id
    )
    
    activity_report = []
    
    for account in accounts['Accounts']:
        account_id = account['Id']
        account_name = account['Name']
        
        # Get recent activity metrics
        try:
            # Check EC2 instances
            ec2_metrics = cloudwatch.get_metric_statistics(
                Namespace='AWS/EC2',
                MetricName='CPUUtilization',
                Dimensions=[{'Name': 'InstanceId', 'Value': 'i-*'}],
                StartTime=datetime.now() - timedelta(hours=1),
                EndTime=datetime.now(),
                Period=300,
                Statistics=['Average']
            )
            
            # Check Lambda invocations
            lambda_metrics = cloudwatch.get_metric_statistics(
                Namespace='AWS/Lambda',
                MetricName='Invocations',
                StartTime=datetime.now() - timedelta(hours=1),
                EndTime=datetime.now(),
                Period=300,
                Statistics=['Sum']
            )
            
            activity_report.append({
                'account_id': account_id,
                'account_name': account_name,
                'ec2_activity': len(ec2_metrics['Datapoints']),
                'lambda_activity': sum([dp['Sum'] for dp in lambda_metrics['Datapoints']]),
                'last_activity': max([dp['Timestamp'] for dp in ec2_metrics['Datapoints']] + 
                                   [dp['Timestamp'] for dp in lambda_metrics['Datapoints']], 
                                   default=datetime.now())
            })
            
        except Exception as e:
            print(f"Error monitoring activity for {account_id}: {e}")
    
    return activity_report

if __name__ == "__main__":
    status = get_workshop_status()
    print(json.dumps(status, indent=2))
