# IaC Template Project (Terragrunt + Terraform)

This project is an extensible IaC template for managing multi-cloud, multi-organization infrastructure.

## Architecture

The project follows the standard Terragrunt directory structure for maximum DRYness and modularity:

```text
.
├── _envcommon/             # Common configurations for all environments
├── modules/                # Custom Terraform modules
├── TestOrg/                # Organization level
│   └── aws/                # Cloud provider level
│       └── us-east-1/      # Region level
│           └── TestProj/   # Project level
│               ├── dev/    # Environment level
│               └── prod/   # Environment level
├── terragrunt.hcl          # Root configuration (remote state, providers)
└── .github/workflows/      # CI/CD pipelines
```

## Features & Requirements Fulfilled

- **S3 Bucket per Project Env**: Defined in `_envcommon/s3.hcl` and instantiated in both `dev` and `prod`.
- **Parameter Store (SSM)**: Custom module in `modules/ssm-parameters` to keep secret strings.
- **EKS with Tiny Node Group**: Configured in `_envcommon/eks.hcl` using `t3.small` SPOT instances for cost efficiency.
- **RDS PostgreSQL with Standby**: Configured in `_envcommon/rds.hcl` with `multi_az = true` for high availability.
- **Networking (VPC)**: Supports both IPv4 and IPv6, including private and public subnets. Configured in `_envcommon/vpc.hcl`.
- **Cilium CNI**: Default AWS VPC CNI is disabled in EKS, and Cilium is installed via Helm in `modules/k8s-addons`.
- **S3 Native Locking**: Configured in the root `terragrunt.hcl` using `use_lockfile = true` for the S3 backend, eliminating the need for DynamoDB (requires Terraform 1.10+).
- **GitHub Secrets Flow**: Secrets from GitHub Actions (e.g., `DB_PASSWORD`) are passed as environment variables (`TF_VAR_...`) and automatically picked up by the SSM module.
- **Extensibility**: Easily add new Organizations, Projects, or Clouds by following the directory structure.

## How to use

### Prerequisites
- AWS Account
- Terraform >= 1.10.0
- Terragrunt >= 0.67.0

### Local Deployment
1. Update `aws_account_id` in `TestOrg/aws/account.hcl`.
2. Run `terragrunt run-all plan` from the root or a specific environment folder.
3. Run `terragrunt run-all apply` to deploy.

### GitHub Actions
1. Set up the following secrets in your GitHub repository:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `DB_PASSWORD`
   - `API_KEY`
2. Push to `main` to trigger an automatic reconciliation (apply).
3. Create a Pull Request to see the plan output.

## Extensibility Guide
- **New Environment**: Copy `dev` folder to a new name (e.g., `staging`) and update `env.hcl`.
- **New Project**: Create a new folder under `us-east-1/` and follow the `TestProj` structure.
- **New Cloud**: Create a folder (e.g., `azure/`) next to `aws/` and define cloud-specific common configs.
