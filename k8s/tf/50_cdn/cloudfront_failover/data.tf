data "terraform_remote_state" "dns" {
  backend = "s3"

  config = {
    bucket = "sumo-state-095732026120"
    key    = "terraform/sumo-dns"
    region = "us-west-2"
  }
}

