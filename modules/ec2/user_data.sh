#!/bin/bash
set -e

echo "Initializing EC2 instance ${instance_index} in ${environment} environment"
echo "Project: ${project_name}"

# Update system
yum update -y

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Configure instance metadata
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

# Create log file
mkdir -p /var/log/terraform
cat > /var/log/terraform/init.log <<EOF
Instance initialized at $(date)
Instance ID: $INSTANCE_ID
Project: ${project_name}
Environment: ${environment}
Instance Index: ${instance_index}
EOF

echo "EC2 instance initialization completed"
