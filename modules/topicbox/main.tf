resource "cloudflare_record" "mx" {
  count           = 2
  zone_id         = var.zone_id
  name            = "@"
  type            = "MX"
  value           = "mx${count.index}.topicbox.com"
  priority        = 10
  ttl             = 86400
  allow_overwrite = var.allow_overwrite
}

resource "cloudflare_record" "dkim" {
  count           = 3
  zone_id         = var.zone_id
  name            = "dkim-${count.index + 1}._domainkey"
  type            = "CNAME"
  value           = "dkim-${count.index + 1}._domainkey.${var.fqdn}.dkim.topicbox.com"
  allow_overwrite = var.allow_overwrite
}

resource "cloudflare_record" "dmarc" {
  zone_id         = var.zone_id
  name            = "_dmarc"
  type            = "TXT"
  value           = "v=DMARC1; p=quarantine; rua=mailto:dmarcreports@whitestar.systems"
  allow_overwrite = var.allow_overwrite
}

resource "cloudflare_record" "spf" {
  zone_id         = var.zone_id
  name            = "@"
  type            = "TXT"
  value           = "v=spf1 ${var.allowed_senders} -all"
  allow_overwrite = var.allow_overwrite
}
