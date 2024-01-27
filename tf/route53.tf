resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = {
    "Project" = var.project_name
  }
}

resource "aws_route53_record" "root-a" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.root_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.root_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www-a" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.www_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.www_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.main.zone_id
  name    = ""
  type    = "MX"

  records = [
    "${var.mx_record_value}",
  ]

  ttl = "600"
}

resource "aws_route53_record" "mail" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "mail.${var.domain_name}"
  type    = "A"
  ttl     = 600

  records = [
    "${var.a_record_mail_value}",
  ]
}

resource "aws_route53_record" "dkim" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "default._domainkey.${var.domain_name}"
  type    = "TXT"
  ttl     = 600

  records = [
    "${var.dkim_record_value}",
  ]
}

resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.main.zone_id
  name    = ""
  type    = "TXT"
  ttl     = 600

  records = [
    "${var.spf_record_value}",
  ]
}

resource "aws_route53_record" "a" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "status"
  type    = "A"
  ttl     = 600

  records = [
    "${var.status_a_record_value}",
  ]
}
