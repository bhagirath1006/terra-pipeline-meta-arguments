# Meta-Arguments Pipeline

A Terraform demonstration project showcasing meta-arguments: `count`, `for_each`, `depends_on`, and `lifecycle`.

## Project Structure

- **main.tf**: Root module orchestration
- **provider.tf**: AWS provider and data sources
- **variables.tf**: Input variables with validation
- **terraform.tfvars**: Variable values (example configuration)
- **outputs.tf**: Output definitions
- **modules/**: Reusable Terraform modules
  - **vpc/**: VPC and networking resources (count example)
  - **security_group/**: Security groups (for_each example)
  - **ec2/**: EC2 instances (depends_on example)
  - **s3/**: S3 buckets (for_each and lifecycle example)

## Prerequisites

- AWS Account with appropriate credentials
- Terraform >= 1.0
- AWS credentials configured (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd terraform-pipeline-clean
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review the Plan

```bash
terraform plan -var-file=terraform.tfvars
```

### 4. Apply Configuration

```bash
terraform apply -auto-approve -var-file=terraform.tfvars
```

### 5. Destroy Resources

```bash
terraform destroy -auto-approve -var-file=terraform.tfvars
```

## Configuration

Update `terraform.tfvars` to customize:
- `aws_region`: Target AWS region
- `project_name`: Project identifier
- `environment`: Deployment environment
- `vpc_count`: Number of VPCs to create
- `ec2_instance_count`: Number of EC2 instances
- `security_groups`: Security group configurations
- `s3_buckets`: S3 bucket configurations

## GitHub Actions Workflow

The `.github/workflows/terraform.yml` file defines a CI/CD pipeline that:

1. Checks out code
2. Initializes Terraform
3. Validates configuration
4. Plans changes
5. Applies changes (on main branch push only)

### Required GitHub Secrets

- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

## Outputs

After applying, outputs include:
- VPC IDs
- Security Group IDs
- EC2 Instance IDs
- S3 Bucket Names

## Meta-Arguments Examples

### COUNT - VPC Module
Creates multiple VPCs based on `vpc_count` variable using index-based iteration.

### FOR_EACH - Security Groups & S3
Creates resources from map objects, useful for creating multiple similar resources with different configurations.

### DEPENDS_ON - EC2 Module
Explicitly defines resource dependencies, ensuring proper creation order.

### LIFECYCLE - VPC & EC2
Controls resource lifecycle behavior (creation, modification, destruction).

## Notes

- All resources are tagged with environment and project information
- S3 buckets have versioning and encryption enabled
- Security groups allow HTTP/HTTPS and database access
- EC2 instances run Amazon Linux 2

## License

MIT
