output "asg_id" {
  description = "auto scaling group id"
  value = aws_autoscaling_group.group.id
}

output "asg_arn" {
  description = "auto scaling group arn"
  value = aws_autoscaling_group.group.arn
}

output "asg_name" {
  description = "auto scaling group name"
  value = aws_autoscaling_group.group.name
}