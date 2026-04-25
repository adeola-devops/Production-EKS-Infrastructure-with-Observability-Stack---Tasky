output "monitoring_instance_public_ip" {
  value = module.Monitoring_public_VM.instance_public_ip
}

output "monitoring_instance_private_ip" {
  value = module.Monitoring_public_VM.instance_private_ip
}

output "mongoDB_private_Ip" {
  value = module.mongodb_private_VM.instance_private_ip
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "mongodb_instance_id" {
  value = module.mongodb_private_VM.instance_id
}

output "cluster_name" {
  value = module.eks_cluster.cluster_name
}

output "region" {
  value = var.region
}
# output "eks_update_kubeconfig_command" {
#   value = "aws eks update-kubeconfig --region ${var.region} --name ${var.eks_name}"
# # aws eks update-kubeconfig --region us-east-1 --name tasky-eks
# }

output "cluster_autoscaler_role_arn" {
  value = module.IAM.cluster_autoscaler_role_arn
}