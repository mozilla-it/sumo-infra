#!/bin/bash

kops create cluster --name=${KOPS_CLUSTER} \
    --authorization=RBAC \
    --cloud aws \
    --kubernetes-version=${KUBERNETES_VERSION} \
    --master-count=${KOPS_MASTER_COUNT} \
    --master-size=${KOPS_MASTER_SIZE} \
    --master-volume-size=${KOPS_MASTER_VOLUME_SIZE_GB} \
    --master-zones=${KOPS_MASTER_ZONES} \
    --networking=${KOPS_NETWORKING} \
    --node-count=${KOPS_NODE_COUNT} \
    --node-size=${KOPS_NODE_SIZE} \
    --node-volume-size=${KOPS_NODE_VOLUME_SIZE_GB} \
    --ssh-access=${KOPS_SSH_IP} \
    --ssh-public-key=${KOPS_SSH_PUB_KEY:-~/.ssh/id_rsa.pub} \
    --target=terraform \
    --vpc=${KOPS_VPC_ID} \
    --zones=${KOPS_ZONES} \
    --subnets=${KOPS_SUBNETS}
