
# Monitoring with elastic stack

![ES-TF](https://devopsdatacenter.files.wordpress.com/2022/05/elasticseach_terraform.png)

With this [Terraform module](https://registry.terraform.io/modules/Mtt6300/monitoring-with-elastic-stack/kubernetes/latest) you can easily deploy and manage [Elastic Stack](https://www.elastic.co/elastic-stack/) with [Helm](https://helm.sh/) for reaching to observability and monitoring [Kubernetes](https://kubernetes.io/) cluster and applications.

Here is all tools which can deploy and configure with this module

* [Elasticsearch](https://github.com/elastic/elasticsearch) (Full-text search engine)
* [kibana](https://github.com/elastic/kibana) (Data visualization dashboard)
* [Metricbeat](https://github.com/elastic/beats/tree/master/metricbeat) (Lightweight shipper for collect metrics)
* [Filebeat](https://github.com/elastic/beats/tree/master/filebeat) (Lightweight shipper for forwarding and centralizing log data)
* [APM-server](https://github.com/elastic/apm-server) (Application performance management)
* [Grafana](https://github.com/grafana/grafana) (Alerting system)
* Beats purger (Kubernetes Cron job for cleaning up Elasticsearch from old Beats data)




# Usage
Module only deploy Elasticsearch and Kibana by default. you can enable other tools by passing `TOOL_NAME-enabled` variable for each of them. i put 4 example of configuration which you can use:

1) default configurations
```tf
provider "kubernetes" {
  config_path = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "monitoring-with-elastic-stack" {
  source  = "Mtt6300/monitoring-with-elastic-stack/kubernetes"
  version = "1.0.0"
  stack-version = "7.13.0"
}
```
It will deploy Elasticsearch and kibana on `elastic-monitoring` namespace with default credentials which is `elastic:elastic`.


2) enable all tools

```tf
provider "kubernetes" {
  config_path = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


module "monitoring-with-elastic-stack" {
  source  = "Mtt6300/monitoring-with-elastic-stack/kubernetes"
  version = "1.0.0"
  stack-version = "7.13.0"
  namespace= "elastic-monitoring"
  
  elasticsearch-credentials-username = "elastic"
  elasticsearch-credentials-password = "elastic"
  elasticsearch-ingress-enabled = true
  elasticsearch-ingress-host  ="elasticsearch.example.com"

  kibana-ingress-enabled = true
  kibana-ingress-host = "kibana.example.com"

  metricbeat-enabled = true

  apm-server-enabled = true

  filebeat-enabled = true

  grafana-enabled = true
  grafana-credentials-username = "admin"
  grafana-credentials-password = "admin"
  grafana-ingress-enabled = true
  grafana-ingress-host  = ["grafana.example.com"]

}
```
It will deploy all tools on `elastic-monitoring` namespace with default credentials which is `elastic:elastic`.


3) This is all available options (variables) which you can use by default.
```tf
provider "kubernetes" {
  config_path = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "monitoring-with-elastic-stack" {
  source  = "Mtt6300/monitoring-with-elastic-stack/kubernetes"
  version = "1.0.0"
  stack-version = "7.13.0"
  namespace= "elastic-monitoring"

  elasticsearch-credentials-username = "elastic"
  elasticsearch-credentials-password = "elastic"
  elasticsearch-persistence-size = "30Gi"
  elasticsearch-ingress-enabled = false
  elasticsearch-ingress-host  ="elasticsearch.example.com"
  elasticsearch-esJavaOpts = "-Xmx1g -Xms1g"

  kibana-replicas = 1
  kibana-ingress-enabled = false
  kibana-ingress-host = "kibana.example.com"



  metricbeat-enabled = true
  kubestate-enabled = true
  metricbeat-daemonset-enabled = true
  metricbeat-purger-schedule = "0 0 * * *"

  apm-server-enabled = true


  filebeat-enabled = true
  filebeat-daemonset-enabled = true
  filebeat-deployment-enabled = false
  filebeat-purger-schedule = "0 0 * * *"


  grafana-enabled = true
  grafana-credentials-username = "admin"
  grafana-credentials-password = "admin"
  grafana-repository = "grafana/grafana"
  grafana-version = "8.0.0"
  grafana-replicas = 1
  grafana-ingress-enabled = false
  grafana-ingress-host  = ["grafana.example.com"]
  grafana-persistence-enabled = true
  grafana-persistence-storageClassName = "default"
  grafana-persistence-size = "10Gi"
  grafana-plugins = "yesoreyeram-infinity-datasource"

  // default helm file path
  // elasticsearch-values-file = ".terraform/modules/monitoring-with-elastic-stack/configs/elasticsearch/values.yaml"
  // kibana-values-file = ".terraform/modules/monitoring-with-elastic-stack/configs/kibana/values.yaml"
  // filebeat-values-file = ".terraform/modules/monitoring-with-elastic-stack/configs/filebeat/values.yaml"
  // grafana-values-file = ".terraform/modules/monitoring-with-elastic-stack/configs/grafana/values.yaml"
  // metricbeat-values-file = ".terraform/modules/monitoring-with-elastic-stack/configs/metricbeat/values.yaml"
  // apm-server-values-file = ".terraform/modules/monitoring-with-elastic-stack/configs/apm-server/values.yaml"

}
```

## metricbeat-purger-schedule and filebeat-purger-schedule
This is Kubernetes Cron job which will trigger every 24 hours by default and will clear old beats data by time .for example if you set every 24 hours (`0 0 * * *`), it will delete that beat old data every 24 hours. this time can configure by cron schedule expressions.for more info visit [here](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#cron-schedule-syntax).



# Input
https://registry.terraform.io/modules/Mtt6300/monitoring-with-elastic-stack/kubernetes/latest?tab=inputs

There is some input variables that can customize your configurations (You can see list of variables in [Terraform registry module page](https://registry.terraform.io/modules/Mtt6300/monitoring-with-elastic-stack/kubernetes/latest) ) but if you want more configment you can pass your helm values file as a argument to module. 

4) Here is full feature config for module which configured with your own helm values file : 
```tf
provider "kubernetes" {
  config_path = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "monitoring-with-elastic-stack" {
  source  = "Mtt6300/monitoring-with-elastic-stack/kubernetes"
  version = "1.0.0"
  namespace= "elastic-monitoring"
  elasticsearch-credentials-username = "elastic"
  elasticsearch-credentials-password = "elastic"


  filebeat-enabled = true
  filebeat-purger-schedule = "0 0 * * *"

  grafana-enabled = true
  grafana-credentials-username = "admin"
  grafana-credentials-password = "admin"

  metricbeat-enabled = true
  metricbeat-purger-schedule = "0 0 * * *"

  apm-server-enabled = true

  elasticsearch-values-file = "Full path of your file"
  kibana-values-file = "Full path of your file"
  filebeat-values-file = "Full path of your file"
  grafana-values-file = "Full path of your file"
  metricbeat-values-file = "Full path of your file"
  apm-server-values-file = "Full path of your file"
}
```



## Grafana (Alerting system) -> soon
We will using Grafana dashboards for sending alerts. currently dashboard is not available.



## Contributing , idea ,issue
Feel free to fill an issue or create a pull request, I'll check it ASAP