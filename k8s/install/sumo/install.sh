#!/bin/bash

kops create cluster ${KOPS_NAME} \
    --authorization=RBAC \
    --cloud aws \
    --kubernetes-version=${KOPS_K8S_VERSION} \
    --master-size=${KOPS_MASTER_SIZE} \
    --master-volume-size=${KOPS_MASTER_VOLUME_SIZE_GB} \
    --master-zones=${KOPS_MASTER_ZONES} \
    --networking=calico \
    --node-count=${KOPS_NODE_COUNT} \
    --node-size=${KOPS_NODE_SIZE} \
    --node-volume-size=${KOPS_NODE_VOLUME_SIZE_GB} \
    --ssh-access=${KOPS_SSH_IP} \
    --ssh-public-key=${KOPS_PUBLIC_KEY} \
    --target=terraform \
    --vpc=${KOPS_VPC_ID} \
    --zones=${KOPS_ZONES}
