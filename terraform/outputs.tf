output "vpc_id" {
  description = "ID of the platform VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets hosting the EKS cluster and nodes."
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API endpoint for the EKS cluster."
  value       = aws_eks_cluster.main.endpoint
}

output "ecr_repository_url" {
  description = "URL of the private ECR repository."
  value       = aws_ecr_repository.main.repository_url
}
