module "vpc" {
  source       = "./module/vpc"
  region       = var.region
  project_name = var.project_name
}

module "security_groups" {
  source       = "./module/security-group"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "keypair" {
  source   = "./module/keypair"
  key_name = "mfp-key"
}

module "IAM" {
  source           = "./module/IAM"
  project_name     = var.project_name
  mongodb_database = var.mongodb_database
  AWS_ACCOUNT_ID   = var.AWS_ACCOUNT_ID
  cluster_name     = module.eks_cluster.cluster_name
  # oidc_url         = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
  oidc_url = module.eks_cluster.oidc_issuer
}

module "mongodb_private_VM" {
  source                      = "./module/VM"
  project_name                = var.project_name
  ami                         = var.ami
  instance_type               = var.instance_type
  volume_size                 = var.volume_size
  key_name                    = null
  subnet_id                   = module.vpc.private_subnet_id[0]
  iam_instance_profile        = module.IAM.iam_instance_profile_name
  associate_public_ip_address = false
  security_groups = [
    module.security_groups.security_group_MongoDB_id,
    module.security_groups.security_group_mongoDB-exporter_id,
    module.security_groups.security_group_monitoring_id
  ]

  user_data = join("\n", [
    file("${path.root}/scripts/node-exporter.sh"),
    file("${path.root}/scripts/mongodb_exporter.sh"),
    file("${path.root}/scripts/mongodb_installation.sh")
  ])
}

module "Monitoring_public_VM" {
  source                      = "./module/VM"
  project_name                = var.project_name
  ami                         = var.ami
  instance_type               = var.instance_type
  volume_size                 = var.volume_size
  subnet_id                   = module.vpc.public_subnet_id[0]
  iam_instance_profile        = null
  key_name                    = module.keypair.keypair
  associate_public_ip_address = true
  security_groups = [
    module.security_groups.security_group_http_id,
    module.security_groups.security_group_ssh_id,
    module.security_groups.security_group_monitoring_id
  ]

  user_data = join("\n", [
    file("${path.root}/scripts/grafana.sh"),
    file("${path.root}/scripts/node-exporter.sh"),
    file("${path.root}/scripts/prometheus.sh")
  ])
}

# module "k8s" {
#   source                           = "./module/k8s"
#   cluster_autoscaler_role_arn = module.IAM.cluster_autoscaler_role_arn
#   cluster_name = module.eks_cluster.cluster_name
#   depends_on = [module.eks_cluster]
# }

module "eks_cluster" {
  source                           = "./module/eks_cluster"
  project_name                     = var.project_name
  instance_type                    = var.instance_type
  volume_size                      = var.volume_size
  eks_role_arn                     = module.IAM.eks-cluster-role_arn
  eks_cluster_policy_attachment_id = module.IAM.eks_cluster_policy_attachment_id
  worker_node_policy               = module.IAM.worker_node_policy_attachment_id
  cni_policy                       = module.IAM.cni_policy_attachment_id
  cluster_autoscaler_role          = module.IAM.cluster_autoscaler_attachment_id
  ecr_readonly                     = module.IAM.ecr_readonly_policy_attachment_id
  node_role_arn                    = module.IAM.eks_node_role_arn
  subnet_ids                       = module.vpc.private_subnet_id
  cluster_autoscaler_role_arn      = module.IAM.cluster_autoscaler_role_arn
}