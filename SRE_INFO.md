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
