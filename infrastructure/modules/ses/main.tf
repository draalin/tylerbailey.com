data "aws_route53_zone" "selected" {
  name = "${var.domain_name}."
}

resource "aws_ses_domain_identity" "noreply" {
  domain = var.domain_name
}

resource "aws_ses_domain_mail_from" "noreply" {
  domain           = aws_ses_domain_identity.noreply.domain
  mail_from_domain = "noreply.${aws_ses_domain_identity.noreply.domain}"
}

resource "aws_route53_record" "noreply_amazonses_verification_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.noreply.verification_token]
}

resource "aws_route53_record" "ses_domain_mail_from_mx" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = aws_ses_domain_mail_from.noreply.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.us-east-1.amazonses.com"]
}

resource "aws_route53_record" "ses_domain_mail_from_txt" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = aws_ses_domain_mail_from.noreply.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}