## Create cluster infra in a specific AZ
Kubernetes and Kops require some infrastructure to get going, primarily a VPC and some S3 buckets

- Ensure your AWS_PROFILE is set correctly and authenticate to AWS if necessary
- In the `k8s/tf/00_aws-vpc/<your_AZ>` directory, run `terraform apply`
- In the `k8s/tf/01_dns` directory, run `terraform apply`
- In the `k8s/tf/01_s3` directory, run `terraform apply`
- In the `k8s/tf/10_ark/<your_AZ>` directory, run `terraform apply`
- In the `k8s/tf/110_metrics` directory, run `terraform apply`
- In the `k8s/tf/20_yar` directory, run `terraform apply`

## Configure more application infra
- In the `k8s/tf/50_cdn` directory, run `terraform apply` to create s3 origins and cloudfront cdns
- In the `k8s/tf/60_dev_db` directory, run `terraform apply` to create the dev environment database, this requires the eu-central-1a (Frankfurt) region to have been created and k8s configured already as that is where the dev environment lives
- In the `k8s/tf/70_prod_db_redis` directory, run `terraform apply` to create the prod database and Redis cache
- In the `k8s/tf/200_eks/<region>` directory, run `terraform apply` to create and manage EKS clusters.

## Configure some infra by hand
At this time, not all infra is created by Terraform due to time constraints.  Create the following by hand:
- Route53 Traffic Policy to send traffic to Oregon ELB with a failover to Frankfurt CloudFront
- Health checks for each ELB with alerts to Slack
- SNS topic and associated Lambda function to send CloudWatch alerts to Slack
- Read only DB replica in Frankfurt
