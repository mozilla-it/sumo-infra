terraform {
  backend "s3" {
    bucket = "sumo-state-095732026120"
    key    = "terraform/kubernetes-us-west-2a"
    region = "us-west-2"
  }
}

provider aws {
  region = "${var.region}"
}

module "ark_bucket" {
  source       = "github.com/mozilla-it/tf-ark-backups?ref=master"
  region       = "${var.region}"
  bucket_name  = "cluster-backups"
  cluster_name = "us-west-2a"
}
