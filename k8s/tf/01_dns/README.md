# SUMO DNS setup
This repository creates the DNS records needed to setup Kubernetes. Since the
domain is owned by Mozilla this will create a delegation set
and we can delegate the domain on the Mozilla side of things.

## Provisioning

This assumes that you have the relevant AWS credentials setup and exported.

```bash
cd dns
terraform init
terraform plan
terraform apply -input=yes -auto-approve
```

If you need to add another DNS zone for a different region just add the following to `main.tf`


```bash
module "us-east-1" {
  source      = "./hosted_zone"
  region      = "us-east-1"
  domain_name = "${var.domain_name}"
  zone_id     = "${aws_route53_zone.master-zone.id}"
}
```
