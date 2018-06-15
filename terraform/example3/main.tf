# "admin" role requires MFA, so it can be assumed like this:
# aws sts assume-role --role-arn arn:aws:iam::835367859851:role/demo-terraform-admin --role-session-name "assumed-role-admin" --serial-number arn:aws:iam::835367859851:mfa/anton --token-code 123456
# Retrieved credentials can be placed should be stored as AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN

#########################
# Terraform configuration
#########################
terraform {
  required_version = ">= 0.11"

  backend "s3" {
    bucket  = "my-tf-states-anton-demo"
    key     = "terraform-delivery-pipeline-example3"
    region  = "eu-west-1"
    encrypt = true
  }
}

###########
# Providers
###########
provider "aws" {
  version = ">= 1.12.0"
  region  = "eu-west-1"
}

###########
# Variables
###########
variable "key_name" {
  description = "Name of EC2 keypair to use"
  default     = ""
}

##############
# Data sources
##############
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

data "template_file" "ec2_userdata" {
  template = <<EOF
#cloud-config
runcmd:
  - yum install -y nginx
  - service nginx restart
EOF
}

#########
# Modules
#########
module "sg_web" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.20.0"

  name   = "demo-web"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "ssh-tcp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "demo-web"
  ami                         = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
  vpc_security_group_ids      = ["${module.sg_web.this_security_group_id}"]
  associate_public_ip_address = true
  key_name                    = "${var.key_name}"
  user_data                   = "${data.template_file.ec2_userdata.rendered}"
}

###########
# Resources
###########
resource "aws_eip" "ec2" {
  vpc      = true
  instance = "${module.ec2.id[0]}"
}

#########
# Outputs
#########
output "ec2_website_eip_public_ip" {
  description = "Public IP of EC2 instance running an application"
  value       = "${aws_eip.ec2.public_ip}"
}
