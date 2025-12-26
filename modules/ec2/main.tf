# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
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

# META-ARGUMENT EXAMPLE: depends_on
# EC2 instances depend on VPC subnet creation
# This ensures resources are created in the correct order

resource "aws_instance" "main" {
  count                = var.instance_count
  ami                  = data.aws_ami.amazon_linux_2.id
  instance_type        = var.instance_type
  subnet_id            = var.subnet_ids[count.index % length(var.subnet_ids)]
  security_groups      = var.security_group_ids
  iam_instance_profile = aws_iam_instance_profile.main.name
  key_name             = var.key_pair_name != "" ? var.key_pair_name : null

  # META-ARGUMENT: depends_on
  # Explicitly state dependencies (usually implicit through references)
  depends_on = [
    aws_iam_role.main
  ]

  # User data script
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    instance_index = count.index + 1
    environment    = var.environment
    project_name   = var.project_name
  }))

  # META-ARGUMENT: lifecycle
  # Ignore changes to tags after creation
  lifecycle {
    ignore_changes = [
      tags["LastModified"]
    ]
  }

  tags = {
    Name = "${var.project_name}-ec2-${count.index + 1}"
  }
}

# Check if IAM role already exists
data "aws_iam_role" "existing" {
  name = "${var.project_name}-e"
}

# IAM role for EC2 instances - only create if it doesn't exist
resource "aws_iam_role" "main" {
  count = data.aws_iam_role.existing.arn == null ? 1 : 0
  name  = "${var.project_name}-e"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# IAM instance profile - use existing if available, otherwise create
resource "aws_iam_instance_profile" "main" {
  name = "${var.project_name}-ec2-profile"
  role = try(aws_iam_role.main[0].name, data.aws_iam_role.existing.name)

  lifecycle {
    ignore_changes = all
  }
}
