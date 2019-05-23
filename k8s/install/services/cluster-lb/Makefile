export ENVIRONMENT ?= dev
export PUBLIC_SUBNETS
export CERT_ARN
export KOPS_CLUSTER_NAME
export ROUTE53_ZONE
export CLUSTER_ALT_NAME

deploy: check-env
	j2 alb-ingress-controller.yaml.j2 | kubectl apply -f -
	echo "Sleeping for ingress controller creation"
	sleep 30
	j2 sumo.service.yaml.j2 | kubectl apply -f -
	j2 alb-ingress.yaml.j2 | kubectl apply -f -
	j2 external-dns.yaml.j2 | kubectl apply -f -

check-env:
ifndef CERT_ARN
	$(error CERT_ARN is undefined)
endif
ifndef PUBLIC_SUBNETS
	$(error PUBLIC_SUBNETS is undefined)
endif
ifndef KOPS_CLUSTER_NAME
	$(error KOPS_CLUSTER_NAME is undefined)
endif
ifndef ROUTE53_ZONE
	$(error ROUTE53_ZONE is undefined)
endif
ifndef CLUSTER_ALT_NAME
	$(error CLUSTER_ALT_NAME is undefined)
endif
