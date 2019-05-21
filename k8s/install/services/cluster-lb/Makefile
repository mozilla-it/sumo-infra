export ENVIRONMENT ?= dev
export CERT_ARN

setup-service: check-env
	j2 sumo.service.yaml | kubectl apply -f -

check-env:
ifndef CERT_ARN
	$(error CERT_ARN is undefined)
endif

.PHONY: setup-service



