resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  enabled_cluster_log_types = var.cluster_log_types

  vpc_config {
    subnet_ids = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]

    endpoint_private_access = true
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs = (
      var.cluster_endpoint_public_access
      ? var.cluster_endpoint_public_access_cidrs
      : null
    )
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster
  ]

  lifecycle {
    precondition {
      condition = (
        !var.cluster_endpoint_public_access ||
        length(var.cluster_endpoint_public_access_cidrs) > 0
      )
      error_message = "Set cluster_endpoint_public_access_cidrs to specific trusted CIDRs before enabling public endpoint access."
    }
  }

  tags = {
    Name = var.cluster_name
  }
}
