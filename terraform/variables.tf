variable "aws_region" {
    description = "The AWS region to deploy resources in."
    type        = string
    default    = "eu-west-2"
}

variable "aws_vpc_cidr" {
    description = "The CIDR block for the VPC."
    type        = string
    default     = "10.0.0.0/16"
}

variable "subnet_cidr_public_1" {
    description = "The CIDR block for the public subnet."
    type        = string
    default     = "10.0.1.0/24"
}

variable "subnet_cidr_public_2" {
    description = "The CIDR block for the second public subnet."
    type        = string
    default     = "10.0.2.0/24"
}

variable "subnet_cidr_private_1" {
    description = "The CIDR block for the private subnet."
    type        = string
    default     = "10.0.3.0/24"
}

variable "subnet_cidr_private_2" {
    description = "The CIDR block for the second private subnet."
    type        = string
    default     = "10.0.4.0/24"
}

variable "instance_type" {
    description = "The EC2 instance type."
    type        = string
    default     = "t3.small"
}

variable "key_name" {
    description = "The name of the key pair to use for EC2 instances."
    type        = string
    default     = "London_Key.pem"
}

variable "ami_id" {
    description = "The ID of the AMI to use for EC2 instances."
    type        = string
    default     = "ami-0c55b159cbfafe1f0"
}
