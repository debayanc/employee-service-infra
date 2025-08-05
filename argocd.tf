# ArgoCD Installation
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = true

  values = [
    yamlencode({
      server = {
        service = {
          type = "NodePort"
        }
      }
    })
  ]

  depends_on = [aws_eks_node_group.main]
}

# ArgoCD Application for Employee Service
resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = "argocd"

  values = [
    yamlencode({
      applications = {
        "employee-service" = {
          namespace = "argocd"
          project   = "default"
          source = {
            repoURL        = "https://github.com/debayanc/employee-service.git"
            targetRevision = "HEAD"
            path           = "helm/employee-service"
            helm = {
              valueFiles = ["values-aws.yaml"]
            }
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "employee-dev"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true"
            ]
          }
        }
        "employee-frontend" = {
          namespace = "argocd"
          project   = "default"
          source = {
            repoURL        = "https://github.com/debayanc/employee-frontend.git"
            targetRevision = "HEAD"
            path           = "helm/employee-frontend"
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "employee-dev"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true"
            ]
          }
        }
      }
    })
  ]

  depends_on = [helm_release.argocd]
}