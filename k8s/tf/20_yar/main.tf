resource "aws_iam_user" "yar" {
  name = "${var.iam_user}"
  tags = "${var.base_tags}"
}

resource "aws_iam_policy" "yar" {
  name        = "${var.iam_user}-nacl"
  description = "Allow bot blocking user to add/remove network blocks"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:DeleteNetworkAclEntry",
            "Resource": "arn:aws:ec2:us-west-2:${data.aws_caller_identity.id.account_id}:network-acl/${data.aws_network_acls.default.ids[0]}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:ReplaceNetworkAclEntry",
                "ec2:CreateNetworkAclEntry",
                "ec2:DescribeNetworkAcls"
            ],
            "Resource": "*"
        }
    ]
}

EOF
}

resource "aws_iam_user_policy_attachment" "yar" {
  user       = "${aws_iam_user.yar.name}"
  policy_arn = "${aws_iam_policy.yar.arn}"
}
