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

Secrets repo [sumo-private](https://github.com/mozilla-it/sumo-private/) which includes the yar bot that blocks malicious IPs

Block-aws repo [block-aws](https://github.com/mozilla-it/block-aws/)

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
| Application Monitoring	| [SUMO Prod Oregon A](https://rpm.newrelic.com/accounts/2239138/applications/153639010), [SUMO Prod Oregon B](https://rpm.newrelic.com/accounts/2239138/applications/153639233), [SUMO Prod Frankfurt](https://rpm.newrelic.com/accounts/2239138/applications/153284218) | N/A | [InfluxDB SUMO Dashboard](https://biff-5adb6e55.influxcloud.net/d/xQmdTPAZk/sumo?orgId=1&from=now-1h&to=now&var-env=prod&var-region=All) |
| Infrastructure Monitoring | [InfluxDB SUMO Dashboard](https://biff-5adb6e55.influxcloud.net/d/xQmdTPAZk/sumo?orgId=1&from=now-1h&to=now&var-env=prod&var-region=All) | [CloudWatch Oregon-B k8s node ASG size Slack Alarm](https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#alarmsV2:alarm/nodes.k8s.us-west-2b.sumo.mozit.cloud-ASG-size), [CloudWatch Oregon-A k8s node ASG size Slack Alarm](https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#alarmsV2:alarm/nodes.k8s.us-west-2a.sumo.mozit.cloud-ASG-size), [CloudWatch Oregon-B k8s master ASG size Slack Alarm](https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#alarmsV2:alarm/master-us-west-2b.masters.k8s.us-west-2b.sumo.mozit.cloud-ASG-size), [CloudWatch Oregon-A k8s master ASG size Slack Alarm](https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#alarmsV2:alarm/master-us-west-2a.masters.k8s.us-west-2a.sumo.mozit.cloud-ASG-size), [CloudWatch RDS Replication Slack Alarm](https://eu-central-1.console.aws.amazon.com/cloudwatch/home?region=eu-central-1#alarmsV2:alarm/awsrds-sumo-replica-ro-High-Replica-Lag), [CloudWatch Frankfurt k8s master ASG size Slack Alarm](https://eu-central-1.console.aws.amazon.com/cloudwatch/home?region=eu-central-1#alarmsV2:alarm/master-eu-central-1a.masters.k8s.eu-central-1a.sumo.mozit.cloud-ASG-size), [CloudWatch Frankfurt k8s nodes ASG size Slack Alarm](https://eu-central-1.console.aws.amazon.com/cloudwatch/home?region=eu-central-1#alarmsV2:alarm/nodes.k8s.eu-central-1a.sumo.mozit.cloud-ASG-size), [CloudWatch Frankfurt VPN Slack Alarm](https://eu-central-1.console.aws.amazon.com/cloudwatch/home?region=eu-central-1#alarmsV2:alarm/eu-central-1-VPN), [CloudWatch Oregon VPN Slack Alarm](https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#alarmsV2:alarm/us-west-2-VPN) | N/A |
| Cert Monitoring | [InfluxDB Cert Monitoring](https://biff-5adb6e55.influxcloud.net/d/uy9KMJGWzsd/ssl-certs?orgId=1) | N/A | N/A |
| Status Dashboard | [Mozilla Websites StatusPage](https://mozilla.statuspage.io/) | [Mozilla Support StatusPage](https://manage.statuspage.io/pages/xy7xhsxcp3zc/components/dyyshh18k1g7/edit) | N/A | 
| Logging | [Papertrail SUMO](https://my.papertrailapp.com/groups/13629141/events) | N/A | N/A |
| Pager Duty | [PagerDuty support.mozilla.org-itsre Service](https://mozilla.pagerduty.com/services/PN78MXK/settings) | [PagerDuty support.mozilla.org-itsre Escalation Policy](https://mozilla.pagerduty.com/escalation_policies#PVGMF9K) | N/A |
| Backups | [GitHub Kitsune repo](https://github.com/mozilla/kitsune), [GitHub sumo-infra repo](https://github.com/mozilla-it/sumo-infra), [GitHub sumo-private repo](https://github.com/mozilla-it/sumo-private/), [GitHub block-aws repo](https://github.com/mozilla-it/block-aws/) | Link to RDS / S3 / AWS backups configuration | [RDS prod snapshots](https://us-west-2.console.aws.amazon.com/rds/home?region=us-west-2#db-snapshots:), [RDS dev snapshots](https://eu-central-1.console.aws.amazon.com/rds/home?region=eu-central-1#db-snapshots:) |
