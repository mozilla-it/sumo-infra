#output "k8s_asg-a" {
#  value = data.aws_autoscaling_groups.group-a.names[0]
#}
#
#output "k8s_asg-b" {
#  value = data.aws_autoscaling_groups.group-b.names
#}
#
#output "lb-sg" {
#  value = aws_security_group.lb.id
#}
#
#output "nodes-a-sg" {
#  value = data.aws_security_group.nodes-a.id
#}
#
#output "nodes-b-sg" {
#  value = data.aws_security_group.nodes-b.id
#}
#
