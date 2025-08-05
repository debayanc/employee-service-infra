# Prometheus and Grafana Stack
resource "helm_release" "kube_prometheus_stack" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true

  values = [
    yamlencode({
      grafana = {
        adminPassword = "admin123"
        service = {
          type = "NodePort"
        }
        persistence = {
          enabled = true
          storageClassName = "gp2"
          size = "10Gi"
        }
      }
      prometheus = {
        prometheusSpec = {
          retention = "30d"
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp2"
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "20Gi"
                  }
                }
              }
            }
          }
        }
      }
      alertmanager = {
        alertmanagerSpec = {
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp2"
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "5Gi"
                  }
                }
              }
            }
          }
        }
      }
    })
  ]

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_addon.ebs_csi
  ]
}

# Loki Stack for Logs
resource "helm_release" "loki_stack" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = "monitoring"

  values = [
    yamlencode({
      loki = {
        persistence = {
          enabled = true
          storageClassName = "gp2"
          size = "10Gi"
        }
      }
      promtail = {
        enabled = true
      }
      grafana = {
        enabled = false  # Use existing Grafana
      }
    })
  ]

  depends_on = [helm_release.kube_prometheus_stack]
}