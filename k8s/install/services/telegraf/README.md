## Telegraf deployments

This folder contains the different Kubernetes manifests used for deploying 3 different Telegraf instances: `telegraf`, `telegraf-daemonset` and `telegraf-standalone`. Above there is a description of the function carried by each instance and a brief explanation describing why having 3 instances:

1. `telegraf`: This configuration uses Telegraf as a StatsD metrics daemon. It receives metrics coming from SUMO application and writes them to the central InfluxDB server.
2. `telegraf-daemonset`: This configuration deploys Telegraf as a Daemonset for fetching host-level metrics and container level metrics (via CAdvisor), and also listens for statsd compatible metrics in two UDP ports: 8125 fro prod and 8126 for stage.
3. `telegraf-standalone`: This configuration deploys only one replica of Telegraf, used for fetching Kubernetes API for getting stats about the cluster status (namespaces, deployments...). It uses the same InfluxDB server.


Note about having 3 different instances: There's a good reason for having 2 different Telegraf configurations. If we were to merge the configurations into the Daemonset, Telegraf will be querying kube-state-metrics for obtaining information about the cluster status, once per host and writing all those duplicated metrics to InfluxDB. Merging the configurations into the Deployment, would cause loosing metrics about container status and host level status in the nodes where it is not running.

There's yet the third instance, which is used as a statsD server. This is planned to be merged into the Daemonset Telegraf instance
