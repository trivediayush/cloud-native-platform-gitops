resource "aws_vpc" "platform-vpc" {
    cidr_block = var.aws_vpc_cidr
    enable_dns_support  = true
    enable_dns_hostnames = true

    tags = {
        Name = "platform-vpc"
    }
}

resource "aws_subnet" "public-subnet-1" {
    vpc_id = aws_vpc.platform-vpc.id
    cidr_block = var.subnet_cidr_public_1
    map_public_ip_on_launch = true
    availability_zone = "${var.aws_region}a"

    tags = {
        Name = "public-subnet-1"
    }
}

resource "aws_subnet" "public-subnet-2" {
    vpc_id = aws_vpc.platform-vpc.id
    cidr_block = var.subnet_cidr_public_2
    map_public_ip_on_launch = true
    availability_zone = "${var.aws_region}b"

    tags = {
        Name = "public-subnet-2"
    }
}

resource "aws_subnet" "private-subnet-1" {
    vpc_id = aws_vpc.platform-vpc.id
    cidr_block = var.subnet_cidr_private_1
    availability_zone = "${var.aws_region}a"

    tags = {
        Name = "private-subnet-1"
    }
}

resource "aws_subnet" "private-subnet-2" {
    vpc_id = aws_vpc.platform-vpc.id
    cidr_block = var.subnet_cidr_private_2
    availability_zone = "${var.aws_region}b"

    tags = {
        Name = "private-subnet-2"
    }
}

resource "aws_internet_gateway" "platform-igw" {
    vpc_id = aws_vpc.platform-vpc.id

    tags = {
        Name = "platform-igw"
    }
}

resource "aws_route_table" "public-rt" {
    vpc_id = aws_vpc.platform-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.platform-igw.id
    }

    tags = {
        Name = "public-rt"
    }
}

resource "aws_route_table_association" "public-subnet-1-association" {
    subnet_id      = aws_subnet.public-subnet-1.id
    route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-subnet-2-association" {
    subnet_id      = aws_subnet.public-subnet-2.id
    route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table" "private-rt" {
    vpc_id = aws_vpc.platform-vpc.id

    tags = {
        Name = "private-rt"
    }
}

resource "aws_route_table_association" "private-subnet-1-association" {
    subnet_id      = aws_subnet.private-subnet-1.id
    route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-subnet-2-association" {
    subnet_id      = aws_subnet.private-subnet-2.id
    route_table_id = aws_route_table.private-rt.id
}

resource "aws_eip" "nat-eip" {
    domain = "vpc"

    tags = {
        Name = "nat-eip"
    }
}

resource "aws_nat_gateway" "nat-gateway" {
    allocation_id = aws_eip.nat-eip.id
    subnet_id    = aws_subnet.public-subnet-1.id

    depends_on = [aws_internet_gateway.platform-igw]

    tags = {
        Name = "nat-gateway"
    }
}

resource "aws_route" "private-subnet-1-nat-route" {
    route_table_id         = aws_route_table.private-rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat-gateway.id
}

resource "aws_ecr_repository" "platform-ecr" {
    name = "cloud-native-platform-app"
    image_tag_mutability = "IMMUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }

    tags = {
        Name = "platform-ecr"
    }

}

resource "aws_iam_role" "eks_cluster" {
  name = "cloud-native-platform-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "eks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "cloud-native-platform-eks-cluster-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "platform" {
    name = "cloud-native-platform-eks-cluster"
    role_arn = aws_iam_role.eks_cluster.arn

    vpc_config {
        subnet_ids = [
            aws_subnet.private-subnet-1.id,
            aws_subnet.private-subnet-2.id
        ]

        endpoint_private_access = true
        endpoint_public_access = true
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks_cluster
    ]

    tags = {
        Name = "cloud-native-platform-eks-cluster"
    }
}


resource "aws_iam_role" "eks_nodes" {
  name = "cloud-native-platform-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "cloud-native-platform-eks-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_nodes_worker" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_ecr" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_cni" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_eks_node_group" "platform" {
  cluster_name    = aws_eks_cluster.platform.name
  node_group_name = "cloud-native-platform-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  instance_types = ["t3.small"]

  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_worker,
    aws_iam_role_policy_attachment.eks_nodes_ecr,
    aws_iam_role_policy_attachment.eks_nodes_cni
  ]

  tags = {
    Name = "cloud-native-platform-eks-nodes"
  }
}