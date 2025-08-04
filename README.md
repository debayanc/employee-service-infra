# Employee Service Infrastructure

This Terraform configuration creates a complete EKS cluster with ArgoCD for GitOps deployment of the employee service application.

## Architecture

- **EKS Cluster**: Managed Kubernetes cluster on AWS
- **VPC**: Custom VPC with public/private subnets across 2 AZs
- **ArgoCD**: GitOps continuous deployment tool
- **EBS CSI Driver**: For persistent storage provisioning

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- kubectl installed

## Quick Start

1. **Configure AWS Profile**
   ```bash
   export AWS_PROFILE=personal
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Deploy Infrastructure**
   ```bash
   terraform apply
   ```

4. **Configure kubectl**
   ```bash
   aws eks update-kubeconfig --region ap-southeast-2 --name employee-service-cluster --profile personal
   ```

5. **Access ArgoCD**
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```
   - URL: https://localhost:8080
   - Username: `admin`
   - Password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

## Configuration

### Variables (terraform.tfvars)
```hcl
cluster_name         = "employee-service-cluster"
node_instance_type   = "t3.medium"
desired_capacity     = 2
```

### ArgoCD Application
- **Repository**: https://github.com/debayanc/employee-service.git
- **Path**: helm/employee-service
- **Namespace**: employee-dev
- **Sync Policy**: Automated with prune and self-heal

## Components

### Networking
- VPC with CIDR 10.0.0.0/16
- 2 Public subnets (10.0.101.0/24, 10.0.102.0/24)
- 2 Private subnets (10.0.1.0/24, 10.0.2.0/24)
- NAT Gateway for private subnet internet access

### EKS Cluster
- Managed node group with t3.medium instances
- EBS CSI driver with proper IAM permissions
- Default storage class: gp2

### ArgoCD
- Installed via Helm chart
- NodePort service for UI access
- Configured to deploy employee service automatically

## Troubleshooting

### AWS Console Access
If you can't see pods in AWS Console:
```bash
kubectl patch configmap aws-auth -n kube-system --patch '{"data":{"mapUsers":"[{\"userarn\":\"arn:aws:iam::ACCOUNT_ID:root\",\"username\":\"root\",\"groups\":[\"system:masters\"]}]"}}'
```

### Storage Issues
Ensure EBS CSI driver has proper IAM role:
- Check `aws_iam_role.ebs_csi_driver` is created
- Verify `service_account_role_arn` is set on EBS addon

## Cleanup

```bash
terraform destroy
```

## Outputs

- `cluster_name`: EKS cluster name
- `cluster_endpoint`: EKS cluster API endpoint
- `cluster_arn`: EKS cluster ARN
- `vpc_id`: VPC ID