locals {
  namespace = "prometheus-operator"
}

resource "helm_release" "prometheus_stack" {
  namespace        = local.namespace
  create_namespace = true
  name             = "prometheus-operator"
  chart            = "./charts/kube-prometheus-stack-61.7.1.tgz"
  wait             = true

  values = [
    <<-EOT
    # Disable Prometheus alerts for etcd and kubeScheduler
    defaultRules:
      rules:
        etcd: false
        kubeScheduler: false
    
    # Disable ServiceMonitor for etcd and kubeScheduler
    kubeControllerManager:
      enabled: false
    kubeEtcd:
      enabled: false
    kubeScheduler:
      enabled: false
    
    # Add a custom label 'promope: timetogo'.
    # This label will be used by the Prometheus Operator to
    # select ServiceMonitor objects.
    prometheus:
      prometheusSpec:
        serviceMonitorSelector:
          matchLabels:
            promope: timetogo
    
    # Labels to apply to all resources.
    # If you won't add this, the Prometheus operator will ignore
    # default ServiceMonitor created by this Helm Chart, and your
    # Prometheus targets section will be empty.
    commonLabels:
      promope: timetogo
    
    grafana:
      adminPassword: test123 # in production case, we can encrypt this with helm-secrets
    EOT
  ]
}
