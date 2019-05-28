export ENVIRONMENT ?= dev
export CERT_ARN

deploy: check-env
	j2 sumo.service.yaml.j2 | kubectl apply -f -

check-env:
ifndef CERT_ARN
	$(error CERT_ARN is undefined)
endif
