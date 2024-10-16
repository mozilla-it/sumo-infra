> [!NOTE]
> This repository was used for the old AWS infrastructure for SUMO. The new infrastructure code for the GCP deployment is private.

# SUMO Infra
This repo has source code for building SUMO infrastructure in AWS including networking, kubernetes clusters and CI/CD

## Kubernetes Clusters
To stand up most of the infra including Kuberenets and Jenkins, see `k8s/README.md`

## Monitoring
SUMO is monitored with AWS Health Checks, New Relic Synthetics, New Relic APM and Dead Man's Snitch.  These tools feed into PagerDuty, Slack and Email alerts.

### Slack alerts
Deployments, Jenkin builds and Dead man's snitch all report to Slack.  To set this up, request a new slack bot from the Service Desk.  There are 3 different ways that our services interact with Slack bots:
* Webhook URL: This is how New Relic integrates with Slack.  Service Desk can create a bot that listens at a url like https://hooks.slack.com/services/<hash>
** AWS SNS can also integrate via Webhook URLs (from a Lambda function) into Slack
* Email address: This is how AWS health checks can be integrated with Slack.  Note this is not the preferred method of integration and is I believe deprecated by Slack.
* Slack API key: This is also a deprecated Slack bot feature that gives a key that can be used to post to slack.  The slack-cli tool uses this feature and is called by Jenkins and commander.sh when building or deploying SUMO

## SUMO Secrets
Secrets are stored in a private location, but to aid in future discoverability the structure is described here:
- Global secrets in the `services` directory
```
[agent]
    isimmortal      = on
    installservice  = on
    discoverpublicip = on
    discoverawsmeta = on
    checkin         = off
    relay           = "amqps://username:password@url:port/path"
    socket          = "host:port"
    heartbeatfreq   = "30s"
    moduletimeout   = "1200s"
    api             = "url"

[certs]
    ca  = "<ca cert path>"
    cert= "<agent cert path>"
    key = "<agent key path>"

[logging]
    mode    = "stdout" ; stdout | file | syslog
    level   = "info"
```
  - `newrelic/` contains a newrelic kubernets secret manfiest like:
```
apiVersion: v1
kind: Secret
metadata:
  name: newrelic-config
  namespace: newrelic
type: Opaque
data:
  config: <base64 encoded NR api key>
```
- For each cluster, e.g. `us-west-2a`:
  - credentials-ark contains secrets generated by our ark terraform
```
[default]
ark_access_key=
ark_secret_key=
```
  - credentials-block-aws links to a specific Deadman's Snitch URL
    `DMS_URL=https://nosnch.in/unique_path`
  - papertrail.env has papertrail syslog host and a port specific to this cluster
```
export SYSLOG_HOST="logs.papertrailapp.com"
export SYSLOG_PORT="unique_port"
```

- jenkins
  - This is a Terraform tfvars file passed straight into a Terraform command using a helper script `./tf-do <plan|apply>`. The format is the standard `key = value` where `key` matches variables found in the k8s/tf Jenkins directory.
