# ===================================================================
#! Optional Variables
# ===================================================================

locals {
  helm_chart      = "ingress-nginx"
  helm_repository = "https://kubernetes.github.io/ingress-nginx"
}

# ===================================================================
#! NGINX Ingress Controller module entry point.
#* https://github.com/terraform-iaac/terraform-helm-nginx-controller
# ===================================================================

resource "helm_release" "application" {
  name             = local.helm_chart
  chart            = "./charts/ingress-nginx-4.11.1.tgz"
  namespace        = "kube-system"
  atomic           = false
  create_namespace = true
  wait             = true
  timeout          = 300

  set {
    name  = "controller.kind"
    value = "DaemonSet"
  }
  set {
    name  = "controller.ingressClassResource.name"
    value = "nginx"
  }
  set {
    name  = "controller.ingressClassResource.default"
    value = true
  }
  set {
    name  = "controller.daemonset.useHostPort"
    value = false
  }
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
  set {
    name  = "controller.publishService.enabled"
    value = true
  }
  set {
    name  = "controller.resources.requests.memory"
    type  = "string"
    value = "140Mi"
  }
}
