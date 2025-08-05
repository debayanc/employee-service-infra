output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = "admin123"
  sensitive   = true
}

output "access_instructions" {
  description = "Instructions to access services"
  value = <<-EOT
    # Access Grafana:
    kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
    # Login: admin / admin123
    
    # Access ArgoCD:
    kubectl port-forward svc/argocd-server 8080:443 -n argocd
    # Get password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
  EOT
}