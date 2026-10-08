# Terraform deployment

This directory is the Terraform root module. Run Terraform commands from this
directory; the resource files are deliberately kept together so they are part
of the root configuration.

## Prerequisites

- Terraform 1.10 or later.
- AWS credentials with permissions to create the VPC, EKS, ECR, and IAM
  resources defined here.
- An S3 bucket named `cloud-native-platform-tfstate` in `eu-west-2`, created
  before `terraform init`. Enable versioning, block all public access, and
  restrict bucket access to the Terraform operators/CI role. The S3 backend
  uses server-side encryption and Terraform's S3 lockfile for state locking.
- Connectivity from the operator to the VPC for `kubectl`: the EKS API endpoint
  is private by default. If public access is required, enable it in
  `terraform.tfvars` and set `cluster_endpoint_public_access_cidrs` to trusted
  public IPv4 CIDRs (never `0.0.0.0/0`).

Copy `terraform.tfvars.example` to `terraform.tfvars` and adjust the values.
The real `.tfvars` file is ignored by Git.

## Commands

```shell
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

The single NAT gateway reduces cost but is a network egress single point of
failure for workloads in the private subnets. For production requiring
availability across Availability Zones, use one NAT gateway per zone and
associate each private subnet with its zone-local NAT gateway.
