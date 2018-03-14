# terraform-delivery-pipeline-talk

This repository contains code for the "Terraform in delivery pipeline" talk by [Anton Babenko](https://github.com/antonbabenko). Usually slides from my tech talks are hosted [here](https://www.slideshare.net/AntonBabenko).

There are several independent Terraform configurations in `terraform` directory.

## terraform/example1

Create S3 bucket with single object placed there. There is no automation, no support for multiple environments. This code can be executed using `terraform init && terraform plan && terraform apply`.

## terraform/example2

[Terraform community module](https://github.com/terraform-community-modules) is used to create security group, AWS AMI data source is used to find AMI produced
by configuration at `packer/app.json`.

## terraform/example3

[Terraform AWS modules](https://github.com/terraform-aws-modules) are used to create security group and launch an EC2 instance. CircleCI workflow configuration is at `.circleci/config.yml`.

## Complete CircleCI workflow

<img src="https://github.com/antonbabenko/terraform-delivery-pipeline-talk/blob/master/terraform_circleci_pipeline.png?raw=true" alt="Terraform in your delivery pipeline - CircleCI workflow" align="center" />
