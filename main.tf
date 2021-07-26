terraform {
  required_providers {
    kubernetes = "~> 2.3.2"
    helm = "~> 2.2.0"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/server.conf"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/server.conf"
  }
}



resource "kubernetes_secret" "elasticsearch-credentials" {
  metadata {
    name = "elasticsearch-credentials"
    namespace = var.namespace
  }
  data = {
    username = var.elasticsearch-credentials-username
    password = var.elasticsearch-credentials-username
  }
  type = "kubernetes.io/basic-auth"
}



resource "helm_release" "elasticsearch" {
  name  = "elasticsearch"
  repository = var.chart-repository
  chart = "elasticsearch"
  namespace = var.namespace
  atomic = true
  cleanup_on_fail = true
  values = [
    file(var.elastic-values-file)
  ]
  set {
    name  = "imageTag"
    value = var.stack-version
  }
  set {
    name = "ingress.enabled"
    value = var.elasticsearch-ingress-enabled
  }
  set {
    name = "ingress.hosts[0].host"
    value = var.elasticsearch-ingress-host
  }
  set {
    name = "ingress.hosts[0].paths[0].path"
    value = "/"
  }
  set {
    name = "esJavaOpts"
    value = var.elasticsearch-esJavaOpts
  }
  set {
    name = "volumeClaimTemplate.resources.requests.storage"
    value = var.elasticsearch-persistence-size
  }

}


resource "helm_release" "kibana" {
  depends_on = [helm_release.elasticsearch]
  name  = "kibana"
  repository = var.chart-repository
  chart = "kibana"
  namespace = var.namespace
  atomic = true
  cleanup_on_fail = true
  values = [
    file(var.kibana-values-file)
  ]
  set {
    name  = "imageTag"
    value = var.stack-version
  }
  set {
    name  = "replicas"
    value = var.kibana-replicas
  }
  set {
    name = "ingress.enabled"
    value = var.kibana-ingress-enabled
  }
  set {
    name = "ingress.hosts[0].host"
    value = var.kibana-ingress-host
  }
  set {
    name = "ingress.hosts[0].paths[0].path"
    value = "/"
  }

}

resource "helm_release" "metricbeat" {
  depends_on = [helm_release.elasticsearch,helm_release.kibana]
  count = var.metricbeat-enabled ? 1 : 0
  name  = "metricbeat"
  repository = var.chart-repository
  chart = "metricbeat"
  namespace = var.namespace
  atomic = true
  cleanup_on_fail = true
  values = [
    file(var.metricbeat-values-file)
  ]
  set {
    name  = "imageTag"
    value = var.stack-version
  }
  set {
    name  = "deployment.enabled"
    value = var.kubestate-enabled
  }
  set {
    name  = "kube_state_metrics.enabled"
    value = var.kubestate-enabled
  }
  set {
    name  = "daemonset.enabled"
    value = var.metricbeat-daemonset-enabled
  }

}


resource "helm_release" "apm-server" {
  depends_on = [helm_release.elasticsearch,helm_release.kibana]
  count = var.apm-server-enabled ? 1 : 0
  name  = "apm-server"
  repository = var.chart-repository
  chart = "apm-server"
  namespace = var.namespace
  atomic = true
  cleanup_on_fail = true
  values = [
    file(var.apm-server-values-file)
  ]
  set {
    name  = "imageTag"
    value = var.stack-version
  }

}



resource "helm_release" "filebeat" {
  depends_on = [helm_release.elasticsearch,helm_release.kibana]
  count = var.filebeat-enabled ? 1 : 0
  name  = "filebeat"
  repository = var.chart-repository
  chart = "filebeat"
  namespace = var.namespace
  atomic = true
  timeout = 100
  cleanup_on_fail = true
  values = [
    file(var.filebeat-values-file)
  ]
  set {
    name  = "imageTag"
    value = var.stack-version
  }
  set {
    name  = "daemonset.enabled"
    value = var.filebeat-daemonset-enabled
  }
  set {
    name  = "deployment.enabled"
    value = var.filebeat-deployment-enabled
  }

}


resource "kubernetes_secret" "grafana-credentials" {
  count = var.grafana-enabled ? 1 : 0
  metadata {
    name = "grafana-credentials"
    namespace = var.namespace
  }
  data = {
    username = var.grafana-credentials-username
    password = var.grafana-credentials-password
  }
  type = "kubernetes.io/basic-auth"

}

resource "helm_release" "grafana" {
  count = var.grafana-enabled ? 1 : 0
  name  = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart = "grafana"
  namespace = var.namespace
  atomic = true
  cleanup_on_fail = true
  timeout = 100
  values = [
    file(var.grafana-values-file)
  ]
  set {
    name  = "image.tag"
    value = var.grafana-version
  }
  set {
    name  = "image.repository"
    value = var.grafana-repository
  }
  set {
    name  = "image.replicas"
    value = var.grafana-replicas
  }
  set {
    name = "ingress.enabled"
    value = var.grafana-ingress-enabled
  }
  set {
    name = "ingress.hosts"
    value = "{${join(",", var.grafana-ingress-host)}}"
  }
  set {
    name = "persistence.enabled"
    value = var.grafana-persistence-enabled
  }
  set {
    name = "ingress.storageClassName"
    value = var.grafana-persistence-storageClassName
  }
  set {
    name = "persistence.size"
    value = var.grafana-persistence-size
  }  
  set {
    name = "plugins"
    value = var.grafana-plugins
  } 

}


resource "kubernetes_cron_job" "elastic-filebeat-purger" {
  count = var.filebeat-enabled ? 1 : 0
  metadata {
    name = "elasticsearch-filebeat-purger"
    namespace = var.namespace
  }
  spec {
    failed_jobs_history_limit     = 2
    schedule                      = var.filebeat-purger-schedule
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            container {
              name    = "elasticsearch-filebeat-purger"
              image   = "ubuntu:focal"
              command = ["/bin/bash","-c"]
              args    = ["apt update && apt install curl --yes && curl -u $username:$password -XDELETE http://elasticsearch-master:9200/filebeat-*-`date -d'1 days ago' +'%Y.%m.%d'`*"]

              env_from {
                secret_ref {
                  name = "elasticsearch-credentials"
                }
              }
              security_context {
                allow_privilege_escalation = false
                run_as_user = 0

              }

            }
          }
        }
      }
    }
  }
}

resource "kubernetes_cron_job" "elasticsearch-metricbeat-purger" {
  count = var.metricbeat-enabled ? 1 : 0
  metadata {
    name = "elasticsearch-metricbeat-purger"
    namespace = var.namespace
  }
  spec {
    failed_jobs_history_limit     = 2
    schedule                      = var.metricbeat-purger-schedule
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            container {
              name    = "elasticsearch-metricbeat-purger"
              image   = "ubuntu:focal"
              command = ["/bin/bash","-c"]
              args    = ["apt update && apt install curl --yes && curl -u $username:$password -XDELETE http://elasticsearch-master:9200/metricbeat-*-`date -d'1 days ago' +'%Y.%m.%d'`*"]

              env_from {
                secret_ref {
                  name = "elasticsearch-credentials"
                }
              }
              security_context {
                allow_privilege_escalation = false
                run_as_user = 0
              }

            }
          }
        }
      }
    }
  }
}
