# GitHub Actions Workflows
## IT Infrastructure Workshop - University Apprenticeship Programme

This directory contains GitHub Actions workflows for the IT Infrastructure Workshop. These workflows demonstrate CI/CD practices for infrastructure management and provide integration points for the DevOps team.

---

## Workflow Overview

### Infrastructure Team Workflows

#### 1. `terraform-plan.yml`
**Purpose:** Plan infrastructure changes on pull requests

**Triggers:**
- Pull requests to `main` or `develop` branches
- Changes to `terraform/` directory or workflow files

**Features:**
- Multi-environment planning (dev, staging, prod)
- Terraform format checking
- Terraform validation
- Security scanning with Trivy
- Cost estimation
- PR comments with plan details

**Usage:**
```bash
# Create a pull request with infrastructure changes
git checkout -b feature/new-infrastructure
# Make changes to terraform files
git add .
git commit -m "Add new infrastructure components"
git push origin feature/new-infrastructure
# Create pull request - workflow will run automatically
```

#### 2. `terraform-apply.yml`
**Purpose:** Apply infrastructure changes after PR approval

**Triggers:**
- Push to `main` branch
- Changes to `terraform/` directory or workflow files

**Features:**
- Multi-environment deployment
- Infrastructure health checks
- Output generation for DevOps team
- Status reporting

**Usage:**
```bash
# Merge approved pull request
git checkout main
git merge feature/new-infrastructure
git push origin main
# Workflow will deploy to all environments
```

#### 3. `terraform-destroy.yml`
**Purpose:** Destroy infrastructure resources to prevent costs

**Triggers:**
- Manual workflow dispatch only
- Requires confirmation input

**Features:**
- Environment selection
- Confirmation requirement
- Resource cleanup verification
- Cost savings reporting

**Usage:**
```bash
# Go to GitHub Actions tab
# Select "Terraform Destroy" workflow
# Click "Run workflow"
# Select environment (dev/staging/prod)
# Type "DESTROY" to confirm
# Click "Run workflow"
```

### DevOps Integration Workflow

#### 4. `devops-integration.yml`
**Purpose:** Integration point for DevOps team application deployment

**Features:**
- Reusable workflow
- Infrastructure information passing
- Application deployment placeholder
- Team notifications

**Usage by DevOps Team:**
```yaml
# In DevOps repository workflow
jobs:
  deploy-app:
    uses: ./.github/workflows/devops-integration.yml
    with:
      environment: 'prod'
      infrastructure_ready: true
    secrets: inherit
```

---

## Workflow Integration Points

### Infrastructure → DevOps Handoff

**Infrastructure Outputs Available:**
```yaml
# From terraform-apply.yml
outputs:
  alb_dns_name: "Load balancer DNS name"
  db_endpoint: "Database endpoint"
  vpc_id: "VPC ID"
  application_url: "Application URL"
```

**DevOps Team Receives:**
- Load balancer DNS name for application deployment
- Database endpoint for application configuration
- VPC ID for network configuration
- Security group IDs for access rules

### DevOps → Infrastructure Feedback

**DevOps Team Provides:**
- Application deployment status
- Health check results
- Performance metrics
- Error logs and troubleshooting information

---

## Security and Permissions

### Required Secrets

**AWS Credentials:**
```yaml
AWS_ROLE_ARN: "arn:aws:iam::123456789012:role/GitHubActionsRole"
```

**GitHub Token:**
```yaml
GITHUB_TOKEN: "Automatically provided by GitHub"
```

### IAM Role Permissions

**Required AWS Permissions:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "rds:*",
        "elbv2:*",
        "autoscaling:*",
        "cloudwatch:*",
        "iam:PassRole",
        "sts:AssumeRole"
      ],
      "Resource": "*"
    }
  ]
}
```

### Security Best Practices

**Implemented:**
- ✅ OIDC authentication (no long-lived credentials)
- ✅ Least privilege IAM roles
- ✅ Environment-specific deployments
- ✅ Security scanning with Trivy
- ✅ Cost monitoring and alerts

**Additional Recommendations:**
- Use AWS Secrets Manager for sensitive data
- Enable VPC Flow Logs
- Set up AWS Config for compliance
- Implement AWS WAF for web protection
- Use AWS Certificate Manager for SSL/TLS

---

## Environment Management

### Environment Strategy

**Development (dev):**
- Small instances (t2.micro)
- Minimal resources
- Auto-shutdown enabled
- Short backup retention

**Staging:**
- Medium instances (t2.small)
- Production-like configuration
- Extended monitoring
- Regular backup retention

**Production (prod):**
- Larger instances (t2.medium+)
- High availability
- Comprehensive monitoring
- Long backup retention
- No auto-shutdown

### Environment Promotion

```
Feature Branch → Dev → Staging → Production
     ↓            ↓        ↓         ↓
   Plan        Apply    Apply     Apply
   Test        Test     Test      Monitor
