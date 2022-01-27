module "yar_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.3"
  create_role                   = true
  role_name                     = "yar-sumo-eks-us-west-2-role"
  provider_url                  = replace(module.eks-us-west-2.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.yar_iam_role_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:sumo-yar:yar"]
  tags                          = { "Name" = "yar-role" }
}

resource "aws_iam_policy" "yar_iam_role_policy" {
  name_prefix = "yar-policy"
  description = "EKS yar policy for cluster us-west-2"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "ec2:DeleteNetworkAclEntry",
        "Resource" : "arn:aws:ec2:us-west-2:${data.aws_caller_identity.current.account_id}:network-acl/${tolist(data.aws_network_acls.default.ids)[0]}"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:ReplaceNetworkAclEntry",
          "ec2:CreateNetworkAclEntry",
          "ec2:DescribeNetworkAcls"
        ],
        "Resource" : "*"
      }
    ]
  })

}
