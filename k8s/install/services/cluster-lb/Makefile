export ENVIRONMENT ?= dev
export CERT_ARN
export K8S_NAMESPACE
export SUMO_APP_NAME
export SUMO_NODEPORT_NAME ?= nodeport
export SUMO_ENV_PORT ?= 8000

deploy: check-env
	j2 sumo.service.yaml.j2 | kubectl apply -f -

check-env:
ifndef CERT_ARN
	$(error CERT_ARN is undefined)
endif
ifndef K8S_NAMESPACE
        $(error K8S_NAMESPACE is undefined)
endif
ifndef SUMO_APP_NAME
        $(error SUMO_APP_NAME is undefined)
endif
