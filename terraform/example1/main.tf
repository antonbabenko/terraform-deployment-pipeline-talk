terraform {
  backend "s3" {
    bucket  = "my-tf-states-anton-demo"
    key     = "terraform-delivery-pipeline-example1"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "random_pet" "bucket" {}

resource "aws_s3_bucket" "app" {
  bucket = "fullstackfest-${random_pet.bucket.id}"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

data "template_file" "index" {
  template = "${file("../../web/index.html")}"

  vars {
    BUILD_DETAILS = "I was deployed from example1 to ${aws_s3_bucket.app.website_endpoint}"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket       = "${aws_s3_bucket.app.id}"
  key          = "index.html"
  content      = "${data.template_file.index.rendered}"
  etag         = "${md5(data.template_file.index.rendered)}"
  content_type = "text/html"
  acl          = "public-read"
}

output "app_website_endpoint" {
  value = "${aws_s3_bucket.app.website_endpoint}"
}
