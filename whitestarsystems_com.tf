resource "cloudflare_zone" "whitestarsystems_com" {
  account_id = local.cf_account_id
  zone       = "whitestarsystems.com"
}

module "whitestarsystems_com_email" {
  source = "./modules/cloudflare_email_routing"

  zone_id = cloudflare_zone.whitestarsystems_com.id
}


resource "cloudflare_record" "whitestarsystems_com_keybase_verification" {
  zone_id = cloudflare_zone.whitestarsystems_com.id
  name    = "@"
  type    = "TXT"
  value   = "keybase-site-verification=m-CHCO8UMok9fCHxS4y7ZhbM7NbvhG8tMMPvKOaHccI"
}
