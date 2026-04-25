# EKS CLUSTER (CONTROL PLANE)
resource "aws_eks_cluster" "eks" {
  name     = "${var.project_name}-eks"
  role_arn = var.eks_role_arn
  version  = "1.35"

    access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = false
  }

# depends_on ensures IAM policy is attached before cluster creation
  depends_on = [
    var.eks_cluster_policy_attachment_id
    ]
}


# MANAGED NODE GROUP (WORKER NODES)
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids = var.subnet_ids
  capacity_type = "ON_DEMAND"
  instance_types = [var.instance_type]
  disk_size = var.volume_size


  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

    update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
  "k8s.io/cluster-autoscaler/enabled"                 = "true"
  "k8s.io/cluster-autoscaler/${var.project_name}-eks" = "owned"
}

  depends_on = [
    var.worker_node_policy,
    var.cni_policy,
    var.ecr_readonly,
    var.cluster_autoscaler_role
  ]
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}