# SRE Info

## Infra Access
To access Kubernetes Masters, you need to be on the MDC1 or MDC2 VPN.  The [Kubeconfig](https://github.com/mozilla-it/sumo-private/blob/master/us-west-2a/kubectl.us-west-2a.conf) is in the private secrets repo, there is one for each of the three clusters.

[SRE aws-vault setup](https://mana.mozilla.org/wiki/display/SRE/aws-vault)

[SRE account guide](https://mana.mozilla.org/wiki/display/SRE/AWS+Account+access+guide)

[SRE AWS accounts](https://github.com/mozilla-it/itsre-accounts/blob/master/accounts/mozilla-itsre/terraform.tfvars#L5)

## Secrets
Secrets are stored in [sumo-private](https://github.com/mozilla-it/sumo-private/), a private repo using git-crypt

[Private repo with git-crypt guide](https://mana.mozilla.org/wiki/display/SRE/Private+repos+with+git-crypt)

## Source Repos
Application repo [kitsune](https://github.com/mozilla/kitsune)

Infrastructure repo [sumo-infra](https://github.com/mozilla-it/sumo-infra)

## Monitoring
[New Relic APM](https://rpm.newrelic.com/accounts/2239138/applications/153639011)

[New Relic Synthetics](https://synthetics.newrelic.com/accounts/2239138/monitors/3a8a4356-ba8e-46ef-b9f6-2fcadcc5e2bf)

## SSL Certificates
SUMO uses certs from AWS ACM

[SSL Cert Monitoring](https://metrics.mozilla-itsre.mozit.cloud/d/EsrIYzmWz/traffic?orgId=1)

## Cloud Account
AWS account mozilla-sumo 095732026120

# Observability, Disaster Recovery, and Alerting for SRE Properties
| Service | Front End | Back End | Database |
| --- | --- | --- | --- |
| Synthetic Monitoring | [Synthetics](https://synthetics.newrelic.com/accounts/2239138/monitors/71c8c6de-65f0-44fb-bbe5-f6ddb70885f1), [Synthetics - Search](https://synthetics.newrelic.com/accounts/2239138/monitors/ea6bab9e-f423-4012-b292-9c8dd04e1df0), [SUMO](https://synthetics.newrelic.com/accounts/2239138/monitors/3a8a4356-ba8e-46ef-b9f6-2fcadcc5e2bf) | [SUMO Prod TP](https://synthetics.newrelic.com/accounts/2239138/monitors/6d16feba-9acc-4d65-96b3-62d30c2c0db7), [SUMO Prod Oregon A](https://synthetics.newrelic.com/accounts/2239138/monitors/3dd4fcc6-9ad8-4dbc-b949-2639f6cb113d), [SUMO Prod Oregon B](https://synthetics.newrelic.com/accounts/2239138/monitors/c06b3b01-e556-4099-89c6-f4b3c1e87181), [SUMO Prod Frankfurt](https://synthetics.newrelic.com/accounts/2239138/monitors/098b84d4-b344-4b74-b628-727740be554d) | N/A |
| Application Monitoring	| Link to New Relic APM | Link to New Relic APM | Link to Influx dashboard |
| Infrastructure Monitoring | Link to Influx Dashboard | | |
| Cert Monitoring | Link to Influx and/or NR Synthetics	Link to Influx and/or NR Synthetics	Link to Influx and/or NR Synthetics | N/A | N/A |
| Status Dashboard | Link to statuspage.io | N/A | N/A | 
| Logging | Link to papertrail | Link to papertrail | N/A |
| Pager Duty | Link to PD setup | | |
| Backups | Link to github? | Link to RDS / S3 / AWS backups configuration | |
