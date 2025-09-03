#!/bin/bash
# User Data Script for Web Servers
# IT Infrastructure Workshop - University Apprenticeship Programme

# Update system packages
yum update -y

# Install required packages
yum install -y httpd php php-mysqlnd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple web application
cat > /var/www/html/index.php << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>IT Infrastructure Workshop</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f4f4; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; color: #333; border-bottom: 2px solid #007cba; padding-bottom: 20px; }
        .info { margin: 20px 0; padding: 15px; background: #e8f4f8; border-left: 4px solid #007cba; }
        .success { color: #28a745; font-weight: bold; }
        .warning { color: #ffc107; font-weight: bold; }
        .error { color: #dc3545; font-weight: bold; }
        .code { background: #f8f9fa; padding: 10px; border-radius: 4px; font-family: monospace; margin: 10px 0; }
        .footer { text-align: center; margin-top: 30px; color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 IT Infrastructure Workshop</h1>
            <h2>University Apprenticeship Programme</h2>
        </div>
        
        <div class="info">
            <h3>✅ Infrastructure Successfully Deployed!</h3>
            <p>Congratulations! You have successfully deployed a 3-tier architecture using Infrastructure as Code.</p>
        </div>
        
        <div class="info">
            <h3>📊 System Information</h3>
            <p><strong>Student:</strong> <?php echo $_SERVER['HTTP_X_STUDENT_NAME'] ?? 'Not Set'; ?></p>
            <p><strong>Environment:</strong> <?php echo $_SERVER['HTTP_X_ENVIRONMENT'] ?? 'Not Set'; ?></p>
            <p><strong>Server:</strong> <?php echo gethostname(); ?></p>
            <p><strong>Timestamp:</strong> <?php echo date('Y-m-d H:i:s T'); ?></p>
            <p><strong>PHP Version:</strong> <?php echo phpversion(); ?></p>
        </div>
        
        <div class="info">
            <h3>🏗️ Architecture Overview</h3>
            <p>Your infrastructure includes:</p>
            <ul>
                <li><strong>Web Tier:</strong> Application Load Balancer + Auto Scaling Group</li>
                <li><strong>Application Tier:</strong> EC2 instances running Apache/PHP</li>
                <li><strong>Database Tier:</strong> RDS MySQL instance</li>
                <li><strong>Networking:</strong> VPC with public and private subnets</li>
                <li><strong>Security:</strong> Security groups with least privilege access</li>
                <li><strong>Monitoring:</strong> CloudWatch dashboard and metrics</li>
            </ul>
        </div>
        
        <div class="info">
            <h3>🔧 What You've Learned</h3>
            <ul>
                <li>Infrastructure as Code with Terraform</li>
                <li>3-tier architecture design</li>
                <li>AWS services integration</li>
                <li>Security best practices</li>
                <li>Monitoring and observability</li>
                <li>Multi-environment deployment</li>
            </ul>
        </div>
        
        <div class="info">
            <h3>🎯 Next Steps</h3>
            <ol>
                <li>Test your application functionality</li>
                <li>Check the CloudWatch dashboard for metrics</li>
                <li>Explore the AWS Console to see your resources</li>
                <li>Join the DevOps session for application deployment</li>
                <li>Practice with additional AWS services</li>
                <li>Remember to clean up resources when done!</li>
            </ol>
        </div>
        
        <div class="code">
            <strong>Cleanup Command:</strong><br>
            terraform destroy
        </div>
        
        <div class="footer">
            <p>IT Infrastructure Workshop | University Apprenticeship Programme | October 2024</p>
        </div>
    </div>
</body>
</html>
EOF

# Create health check endpoint
cat > /var/www/html/health.php << 'EOF'
<?php
header('Content-Type: application/json');

$health = [
    'status' => 'healthy',
    'timestamp' => date('c'),
    'server' => gethostname(),
    'php_version' => phpversion(),
    'checks' => [
        'apache' => 'running',
        'php' => 'working',
        'disk_space' => disk_free_space('/') > 1000000000 ? 'ok' : 'low',
        'memory' => memory_get_usage(true) < 100000000 ? 'ok' : 'high'
    ]
];

echo json_encode($health, JSON_PRETTY_PRINT);
?>
EOF

# Create a simple health check endpoint
cat > /var/www/html/health << 'EOF'
OK
EOF

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Configure Apache to show server info (for workshop purposes only)
echo "ServerTokens Prod" >> /etc/httpd/conf/httpd.conf
echo "ServerSignature Off" >> /etc/httpd/conf/httpd.conf

# Create a simple database connection test (will be used in DevOps session)
cat > /var/www/html/db_test.php << 'EOF'
<?php
// Database connection test
// This will be used in the DevOps session

$host = '${db_endpoint}';
$dbname = 'workshopdb';
$username = 'admin';
$password = '${db_password}';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Database connection successful!";
} catch(PDOException $e) {
    echo "Database connection failed: " . $e->getMessage();
}
?>
EOF

# Install CloudWatch agent for monitoring
yum install -y amazon-cloudwatch-agent

# Create CloudWatch agent configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "metrics": {
        "namespace": "Workshop/EC2",
        "metrics_collected": {
            "cpu": {
                "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": ["used_percent"],
                "metrics_collection_interval": 60,
                "resources": ["*"]
            },
            "mem": {
                "measurement": ["mem_used_percent"],
                "metrics_collection_interval": 60
            }
        }
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/httpd/access_log",
                        "log_group_name": "workshop-apache-access",
                        "log_stream_name": "{instance_id}"
                    },
                    {
                        "file_path": "/var/log/httpd/error_log",
                        "log_group_name": "workshop-apache-error",
                        "log_stream_name": "{instance_id}"
                    }
                ]
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# Create a simple log entry
echo "$(date): Web server initialized for student ${student_name} in environment ${environment}" >> /var/log/workshop-init.log

# Set up log rotation for workshop logs
cat > /etc/logrotate.d/workshop << 'EOF'
/var/log/workshop-init.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF

# Create a simple status page for monitoring
cat > /var/www/html/status << 'EOF'
{
    "status": "running",
    "service": "apache",
    "version": "2.4",
    "uptime": "unknown",
    "workshop": "IT Infrastructure Workshop"
}
EOF

# Restart Apache to ensure all configurations are loaded
systemctl restart httpd

# Create a completion marker
touch /var/log/workshop-complete.log
echo "$(date): Workshop infrastructure setup completed successfully" >> /var/log/workshop-complete.log

# Log the completion
logger "IT Infrastructure Workshop: Web server setup completed for student ${student_name}"
