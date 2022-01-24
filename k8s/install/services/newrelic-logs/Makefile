export MANIFEST_FILE ?= "newrelic-logs.yaml.j2"
export FLUENTD_CPU_LIMIT ?= 100m
export FLUENTD_MEMORY_LIMIT ?= 256Mi
export NR_LICENSE_B64 = $(shell printf "${NR_LICENSE_KEY}" | base64)

install-fluentd: check-env
	j2 ${MANIFEST_FILE} | kubectl apply -f -

test: check-env
	j2 ${MANIFEST_FILE}

delete: check-env
	j2 ${MANIFEST_FILE} | kubectl delete -f -

diff: check-env
	j2 ${MANIFEST_FILE} | kubectl diff -f -

# Note that ifndef and endif are not indented to process env vars
# before the rest of the script
check-env:
ifndef NR_LICENSE_KEY
	$(error NR_LICENSE_KEY is undefined)
endif
ifndef CLUSTER_NAME
	$(error CLUSTER_NAME is undefined)
endif

.PHONY: check-env

