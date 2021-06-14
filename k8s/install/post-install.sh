#!/bin/bash
# Configure various bits of a SUMO Kubernetes cluster including secrets and cluster services like fluentd, calico, autoscalers, etc.
# Requires GNU sed vs BSD sed.  `brew install gnu-sed`

set -u

if [ ! -f ./config.sh ]; then
    echo "config.sh not found"
    exit 1
fi

source ./config.sh

die() {
    echo "$*" 1>&2
    exit 1
}

if [ "${KOPS_CLUSTER_NAME}" != "$(kubectl config current-context)" ]; then
    echo "Your kubeconfig is pointing to a different cluster than the environment claims, bailing"
    exit 1
fi

validate_cluster() {
    echo "Validating cluster ${KOPS_CLUSTER_NAME}"
    kops validate cluster
    RV=$?

    return "${RV}"
}

set_tf_resource_name() {
    export TF_RESOURCE_NAME=$(echo ${KOPS_CLUSTER_NAME} | tr "." "-")
}

apply_cluster_autoscaler_tf() {
    set_tf_resource_name
    # we can now specify the exact ASG instead of "*" for the autoscaler policy
    # https://github.com/kubernetes/autoscaler/pull/527
    # https://docs.aws.amazon.com/autoscaling/latest/userguide/control-access-using-iam.html#policy-auto-scaling-resources
    echo "Generating ./out/terraform/cluster_autoscaler.tf"
    cat <<BASHEOF > ./out/terraform/cluster_autoscaler.tf
# This file is generated via post-install.sh
resource "aws_iam_policy" "nodes-${TF_RESOURCE_NAME}-autoscaler-policy" {
    name        = "nodes-${TF_RESOURCE_NAME}-autoscaler-policy"
    path        = "/"
    description = "Policy for K8s AWS autoscaler"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "autoscaler-attach" {
    role       = "\${aws_iam_role.nodes-${TF_RESOURCE_NAME}.name}"
    policy_arn = "\${aws_iam_policy.nodes-${TF_RESOURCE_NAME}-autoscaler-policy.arn}"
}
BASHEOF

    # set ASG max size so to allow the cluster autoscaler to scale up
    # retains whitespace for easier reading :-)
    echo "Editing ./out/terraform/kubernetes.tf to increase max_size"
    sed -ri "s/max_size(\s*)=(\s*)$KOPS_NODE_COUNT/max_size\\1=\2$MAX_NODE_COUNT/" ./out/terraform/kubernetes.tf
    echo "*** Applying cluster_autoscaler terraform, press enter then read all proposed changes carefully before continuing ***"
    read
    cd ./out/terraform
    terraform init > /dev/null
    terraform apply
    cd - > /dev/null
    echo "Done applying cluster_autoscaler terraform"
    echo "You may want to git commit the modified ./out/terraform/kubernetes.tf with increased max_size"
}

install_yar() {
    echo "Installing yar"

    # Check we have access to the secrets repo
    if [ ! -f "${SECRETS_PATH}/services/yar/yar-secrets.yaml" ]; then
        echo "Error: could not access ${SECRETS_PATH}/services/yar/yar-secrets.yaml"
        echo "Check \$SECRETS_PATH env var is set in your config.sh for this cluster and sourced"
        exit 8
    fi

    # If the namespace already exists, delete it first so we don't get duplicate replicasets
    kubectl get namespace sumo-yar > /dev/null
    if [ $? -eq 0 ]; then
        kubectl delete namespace sumo-yar
    fi
    kubectl apply -f "${SECRETS_PATH}/services/yar/yar-namespace.yaml"
    kubectl apply -f "${SECRETS_PATH}/services/yar/yar-secrets.yaml"
    kubectl apply -f "${SECRETS_PATH}/services/yar/yar.yaml"

    echo "Done installing yar"
}

install_newrelic() {
    echo "Installing New Relic"

    # Check we have access to the secrets repo
    if [ ! -f "${SECRETS_PATH}/services/newrelic/newrelic-config.yaml" ]; then
        echo "Error: could not access ${SECRETS_PATH}/services/newrelic/newrelic-config.yaml"
        echo "Check \$SECRETS_PATH env var is set in your config.sh for this cluster and sourced"
        exit 8
    fi

    NR_DIR=${KOPS_INSTALLER}/services/newrelic/
    kubectl apply -f "${NR_DIR}/newrelic-namespace.yaml"
    kubectl apply -f ${SECRETS_PATH}/services/newrelic/newrelic-config.yaml
    cat ${NR_DIR}/newrelic-daemonset.yaml.tmpl | envsubst | kubectl apply -f -
    echo "Done installing New Relic"
}

install_calico_rbac() {
    echo "Installing calico"
    if [ ${KOPS_NETWORKING} != "calico" ]; then
        echo "Networking not using calico, not doing anything"
        continue
    else
        kubectl apply -f "https://docs.projectcalico.org/${CALICO_VERSION:-v3.2}/getting-started/kubernetes/installation/rbac.yaml"
    fi
    echo "Done installing calico"
}

install_fluentd() {
    echo "Installing fluentd"
    PAPERTRAIL_CONFIG="${SECRETS_PATH}/${KOPS_ZONES}/papertrail.env"
    if [ ! -f "${PAPERTRAIL_CONFIG}" ]; then
        echo "Error: could not access ${PAPERTRAIL_CONFIG}"
        echo "Check \$SECRETS_PATH env var is set in your config.sh for this cluster and sourced"
        exit 1
    fi

    source "${PAPERTRAIL_CONFIG}"
    (cd ${KOPS_INSTALLER}/services/fluentd && make FLUENTD_SYSLOG_HOST=${SYSLOG_HOST} FLUENTD_SYSLOG_PORT=${SYSLOG_PORT})
    echo "Done installing fluentd"
}

install_cluster_autoscaler() {
    echo "Installing cluster autoscaler"
    apply_cluster_autoscaler_tf
    # https://github.com/kubernetes/dashboard/issues/2326#issuecomment-326651713
    set +e  # This will return 1 if the binding already exists so do not bomb the script on it
    kubectl create clusterrolebinding \
        --user system:serviceaccount:kube-system:default \
        kube-system-cluster-admin --clusterrole cluster-admin
    set -e
    j2 ${KOPS_INSTALLER}/services/cluster-autoscaler/autoscaler.yaml.j2 | kubectl apply -f -
    echo "Done installing cluster autoscaler"
}

install_kubecost() {
    echo "Install kubecost"
    kubectl apply -f "${KOPS_INSTALLER}/services/kubecost/kubecost-namespace.yaml"
    kubectl apply -n kubecost -f "${KOPS_INSTALLER}/services/kubecost/kubecost.yaml"
    echo "Run 'kubectl -n kubecost port-forward service/kubecost-cost-analyzer 9090:9090' to connect to kubecost"
    echo "Done installiing kubecost"
}

install_block-aws() {
    echo "Install block-aws"
    kubectl apply -f "${KOPS_INSTALLER}/services/block-aws/block-aws-namespace.yaml"
    kubectl apply -f "${KOPS_INSTALLER}/services/block-aws/block-aws-networkpolicy.yaml"

    # Check we have access to the secret
    if [ ! -f "${SECRETS_PATH}/${KOPS_SHORTNAME#k8s.}/credentials-block-aws" ]; then
        echo "Error: could not access ${SECRETS_PATH}/${KOPS_SHORTNAME#k8s.}/credentials-block-aws"
        echo "Check \$SECRETS_PATH env var is set in your config.sh for this cluster and sourced"
        exit 7
    fi

    # Check if the secret already exists so we don't error out on kubectl create secret step
    set +e
    kubectl -n sumo-cron get secret blockaws-secrets > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        set -e
        echo "Creating block-aws secret in k8s cluster"
        kubectl -n sumo-cron create secret generic blockaws-secrets \
            --from-env-file "${SECRETS_PATH}/${KOPS_SHORTNAME#k8s.}/credentials-block-aws"
    else
        set -e
        echo "block-aws secret already exists in k8s cluster.  If you need to update it, delete it first with 'kubectl -n sumo-cron delete secret blockaws-secrets' and rerun this script"
    fi
    kubectl apply -f "${KOPS_INSTALLER}/services/block-aws/block-aws-cron.yaml"
    echo "Done installiing block-aws"
}

install_metrics-server() {
    echo "Installing metrics-server"
    kubectl apply -f "${KOPS_INSTALLER}/services/metrics-server/metrics-server.yaml"
    echo "Done installing metrics-server"
}

install_ark() {
    echo "Installing ark"

    # Ensure the supporting ark terraform has already been applied
    cd ../tf/10_ark/$(basename $PWD)
    terraform output ark_bucket > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: ark terraform not applied, please apply that first in ../tf/10_ark/$(basename $PWD).  Then put the secrets it outputs into ${SECRETS_PATH}/${KOPS_SHORTNAME#k8s.}/credentials-ark"
        echo "See the README at https://github.com/mozilla-it/sumo-infra/blob/master/k8s/README.md for more details"
        exit 6
    fi
    cd -

    kubectl apply -f "${KOPS_INSTALLER}/services/ark/ark-prereqs.yaml"

    # Check we have access to the secret
    if [ ! -f "${SECRETS_PATH}/${KOPS_SHORTNAME#k8s.}/credentials-ark" ]; then
        echo "Error: could not access ${SECRETS_PATH}/${KOPS_SHORTNAME#k8s.}/credentials-ark"
        echo "Check \$SECRETS_PATH env var is set in your config.sh for this cluster and sourced"
        exit 7
    fi

    # Check if the secret already exists so we don't error out on kubectl create secret step
    set +e
    kubectl -n heptio-ark get secret cloud-credentials > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        set -e
        echo "Creating ark secret in k8s cluster"
        kubectl -n heptio-ark create secret generic cloud-credentials \
            --from-file cloud="${SECRETS_PATH}/${KOPS_SHORTNAME#k8s.}/credentials-ark"
    else
        set -e
        echo "Ark secret already exists in k8s cluster.  If you need to update it, delete it first with 'kubectl -n heptio-ark delete secret cloud-credentials' and rerun this script"
    fi

    export AWS_REGION=${KOPS_REGION}
    export ARK_BUCKET=$(cd ../tf/10_ark/$(basename $PWD) && terraform output ark_bucket)
    if [ "$ARK_BUCKET" == "" ]; then
        echo "Error: could not get the name of the Ark bucket, you likely need to run the terraform that creates it, see the README at https://github.com/mozilla-it/sumo-infra/blob/master/k8s/README.md"
        echo "Exiting"
        exit 1
    fi
    (cd "${KOPS_INSTALLER}/services/ark" && make deploy)

    kubectl apply -f "${KOPS_INSTALLER}/services/ark/ark-deployment.yaml"
    kubectl apply -f "${KOPS_INSTALLER}/services/ark/ark-schedule.yaml"
    echo "Done installing ark"
}

install_namespaces() {
    echo "Installing namespaces"

    # Ensure the supporting ark terraform has already been applied
    kubectl get namespace sumo_dev > /dev/null
    if [ $? -ne 0 ]; then
        kubectl create namespace sumo_dev
        if [ $? -ne 0 ]; then
            echo "Error: could not create new namespace sumo_dev"
            exit 7
        fi
    fi
}

install_elb_service() {
    echo "Setting up LoadBalancer service"

    (cd "${KOPS_INSTALLER}/services/cluster-lb" && make deploy)
}

install_all() {
    install_cluster_autoscaler
    install_calico_rbac
    install_fluentd
    install_block-aws
    install_ark
    install_newrelic
    install_metrics-server
}

# Turn off annoying set -u in case someone sources this script
set +u

usage() {
    echo "Usage: $(basename ${0}) <arg>"
    echo "  args: "
    echo "  cluster_autoscaler      install cluster autoscaler"
    echo "  calico                  install calico networking"
    echo "  newrelic                install newrelic"
    echo "  block-aws               install the AWS metadata block"
    echo "  ark                     install ark/velero for backups"
    echo "  metrics-server          install metrics-server"
    echo "  fluentd                 install fluentd"
    echo "  elb_service             install ELB service"
    echo "  yar                     install yar service"
    echo "  kubecost                install kubecost for cost analysis"
    echo "  all                     install all of the above components"
}

# Allow us to install one component at a time (or all of them)
if [ $# -eq 1 ]; then
    set -e
    case $1 in
        cluster_autoscaler)
            install_cluster_autoscaler;;
        calico)
            install_calico_rbac;;
        newrelic)
            install_newrelic;;
        block-aws)
            install_block-aws;;
        ark)
            install_ark;;
        metrics-server)
            install_metrics-server;;
        fluentd)
            install_fluentd;;
        namespaces)
            install_namespaces;;
        elb_service)
            install_elb_service;;
        yar)
            install_yar;;
        kubecost)
            install_kubecost;;
        all)
            install_all;;
        -h|--help)
            usage
            set +e
            exit
            ;;
        *)
            echo "Unknown argument ${1}, exiting"
            echo
            set +e
            usage
            exit 1
            ;;
    esac
    set +e
else
    usage
    exit 2
fi
