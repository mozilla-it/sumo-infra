# Creating a SUMO kubernetes cluster
Kubernetes clusters are configured using kops, each cluster created right now will have 1 master and 3 nodes in a singular AZ

## Requirements
You will need the following tools to get kubernetes installed

- kops
- terraform
- kubectl
- awscli

## Checklist

- choose AWS region + AZ
- choose an external DNS name
    - Create external DNS name

## Create cluster infra in a specific AZ
Kubernetes and Kops require some infrastructure to get going, primarily a VPC and some S3 buckets

- Ensure your AWS_PROFILE is set correctly and authenticate to AWS if necessary
- In the `k8s/tf/00_aws-vpc/<your_AZ>` directory, run `terraform apply`
- In the `k8s/tf/01_dns` directory, run `terraform apply`
- In the `k8s/tf/01_s3` directory, run `terraform apply`
- In the `k8s/tf/10_ark/<your_AZ>` directory, run `terraform apply`
- In the `k8s/tf/110_metrics` directory, run `terraform apply`
- In the `k8s/tf/20_yar` directory, run `terraform apply`

## Create the cluster with kops
- Edit `k8s/common.sh` and put real values form your terraform output into `KOPS_VPC_ID`, `KOPS_STATE_BUCKET` and `STATE_BUCKET`.  Ensure all the sizing and k8s version is as you desire.
- cd to the directory under `k8s/` for the Availability Zone(AZ) you want to build a k8s cluster in such as `us-west-2a`:
- Copy config.sh.template to config.sh and put real values in it for:
    - `KOPS_SUBNETS` which should be set to a public subnet created by the terraform earlier
    - `KOPS_SSH_PUB_KEY` which should point to a copy of SSH public key
    - `KOPS_ADMIN_IP` which should be your IP
    - `SECRETS_PATH` which should point to a checkout of sumo's private repo
- `source config.sh`
- run `install.sh` to have kops generate terraform for your k8s cluster
- In the resulting `out/terraform` directory, you will need to define a remote state bucket before applying the newly generated terraform code.
```
$ cat ./out/terraform/provider.tf
terraform {
  backend "s3" {
    bucket = "<state-bucket-name>"
    key    = "<state-key>"
    region = "<region>"
  }
```
Note: If you already have applied the kops terraform and have a terraform.tfstate, you can copy that to the remote bucket named as the key name, and terraform will use that with the provider snippet in place on subsequent runs.

- Run `terraform init && terraform apply`
- Wait several minutes for the kubernetes cluster to start or the next step will fail
- `kops validate cluster` until it shows the cluster is ready

## Configure the kubernetes cluster
- Ensure your kubeconfig is pointed at the cluster you intend to install against `kubectl config current-context`
- Run the post-install configuration script like `./post-install.sh all` and follow any prompts, or if it is more comfortable you can install one component at a time, see `./install/post-install.sh` for more details

### post-install.sh notes
  * `elb_service()` function install relies on environment variables in `<cluster>/config.sh` that may change per namespace and currently requires modifying and re-running `./post-install.sh elb_service` for each namespace. E.G. edit config.sh and set `ENVIRONMENT` to stage to deploy an ELB for sumo-stage.
  * Note: currently elb_service() is not part of the default install `all` and must be called independently, explicitly.
  * Note: similarly, yar_install is not part of the default install `all` and must be called independently, explicitly as it only is supposed to run in a single region as well
  * You can view all configured LoadBalancer services with `kubectl get svc -A`

## Configure more application infra
- In the `k8s/tf/50_cdn` directory, run `terraform apply` to create s3 origins and cloudfront cdns
- In the `k8s/tf/60_dev_db` directory, run `terraform apply` to create the dev environment database, this requires the eu-central-1a (Frankfurt) region to have been created and k8s configured already as that is where the dev environment lives
- In the `k8s/tf/70_prod_db_redis` directory, run `terraform apply` to create the prod database and Redis cache
- In the `k8s/tf/80_regional_lb` directory, run `terraform apply` to create the load balancer that points to all nodes in oregon-a and oregon-b
- In the `k8s/tf/99_jenkins` directory, run `terraform apply` to create the Jenkins CI instance

## Configure some infra by hand
At this time, not all infra is created by Terraform due to time constraints.  Create the following by hand:
- Route53 Traffic Policy to send traffic to Oregon ELB with a failover to Frankfurt CloudFront
- Health checks for each ELB with alerts to Slack
- SNS topic and associated Lambda function to send CloudWatch alerts to Slack
- Read only DB replica in Frankfurt
