resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    domain_name = var.media
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = join("/", ["origin-access-identity/cloudfront", aws_cloudfront_origin_access_identity.cfoai.id])
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = var.project_name

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfrontlogs.bucket_domain_name
    prefix          = "cflogs"

  }

  default_root_object = "index.html"

  aliases = ["${var.domain_name}"]

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = var.compress
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB"]
    }
  }

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-cfdistribution"
  }

  web_acl_id = var.web_acl_cf

  viewer_certificate {
    acm_certificate_arn = var.certificate
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_identity" "cfoai" {
  comment = "${var.project_name}-${terraform.workspace}-cfoai"
}

resource "aws_s3_bucket" "cloudfrontlogs" {
  bucket        = "${var.project_name}-${terraform.workspace}-cloudfrontlogs"
  acl           = "private"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-cloudfrontlogs"
  }
}