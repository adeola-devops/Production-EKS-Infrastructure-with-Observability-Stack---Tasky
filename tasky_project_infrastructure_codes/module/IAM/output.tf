output "eks-cluster-role_arn" {
    value = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "cluster_autoscaler_role_arn" {
  value = aws_iam_role.cluster_autoscaler_role.arn
}

output "ssm_role_arn" {
  value = aws_iam_role.ssm_role.arn
}



output "eks_cluster_policy_attachment_id" {
  value = aws_iam_role_policy_attachment.eks_cluster_policy.id
}

output "worker_node_policy_attachment_id" {
  value = aws_iam_role_policy_attachment.worker_node_policy.id
}

output "cni_policy_attachment_id" {
  value = aws_iam_role_policy_attachment.cni_policy.id
}

output "ecr_readonly_policy_attachment_id" {
  value = aws_iam_role_policy_attachment.ecr_readonly.id
}



output "cluster_autoscaler_attachment_id" {
  value = aws_iam_role_policy_attachment.cluster_autoscaler_attachment.id
}

output "ssm_policy_attachment_id" {
  value = aws_iam_role_policy_attachment.ssm_policy_attachment.id
}

output "ssm_s3_policy_attachment_id" {
  value = aws_iam_role_policy_attachment.s3_policy_attachment.id
}

output "mongodb_secrets_policy_attachment_id" {
  value = aws_iam_role_policy_attachment.mongodb_secrets_policy_attachment.id
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.ssm_profile.name
}

output "oidc_provide_url" {
  value = aws_iam_openid_connect_provider.oidc.url
}