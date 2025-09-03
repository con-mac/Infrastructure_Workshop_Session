# Sample Application
## IT Infrastructure Workshop - University Apprenticeship Programme

This directory contains a simple web application that demonstrates the 3-tier architecture deployed during the workshop.

---

## Application Overview

### Purpose
This sample application serves as a demonstration of:
- Web application deployment on cloud infrastructure
- Health monitoring and status reporting
- Integration with infrastructure components
- Workshop learning objectives

### Features
- **Responsive Web Interface:** Modern HTML5/CSS3/JavaScript
- **Health Monitoring:** Detailed health check endpoints
- **System Information:** Server and environment details
- **Workshop Integration:** Educational content and objectives
- **Status Reporting:** Real-time system status

---

## File Structure

```
sample-app/
├── index.html          # Main application interface
├── health.php          # Detailed health check endpoint
├── status              # Simple status endpoint
└── README.md           # This file
```

---

## Application Components

### 1. Main Interface (`index.html`)

**Features:**
- Responsive design with modern CSS
- Workshop information and objectives
- Architecture overview
- Technology stack display
- System status dashboard
- Quick command reference
- Useful links and resources

**Technologies:**
- HTML5 semantic markup
- CSS3 with flexbox and grid
- JavaScript for dynamic content
- Responsive design principles

### 2. Health Check (`health.php`)

**Purpose:** Comprehensive health monitoring endpoint

**Checks:**
- System resources (disk, memory, load)
- Application components (Apache, PHP)
- File system permissions
- Database connectivity (placeholder)
- Overall system health

**Response Format:**
```json
{
  "status": "healthy|degraded|unhealthy",
  "timestamp": "2024-10-03T12:00:00Z",
  "server_info": { ... },
  "system_checks": { ... },
  "application_checks": { ... },
  "issues": [ ... ]
}
```

### 3. Status Endpoint (`status`)

**Purpose:** Simple status reporting for load balancer health checks

**Features:**
- Lightweight JSON response
- Basic service information
- Performance metrics
- Workshop context

---

## Deployment Integration

### Infrastructure Integration

**Web Server Configuration:**
- Apache HTTP Server
- PHP 7.4+ with required extensions
- Document root: `/var/www/html`
- Health check endpoints configured

**Load Balancer Health Checks:**
- Path: `/health`
- Expected response: HTTP 200
- Timeout: 5 seconds
- Interval: 30 seconds

**Auto Scaling Integration:**
- Health check type: ELB
- Grace period: 300 seconds
- Launch template with user data

### Database Integration

**Connection Details:**
- Host: RDS endpoint (from Terraform outputs)
- Database: `workshopdb`
- Username: `admin`
- Password: From Terraform variables

**Note:** Database connection is configured in the user data script but not actively used in this demo application.

---

## Usage Examples

### Accessing the Application

**Main Interface:**
```bash
# Get application URL from Terraform
terraform output application_url

# Access in browser
open http://your-alb-dns-name
```

**Health Check:**
```bash
# Simple health check
curl http://your-alb-dns-name/health

# Detailed health information
curl -s http://your-alb-dns-name/health | jq '.'
```

**Status Endpoint:**
```bash
# Simple status
curl http://your-alb-dns-name/status

# Pretty formatted
curl -s http://your-alb-dns-name/status | jq '.'
```

### Testing Application

**Load Testing:**
```bash
# Simple load test
for i in {1..10}; do
  curl -s http://your-alb-dns-name/health > /dev/null
  echo "Request $i completed"
done
```

**Health Monitoring:**
```bash
# Continuous health monitoring
watch -n 5 'curl -s http://your-alb-dns-name/health | jq ".status"'
```

---

## Workshop Integration

### Learning Objectives

**Students Will Learn:**
1. **Web Application Deployment:** How applications are deployed on cloud infrastructure
2. **Health Monitoring:** Importance of health checks and monitoring
3. **Load Balancer Integration:** How applications integrate with load balancers
4. **Auto Scaling:** How applications respond to scaling events
5. **Monitoring:** Real-time system and application monitoring

### Workshop Tasks

**Infrastructure Team:**
- Deploy the infrastructure using Terraform
- Configure load balancer health checks
- Set up auto scaling based on health
- Monitor application performance

**DevOps Team (Future Session):**
- Containerize the application
- Set up CI/CD pipelines
- Implement blue-green deployments
- Add advanced monitoring and alerting

---

## Customization

### Adding Features

**Database Integration:**
```php
// Add to health.php
try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $application_checks['database']['status'] = 'connected';
} catch(PDOException $e) {
    $application_checks['database']['status'] = 'error';
    $application_checks['database']['error'] = $e->getMessage();
}
```

