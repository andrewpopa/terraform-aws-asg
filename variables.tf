variable "launch_cfg_name" {
  type        = string
  description = "launch configuration name"
}

variable "image_id" {
  type        = string
  description = "ec2 image id for lunch"
}

variable "instance_type" {
  type        = string
  description = "ec2 instance type"
}

variable "iam_instance_profile" {
  type        = string
  description = "iam instance profile associated"
}

variable "key_name" {
  type        = string
  description = "key for the ec2 instance"
}

variable "security_groups" {
  type        = list
  description = "security group list"
}

variable "associate_public_ip_address" {
  type        = bool
  description = "associate public ip"
}

variable "user_data_base64" {
  type        = string
  description = "user data"
}

variable "root_block_device" {
  type        = map(string)
  description = "device propertiece"
}

variable "asg_name" {
  type        = string
  description = "auto scalling group name"
}

variable "max_size" {
  type        = number
  description = "max number in asg"
}

variable "min_size" {
  type        = number
  description = "min number in asg"
}

variable "health_check_type" {
  type        = string
  description = "ec2 or elb"
}

variable "vpc_zone_identifier" {
  type        = list
  description = "list of subnets to launch resources in"
}

variable "wait_for_capacity_timeout" {
  type        = string
  description = "tf should wait for asg to be healthy"
}

variable "target_group_arns" {
  type = list
  description = "list of arns in target group"
}

variable "asg_tags" {
  description = "asg tags"
}