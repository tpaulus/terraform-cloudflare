resource "cloudflare_zone" "runabout_space" {
  account_id = local.cf_account_id
  zone       = "runabout.space"
}

module "runabout_space_email" {
  source = "./modules/fastmail"

  zone_id = cloudflare_zone.runabout_space.id
  fqdn    = cloudflare_zone.runabout_space.zone
}

resource "cloudflare_record" "runabout_space_keybase_verification" {
  zone_id         = cloudflare_zone.runabout_space.id
  name            = "@"
  type            = "TXT"
  value           = "keybase-site-verification=RsL-7roB3x2Sv1GoI3MzZ8APh3Gt88CMBw_DTL1LKvk"
}