**Custom Metrics:**
```php
// Add custom application metrics
$custom_metrics = [
    'active_users' => get_active_user_count(),
    'requests_today' => get_daily_request_count(),
    'average_response_time' => get_average_response_time()
];
```

**Additional Endpoints:**
```php
// Create new endpoint files
// api.php - REST API endpoints
// metrics.php - Prometheus metrics
// admin.php - Administrative interface
```

---

## Security Considerations

### Current Implementation
- ✅ No sensitive data exposure
- ✅ Input validation on health checks
- ✅ Proper HTTP status codes
- ✅ Error logging without information leakage

### Recommendations for Production
- Implement authentication for admin endpoints
- Add rate limiting for health checks
- Use HTTPS for all communications
- Implement proper logging and monitoring
- Add security headers (CSP, HSTS, etc.)

---

## Monitoring and Observability

### Metrics Available

**System Metrics:**
- CPU usage and load average
- Memory usage and limits
- Disk space and I/O
- Network connectivity

**Application Metrics:**
- Response times
- Request counts
- Error rates
- Health check status

**Infrastructure Metrics:**
- Load balancer health
- Auto scaling events
- Database connectivity
- Security group rules

### CloudWatch Integration

**Custom Metrics:**
```bash
# Send custom metrics to CloudWatch
aws cloudwatch put-metric-data \
  --namespace "Workshop/Application" \
  --metric-data MetricName=ResponseTime,Value=45,Unit=Milliseconds
```

**Logs:**
- Application logs: `/var/log/httpd/`
- System logs: `/var/log/messages`
- Workshop logs: `/var/log/workshop-*.log`

---

## Troubleshooting

### Common Issues

**1. Application Not Loading:**
```bash
# Check Apache status
sudo systemctl status httpd

# Check logs
sudo tail -f /var/log/httpd/error_log

# Test configuration
sudo httpd -t
```

**2. Health Check Failures:**
```bash
# Test health endpoint directly
curl -v http://localhost/health

# Check PHP errors
sudo tail -f /var/log/httpd/error_log

# Verify file permissions
ls -la /var/www/html/
```

**3. Load Balancer Issues:**
```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn your-tg-arn

# Check security group rules
aws ec2 describe-security-groups --group-ids your-sg-id
```

### Debug Commands

**Application Debugging:**
```bash
# Check PHP configuration
php -m
php -i | grep -E "(mysql|curl|json)"

# Test database connection
php -r "echo 'PHP version: ' . phpversion() . PHP_EOL;"

# Check file permissions
find /var/www/html -type f -exec ls -la {} \;
```

**Infrastructure Debugging:**
```bash
# Check instance status
aws ec2 describe-instances --instance-ids your-instance-id

# Check load balancer
aws elbv2 describe-load-balancers --names your-alb-name

# Check auto scaling
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names your-asg-name
```

---

## Performance Optimization

### Current Optimizations
- ✅ Gzip compression enabled
- ✅ Browser caching headers
- ✅ Optimized CSS and JavaScript
- ✅ Efficient database queries (when implemented)

### Additional Recommendations
- Implement Redis for session storage
- Add CDN for static assets
- Use database connection pooling
- Implement application-level caching
- Add performance monitoring

---

## Future Enhancements

### Planned Features
- [ ] Database integration with sample data
- [ ] User authentication and sessions
- [ ] REST API endpoints
- [ ] Real-time metrics dashboard
- [ ] Container deployment support
- [ ] CI/CD pipeline integration

### DevOps Integration
- [ ] Docker containerization
- [ ] Kubernetes deployment manifests
- [ ] Helm charts for deployment
- [ ] Prometheus metrics export
- [ ] Grafana dashboards
- [ ] Automated testing

---

## Resources

### Documentation
- [Apache HTTP Server](https://httpd.apache.org/docs/)
- [PHP Documentation](https://www.php.net/docs.php)
- [AWS Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Tools
- [cURL](https://curl.se/docs/)
- [jq](https://stedolan.github.io/jq/)
- [Apache Bench](https://httpd.apache.org/docs/2.4/programs/ab.html)

### Support
- Workshop Instructors: [Your Email]
- DevOps Team: [DevOps Email]
- GitHub Issues: [Repository Issues]

---

## Next Steps

1. **Deploy Infrastructure:** Use Terraform to deploy the 3-tier architecture
2. **Test Application:** Verify the application works correctly
3. **Monitor Performance:** Check CloudWatch metrics and logs
4. **Join DevOps Session:** Learn about containerization and CI/CD
5. **Practice More:** Try additional features and optimizations
6. **Clean Up:** Destroy resources when done

---

**Happy Learning! 🚀**
