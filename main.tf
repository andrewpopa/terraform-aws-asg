resource "aws_launch_configuration" "launch_configuration" {
  name                        = var.launch_cfg_name
  image_id                    = var.image_id
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_instance_profile
  key_name                    = var.key_name
  security_groups             = var.security_groups
  associate_public_ip_address = var.associate_public_ip_address
  user_data_base64            = var.user_data_base64
  root_block_device {
    volume_type = var.root_block_device["type"]
    volume_size = var.root_block_device["size"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "group" {
  name                      = var.asg_name
  max_size                  = var.max_size
  min_size                  = var.min_size
  launch_configuration      = aws_launch_configuration.launch_configuration.name
  health_check_type         = var.health_check_type
  vpc_zone_identifier       = var.vpc_zone_identifier
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  target_group_arns         = var.target_group_arns
  dynamic "tag" {
    for_each = merge({ Name = "${var.asg_name}-instance" }, var.asg_tags)
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  timeouts {
    delete = "30m"
  }
}

resource "aws_autoscaling_lifecycle_hook" "cycle" {
  name                   = "${var.launch_cfg_name}-${var.asg_name}"
  autoscaling_group_name = aws_autoscaling_group.group.name
  default_result         = "ABANDON"
  heartbeat_timeout      = 1500
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
}