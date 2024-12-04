# Requirement addressed: EKS Cluster Outputs (7.4.2 Deployment Architecture)
# Exposes key attributes of the EKS cluster and node groups for integration with other modules or configurations.

output "cluster_id" {
  description = "The unique identifier of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_endpoint" {
  description = "The endpoint URL of the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  description = "The certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "node_group_scaling_config" {
  description = "The scaling configuration of the EKS node group"
  value       = aws_eks_node_group.main.scaling_config[0]
}