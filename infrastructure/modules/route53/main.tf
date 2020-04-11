data "aws_route53_zone" "selected" {
  name = "${var.domain_name}."
}

resource "aws_route53_record" "cloudfront" {
  name    = data.aws_route53_zone.selected.name
  zone_id = data.aws_route53_zone.selected.zone_id
  type    = "A"
  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront
    evaluate_target_health = true
  }
}
