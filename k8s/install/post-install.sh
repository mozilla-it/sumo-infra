#!/bin/bash
# Configure various bits of a SUMO Kubernetes cluster including secrets and cluster services like fluentd, mig, calico, autoscalers, etc.
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

validate_cluster() {
    echo "Validating cluster ${KOPS_CLUSTER_NAME}"
    kops validate cluster
    RV=$?

    return "${RV}"
}

set_tf_resource_name() {
    export TF_RESOURCE_NAME=$(echo ${KOPS_CLUSTER_NAME} | tr "." "-")
}

apply_ingress_controller_tf() {
    set_tf_resource_name
    # https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/
    # https://kubernetes-sigs.github.io/aws-alb-ingress-controller/
    echo "Generating ./out/terraform/aws_alb_ingress_controller.tf"
    cat <<BASHEOF > ./out/terraform/aws_alb_ingress_controller.tf
# This file is generated via post-install.sh
resource "aws_iam_policy" "nodes-${TF_RESOURCE_NAME}-aws-alb-ingress-controller" {
    name        = "nodes-${TF_RESOURCE_NAME}-aws-alb-ingress-controller"
    path        = "/"
    description = "Policy for K8s AWS ALB Ingress Controller"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
              ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ingress-attach" {
    role       = "\${aws_iam_role.nodes-${TF_RESOURCE_NAME}.name}"
    policy_arn = "\${aws_iam_policy.nodes-${TF_RESOURCE_NAME}-aws-alb-ingress-controller.arn}"
}
BASHEOF

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

    DEFAULT_MAX=$(echo "$((4 * ${KOPS_NODE_COUNT}))")
    # set ASG max size so to allow the cluster autoscaler to scale up
    # retains whitespace for easier reading :-)
    echo "Editing ./out/terraform/kubernetes.tf to increase max_size"
    sed -ri "s/max_size(\s*)=(\s*)$KOPS_NODE_COUNT/max_size\\1=\2$DEFAULT_MAX/" ./out/terraform/kubernetes.tf
    echo "*** Applying cluster_autoscaler terraform, press enter then read all proposed changes carefully before continuing ***"
    read
    cd ./out/terraform
    terraform init > /dev/null
    terraform apply
    cd - > /dev/null
    echo "Done applying cluster_autoscaler terraform"
    echo "You may want to git commit the modified ./out/terraform/kubernetes.tf with increased max_size"
}

install_mig() {
    echo "Installing mig"
    kubectl apply -f "${KOPS_INSTALLER}/services/mig/mig-namespace.yaml"

    # Check we have access to the secrets repo
    if [ ! -f "${SECRETS_PATH}/services/mig/agent.key" ]; then
        echo "Error: could not access ${SECRETS_PATH}/services/mig/agent.key"
        echo "Check \$SECRETS_PATH env var is set in your config.sh for this cluster and sourced"
        exit 8
    fi

    # Export mqpassword
    # Check if the secret already exists so we don't error out on kubectl create secret step
    set +e
    kubectl -n mig get secret mig-agent-secrets > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        set -e
        echo "Creating mig secret in k8s cluster"
        kubectl -n mig create secret generic mig-agent-secrets \
            --from-file=${SECRETS_PATH}/services/mig/agent.key \
            --from-file=${SECRETS_PATH}/services/mig/agent.crt \
            --from-file=${SECRETS_PATH}/services/mig/ca.crt \
            --from-file=${SECRETS_PATH}/services/mig/mig-agent.cfg
    else
        set -e
        echo "Mig secret already exists in k8s cluster.  If you need to update it, delete it first with 'kubectl -n mig delete secret mig-agent-secrets' and rerun this script"
    fi
    kubectl -n mig apply -f ${KOPS_INSTALLER}/services/mig/migdaemonset.yaml
    echo "Done installing mig"
}

install_newrelic() {
    echo "Installing New Relic"

    # Check we have access to the secrets repo
    if [ ! -d "${SECRETS_PATH}/services/newrelic/newrelic-config.yaml" ]; then
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

install_block-aws() {
    echo "Install block-aws"
    kubectl apply -f "${KOPS_INSTALLER}/services/block-aws/block-aws-namespace.yaml"

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
        echo "block-aws secret already exists in k8s cluster.  If you need to update it, delete it first with 'kubectl -n heptio-ark delete secret cloud-credentials' and rerun this script"
    fi
    kubectl apply -f "${KOPS_INSTALLER}/services/block-aws/block-aws-cron.yaml"
    kubectl apply -f "${KOPS_INSTALLER}/services/block-aws/block-aws-networkpolicy.yaml"
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

install_ingress_controller() {
    echo "Installing ingress controller"

    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.0/docs/examples/rbac-role.yaml
    apply_ingress_controller_tf
    (cd "${KOPS_INSTALLER}/services/cluster-lb" && make deploy)
}

install_all() {
    install_cluster_autoscaler
    install_calico_rbac
    install_fluentd
    install_mig
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
    echo "  mig                     install mig"
    echo "  block-aws               install the AWS metadata block"
    echo "  ark                     install ark/velero for backups"
    echo "  metrics-server          install metrics-server"
    echo "  fluentd                 install fluentd"
    echo "  ingress_controller      install ingress controller"
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
        mig)
            install_mig;;
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
        ingress_controller)
            install_ingress_controller;;
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
