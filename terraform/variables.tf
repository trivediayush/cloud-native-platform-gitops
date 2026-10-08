variable "aws_region" {
  description = "AWS region in which to deploy the platform."
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project identifier used for resource tags."
  type        = string
  default     = "cloud-native-platform"
}

variable "environment" {
  description = "Environment name used for resource tags."
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "cloud-native-platform-eks-cluster"
}

variable "ecr_repository_name" {
  description = "Name of the private ECR repository."
  type        = string
  default     = "cloud-native-platform-app"
}

variable "aws_vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.aws_vpc_cidr))
    error_message = "aws_vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "subnet_cidr_public_1" {
  description = "IPv4 CIDR block for the first public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_cidr_public_2" {
  description = "IPv4 CIDR block for the second public subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_cidr_private_1" {
  description = "IPv4 CIDR block for the first private subnet."
  type        = string
  default     = "10.0.3.0/24"
}

variable "subnet_cidr_private_2" {
  description = "IPv4 CIDR block for the second private subnet."
  type        = string
  default     = "10.0.4.0/24"
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS managed node group."
  type        = list(string)
  default     = ["t3.small"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "node_instance_types must contain at least one instance type."
  }
}

variable "node_min_size" {
  description = "Minimum number of nodes in the managed node group."
  type        = number
  default     = 1

  validation {
    condition     = var.node_min_size >= 1
    error_message = "node_min_size must be at least 1."
  }
}

variable "node_desired_size" {
  description = "Desired number of nodes in the managed node group."
  type        = number
  default     = 2

  validation {
    condition     = var.node_desired_size >= 1
    error_message = "node_desired_size must be at least 1."
  }
}

variable "node_max_size" {
  description = "Maximum number of nodes in the managed node group."
  type        = number
  default     = 3

  validation {
    condition     = var.node_max_size >= 1
    error_message = "node_max_size must be at least 1."
  }
}

variable "cluster_endpoint_public_access" {
  description = "Whether the Kubernetes API endpoint is reachable from public networks. Keep disabled unless required."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "IPv4 CIDRs allowed to reach the public Kubernetes API endpoint when public access is enabled."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.cluster_endpoint_public_access_cidrs :
      can(cidrnetmask(cidr)) && cidr != "0.0.0.0/0"
    ])
    error_message = "Each public endpoint CIDR must be valid and must not allow all IPv4 addresses (0.0.0.0/0)."
  }
}

variable "cluster_log_types" {
  description = "EKS control-plane log types to publish to CloudWatch Logs."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "tags" {
  description = "Additional tags to apply to all supported resources."
  type        = map(string)
  default     = {}
}