```

---

## Monitoring and Observability

### Workflow Monitoring

**GitHub Actions Insights:**
- Workflow run history
- Performance metrics
- Failure analysis
- Resource usage

**AWS CloudWatch:**
- Infrastructure metrics
- Application logs
- Custom dashboards
- Alarms and notifications

### Health Checks

**Infrastructure Health:**
- Load balancer status
- Database connectivity
- Auto Scaling Group health
- Security group rules

**Application Health:**
- HTTP response codes
- Response times
- Error rates
- Database queries

---

## Cost Management

### Cost Optimization Features

**Implemented:**
- Environment-specific instance sizes
- Auto-shutdown for non-production
- Resource tagging for cost tracking
- Cost estimation in PR comments

**Monitoring:**
- AWS Budgets with alerts
- CloudWatch billing metrics
- Regular cost reviews
- Resource cleanup automation

### Estimated Costs

| Environment | Monthly Cost | Notes |
|-------------|--------------|-------|
| Dev | ~$20 | Auto-shutdown enabled |
| Staging | ~$35 | Limited hours |
| Production | ~$50 | 24/7 operation |

---

## Troubleshooting

### Common Issues

**1. Authentication Failures:**
```bash
# Check IAM role configuration
aws sts get-caller-identity

# Verify OIDC provider setup
aws iam get-open-id-connect-provider --open-id-connect-provider-arn arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com
```

**2. Terraform State Issues:**
```bash
# Check state file location
terraform state list

# Refresh state
terraform refresh

# Import existing resources
terraform import aws_instance.example i-1234567890abcdef0
```

**3. Workflow Failures:**
```bash
# Check workflow logs in GitHub Actions
# Verify required secrets are set
# Check AWS service limits
# Review IAM permissions
```

### Debug Commands

**Infrastructure Debugging:**
```bash
# Check resource status
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name]'
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]'
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,State.Code]'
```

**Application Debugging:**
```bash
# Test load balancer
curl -I http://your-alb-dns-name

# Check health endpoints
curl http://your-alb-dns-name/health
curl http://your-alb-dns-name/status
```

---

## Best Practices

### Infrastructure as Code

**Terraform Best Practices:**
- Use modules for reusable components
- Implement proper variable validation
- Use remote state with locking
- Regular state file backups
- Version pinning for providers

**Git Workflow:**
- Feature branches for changes
- Pull request reviews required
- Automated testing and validation
- Clear commit messages
- Regular rebasing

### CI/CD Best Practices

**Pipeline Design:**
- Fast feedback loops
- Parallel execution where possible
- Environment promotion strategy
- Rollback capabilities
- Comprehensive testing

**Security:**
- Least privilege access
- Secret management
- Regular security scans
- Audit logging
- Compliance monitoring

---

## Integration with DevOps Session

### Handoff Checklist

**Infrastructure Team Completes:**
- [ ] VPC and networking setup
- [ ] Security groups and IAM roles
- [ ] Database and storage provisioning
- [ ] Load balancer configuration
- [ ] Basic monitoring setup
- [ ] Cost optimization features

**DevOps Team Receives:**
- [ ] Infrastructure outputs and endpoints
- [ ] Security group IDs for application access
- [ ] Database connection details
- [ ] Load balancer DNS name
- [ ] VPC and subnet information

**DevOps Team Implements:**
- [ ] Application container deployment
- [ ] CI/CD pipelines for application code
- [ ] Application monitoring and alerting
- [ ] Blue-green deployment strategy
- [ ] Application health checks
- [ ] Performance optimization

---

## Resources

### Documentation
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### Tools
- [Terraform](https://terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- [GitHub Actions](https://github.com/features/actions)

### Support
- Workshop Instructors: [Your Email]
- DevOps Team: [DevOps Email]
- GitHub Issues: [Repository Issues]

---

## Next Steps

1. **Complete Infrastructure Setup:** Deploy the 3-tier architecture
2. **Test Workflows:** Run through the CI/CD pipeline
3. **Handoff to DevOps:** Provide infrastructure outputs
4. **Monitor and Optimize:** Track costs and performance
5. **Clean Up:** Destroy resources when done

---

**Happy Learning! 🚀**
