#########################
# Terraform configuration
#########################
terraform {
  backend "s3" {
    bucket  = "my-tf-states-anton-demo"
    key     = "terraform-delivery-pipeline-example2"
    region  = "eu-west-1"
    encrypt = true
  }
}

###########
# Providers
###########
provider "aws" {
  region = "eu-west-1"
}

###########
# Variables
###########
variable "vpc_id" {
  description = "ID of VPC where resources will be created"
}

variable "subnet_id" {
  description = "ID of subnet where resources will be created"
}

variable "instance_type" {
  description = "Type of EC2 instance to launch"
}

##############
# Data sources
##############
data "aws_ami" "app" {
  most_recent = true

  filter {
    name = "name"

    values = ["fullstackfest-demo-*"]
  }
}

#########
# Modules
#########
module "sg_web" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "my-app"
  vpc_id = "${var.vpc_id}"
}

###########
# Resources
###########
resource "aws_instance" "app" {
  ami                    = "${data.aws_ami.app.id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${module.sg_web.security_group_id_web}"]

  tags {
    Name = "fullstackfest-demo"
  }
}

#########
# Outputs
#########
output "app_public_ip" {
  description = "Public IP of EC2 instance running an application"
  value       = "${aws_instance.app.public_ip}"
}
