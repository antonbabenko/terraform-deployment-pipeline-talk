provider "aws" {
  region = "eu-west-1"
}

resource "random_pet" "bucket" {}

resource "aws_s3_bucket" "app" {
  bucket = "demo-bucket-${random_pet.bucket.id}"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.app.id
  key    = "index.html"

  content = templatefile("../../web/index.html", {
    BUILD_DETAILS = "I was deployed from example1 to ${aws_s3_bucket.app.website_endpoint}"
  })

  content_type = "text/html"
  acl          = "public-read"
}

output "app_website_endpoint" {
  value = aws_s3_bucket.app.website_endpoint
}
