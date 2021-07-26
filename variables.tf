variable "chart-repository" {
    default = "https://helm.elastic.co"
    description = "elastic repository for getting helm charts"
}
variable "namespace" {
    default = "elastic-monitoring"
    description = "all the resources will deploy here"
}
variable "stack-version" {
    default = "7.13.0"
    description = "elastic stack version"
    type  = string
}

## elasticsearch
variable "elasticsearch-credentials-username" {
    default = "elastic"
    description = "default elasticsearch username"
    type    = string
}
variable "elasticsearch-credentials-password" {
    default = "admin"
    description = "default elasticsearch password"
    type    = string
}
variable "elasticsearch-ingress-enabled" {
    default = false
    description = "elasticsearch ingress"
    type    = bool
}
variable "elasticsearch-ingress-host" {
    default = "elasticsearch.example.com"
    description = "elasticsearch ingress host"
    type    = string
}
variable "elasticsearch-esJavaOpts" {
    default = "-Xmx1g -Xms1g"
    description = "JVM options"
    type    = string
}
variable "elasticsearch-persistence-size" {
    default = "30Gi"
    description = "elasticsearch persistence size per pod"
    type    = string
}
variable "elasticsearch-values-file" {
    default = ".terraform/modules/monitoring-with-elastic-stack/configs/elasticsearch/values.yaml"
    description = "helm values file path"
    type    = string
}


## kibana
variable "kibana-replicas" {
    default = 1
    description = "kibana replicas"
    type    = number
}
variable "kibana-ingress-enabled" {
    default = false
    description = "kibana ingress"
    type    = bool
}
variable "kibana-ingress-host" {
    default = "kibana.example.com"
    description = "elasticsearch ingress host"
    type    = string
}
variable "kibana-values-file" {
    default = ".terraform/modules/monitoring-with-elastic-stack/configs/kibana/values.yaml"
    description = "helm values file path"
    type    = string
}


## metricbeat
variable "metricbeat-enabled" {
    default = false
    description = "enable metricbeat resource for deploy"
    type    = bool
}
variable "kubestate-enabled" {
    default = true
    description = "enable kube-state-metrics deployment for metricbeat"
    type    = bool
}
variable "metricbeat-daemonset-enabled" {
    default = true
    description = "metricbeat daemonset"
    type    = bool
}
variable "metricbeat-purger-schedule" {
    // every 24H
    default = "0 0 * * *"
    description = "CronJob which cleaning up metricbeat data from elasticsearch (default:every 24H)"
    type    = string
}
variable "metricbeat-values-file" {
    default = ".terraform/modules/monitoring-with-elastic-stack/configs/metricbeat/values.yaml"
    description = "helm values file path"
    type    = string
}


## apm-server
variable "apm-server-enabled" {
    default = false
    description = "enable apm-server resource for deploy"
    type    = bool
}
variable "apm-server-values-file" {
    default = ".terraform/modules/monitoring-with-elastic-stack/configs/apm-server/values.yaml"
    description = "helm values file path"
    type    = string
}

## filebeat
variable "filebeat-enabled" {
    default = false
    description = "enable filebeat resource for deploy"
    type    = bool
}
variable "filebeat-daemonset-enabled" {
    default = true
    description = "metricbeat daemonset"
    type    = bool
}
variable "filebeat-deployment-enabled" {
    default = false
    description = "filebeat deployment"
    type    = bool
}
variable "filebeat-purger-schedule" {
    // every 24H
    default = "0 0 * * *"
    description = "CronJob which cleaning up filebeat data from elasticsearch (default:every 24H)"
    type    = string
}
variable "filebeat-values-file" {
    default = ".terraform/modules/monitoring-with-elastic-stack/configs/filebeat/values.yaml"
    description = "helm values file path"
    type    = string
}



### grafana
variable "grafana-enabled" {
    default = false
    description = "enable grafana resource for deploy"
    type    = bool
}
variable "grafana-credentials-username" {
    default = "admin"
    description = "default grafana username"
    type    = string
}
variable "grafana-credentials-password" {
    default = "admin"
    description = "default grafana password"
    type    = string
}
variable "grafana-repository" {
    default = "grafana/grafana"
    description = "grafana repository"
    type    = string
}
variable "grafana-version" {
    default = "8.0.0"
    description = "grafana version"
    type    = string
}
variable "grafana-replicas" {
    default = 1
    description = "number of grafana replicas"
    type    = number
}
variable "grafana-ingress-enabled" {
    default = false
    description = "grafana ingress"
    type    = bool
}
variable "grafana-ingress-host" {
    default = ["grafana.example.com"]
    description = "list of grafana hosts"
    type    = list
}
variable "grafana-persistence-enabled" {
    default = true
    description = "grafana persistence"
    type    = bool
}
variable "grafana-persistence-storageClassName" {
    default = "default"
    description = "grafana storage class name"
    type    = string
}
variable "grafana-persistence-size" {
    default = "10Gi"
    description = "grafana persistence size"
    type    = string
}
variable "grafana-plugins" {
    default = "yesoreyeram-infinity-datasource"
    description = "grafana plugins"
    type    = string
}
variable "grafana-values-file" {
    default = ".terraform/modules/monitoring-with-elastic-stack/configs/grafana/values.yaml"
    description = "helm values file path"
    type    = string
}