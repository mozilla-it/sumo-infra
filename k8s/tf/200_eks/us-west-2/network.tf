data "aws_security_group" "nodes_k8s_us-west-2a_sumo_mozit_cloud" {
  id = "sg-0fde630fb730ee9ed"
}

data "aws_security_group" "nodes_k8s_us-west-2b_sumo_mozit_cloud" {
  id = "sg-05f3b5d24b59143e9"
}

data "aws_security_group" "sumo-eks-us-west-2" {
  id = "sg-0b5c332983a11887c"
}
