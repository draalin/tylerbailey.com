data "aws_route53_zone" "selected" {
  name = "${var.domain_name}."
}

resource "aws_acm_certificate" "certificate" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.domain_name}"]
  tags = {
    Name = "${var.project_name}-certificate"
  }
  lifecycle {
    ignore_changes = [subject_alternative_names]
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.selected.zone_id
  records = [aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value]
  ttl     = 60
}
