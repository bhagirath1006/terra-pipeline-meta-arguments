aws_region         = "us-east-1"
environment        = "dev"
project_name       = "meta-arguments-pipeline"
vpc_count          = 2
ec2_instance_count = 2

security_groups = {
  app = {
    description = "Application security group"
    ingress = [
      {
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        protocol    = "tcp"
        from_port   = 443
        to_port     = 443
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
  database = {
    description = "Database security group"
    ingress = [
      {
        protocol    = "tcp"
        from_port   = 5432
        to_port     = 5432
        cidr_blocks = ["10.0.0.0/8"]
      }
    ]
  }
}

s3_buckets = {
  logs = {
    versioning = true
  }
  backups = {
    versioning = true
  }
}
