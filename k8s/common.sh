#!/bin/bash

export KUBERNETES_VERSION="1.11.8"

export KOPS_DOMAIN="sumo.mozit.cloud"
export KOPS_MASTER_COUNT=3
export KOPS_MASTER_SIZE="m4.large"
export KOPS_MASTER_VOLUME_SIZE_GB=250
export KOPS_NETWORKING="calico"
export KOPS_NODE_COUNT=3
export KOPS_NODE_SIZE="m4.xlarge"
export KOPS_NODE_VOLUME_SIZE_GB=250

# s3 bucket
# Generate random hash by doing
# date +%s | md5sum | cut -d ' ' -f 1
export KOPS_STATE_BUCKET="sumo-kops-state-095732026120"
export KOPS_STATE_STORE="s3://${KOPS_STATE_BUCKET}"

export STATE_BUCKET="sumo-state-095732026120"
export STATE_BUCKET_STORE="s3://${STATE_BUCKET}"
