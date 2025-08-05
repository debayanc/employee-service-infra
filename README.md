# Employee Service EKS Infrastructure

Complete EKS setup with GitOps (ArgoCD) and Monitoring (Grafana + Prometheus).

## Resources Created

- **EKS Cluster** with cost-optimized t3.medium nodes
- **VPC** with public/private subnets and single NAT Gateway
- **ArgoCD** for GitOps deployment
- **Grafana + Prometheus + Loki** for monitoring and log aggregation
- **EBS CSI Driver** for persistent storage

## Deployment

1. **Configure AWS credentials**:
   ```bash
   aws configure --profile employee-service
   ```

2. **Deploy infrastructure**:
   ```bash
   terraform init
   terraform apply
   ```

3. **Configure kubectl**:
   ```bash
   aws eks update-kubeconfig --region ap-southeast-2 --name employee-service-cluster --profile employee-service
   ```

## Access Services

### Grafana Dashboard (Metrics + Logs)
```bash
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
```
- URL: http://localhost:3000
- Login: `admin` / `admin123`
- **Metrics**: Pre-configured Prometheus dashboards
- **Logs**: Go to Explore → Select Loki → Query: `{namespace="kube-system"}`

### ArgoCD UI
```bash
kubectl port-forward svc/argocd-server 8080:443 -n argocd
```
- URL: https://localhost:8080
- Get password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

### Prometheus
```bash
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring
```
- URL: http://localhost:9090

## Log Queries (Grafana Explore)

**Useful LogQL queries:**
```
{namespace="kube-system"}
{namespace="employee-dev"}
{pod=~"ebs-csi.*"}
{namespace="kube-system"} |= "error"
{container="mysql"}
```

**Benefits over kubectl logs:**
- Centralized log aggregation
- Time-based filtering
- Regex search capabilities
- Log retention and persistence

## GitOps Workflow

1. Update Helm charts in Git
2. ArgoCD automatically syncs changes
3. Monitor deployments in Grafana dashboards

## Cost Optimization

- Single NAT Gateway
- t3.medium instances
- Estimated cost: ~$200-250/month