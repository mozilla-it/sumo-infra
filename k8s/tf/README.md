# ./00_aws-vpc

This sets up the VPC for the cluster. Creating this outside of kops and handing off the desired subnets and VPC ID to kops allows for much greater flexibility down the road.

# ./01_dns

# ./01_s3

# ./10_ark

This sets up the Ark buckets, split up by AZ (cluster) gets its own S3 backup bucket.

This uses the [tf-ark-backup](https://github.com/mozilla-it/tf-ark-backups) module in github.

# ./20_yar

This module is to be run before the k8s deployment that is found in `<${K8S_SECRETS}/services/yar>`. This sets up the IAM permissions for the app to add/remove/query NACLs

# ./50_cdn/user_media_s3

Note: The static user content IAM user credentials are not created here due to security concerns of the secret keys being stored in the terraform state. You will need to generate the credentials via the CLI or console separately and populate the kitsune secrets yaml

# ./60_dev_db_redis

# ./70_prod_db_redis

# ./80_regional_lb

This builds and configures the region-wide us-west-2 ELB in AWS that glues up the `nodes.k8s.us-west-2(a|b).sumo.mozit.cloud` Auto Scaling Groups that the production traffic policy points at.

# ./120_pocket_support

Infrastructure related to Pocket Help Center. Public S3 bucket and a CloudFront distribution with a custom domain.

# ./200_eks

EKS configuration.
