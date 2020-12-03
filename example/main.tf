module "vpc" {
  source = "github.com/andrewpopa/terraform-aws-vpc"

  # VPC
  cidr_block          = "172.16.0.0/16"
  vpc_public_subnets  = ["172.16.10.0/24", "172.16.11.0/24", "172.16.12.0/24"]
  vpc_private_subnets = ["172.16.13.0/24", "172.16.14.0/24", "172.16.15.0/24"]
  availability_zones  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  vpc_tags = {
    vpc            = "my-aws-vpc"
    public_subnet  = "public-subnet"
    private_subnet = "private-subnet"
    internet_gw    = "my-internet-gateway"
    nat_gateway    = "nat-gateway"
  }
}

module "security-group" {
  source = "github.com/andrewpopa/terraform-aws-security-group"

  # Security group
  security_group_name        = "my-aws-security-group"
  security_group_description = "my-aws-security-group-descr"
  ingress_ports              = [22, 443, 8800]
  vpc_id                     = module.vpc.vpc_id
}

module "key-pair" {

  // ssh key
  source = "github.com/andrewpopa/terraform-aws-key-pair"
}

module "iam-profile" {
  source = "github.com/andrewpopa/terraform-aws-iam-profile"

  // iam policy
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": ["s3:*"],
        "Resource": ["arn:aws:s3:::ptfe-external-svc-snapshot"]
      },
      {
        "Effect": "Allow",
        "Action": "s3:ListAllMyBuckets",
        "Resource": "arn:aws:s3:::*"
      }
    ]
  }
  EOF
}

module "alb" {
  source = "github.com/andrewpopa/terraform-aws-alb"

  // Load balancer
  certificate_body  = file("files/certificate.pem")
  private_key       = file("files/private_key.pem")
  certificate_chain = file("files/fullchain.pem")
  alb_name_prefix   = "ptfe-loadbalancer"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  vpc_id            = module.vpc.vpc_id
  tf_subnet         = module.vpc.public_subnets
  sg_id             = module.security-group.sg_id

  lbports = {
    8800 = "HTTPS",
    443  = "HTTPS",
  }
  alb_tags = {
    name = "alb-name"
  }
  cert_tags = {
    name = "letsencrypt-certificates"
  }
}

module "asg" {
  source                      = "../"
  launch_cfg_name             = "launch_cfg"
  asg_name                    = "asg-name"
  image_id                    = "ami-0085d4f8878cddc81"
  instance_type               = "m5.large"
  iam_instance_profile        = module.iam-profile.iam_instance_profile # iam profile
  key_name                    = module.key-pair.public_key_name         # ssh_keys
  security_groups             = [module.security-group.sg_id]
  associate_public_ip_address = true
  user_data_base64            = ""
  max_size                    = 5
  min_size                    = 1
  health_check_type           = "EC2"
  vpc_zone_identifier         = module.vpc.public_subnets
  wait_for_capacity_timeout   = 0
  target_group_arns           = module.alb.target_group_arn
  root_block_device = {
    type = "gp2"
    size = 50
  }
  asg_tags = {
    Key = "name"
  }
}