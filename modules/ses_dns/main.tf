resource "cloudflare_record" "dkim" {
  count           = length(var.dkim_ids)
  zone_id         = var.zone_id
  name            = "${var.dkim_ids[count.index]}._domainkey"
  type            = "CNAME"
  value           = "${var.dkim_ids[count.index]}.dkim.amazonses.com"
  allow_overwrite = var.allow_overwrite
}


resource "cloudflare_record" "txt" {
  count           = length(var.txt_verification)
  zone_id         = var.zone_id
  name            = "_amazonses"
  type            = "TXT"
  value           = var.txt_verification[count.index]
  allow_overwrite = var.allow_overwrite
}
