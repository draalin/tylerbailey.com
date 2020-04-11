resource "aws_s3_bucket" "website" {
  bucket        = var.domain_name
  acl           = "public-read"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${terraform.workspace}"
  }

  cors_rule {
    allowed_headers = [
      "*",
    ]
    allowed_methods = [
      "GET",
    ]
    allowed_origins = [
      "https://${var.domain_name}",
    ]
    expose_headers  = []
    max_age_seconds = 0
  }

  website {
    error_document = "index.html"
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.website.id}/*"
    }
  ]
}
POLICY
}