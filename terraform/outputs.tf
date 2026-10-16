output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS Kubernetes API server"
  value       = aws_eks_cluster.main.endpoint
}

output "rds_endpoint" {
  description = "The connection endpoint for RDS PostgreSQL"
  value       = aws_db_instance.postgres.endpoint
}
