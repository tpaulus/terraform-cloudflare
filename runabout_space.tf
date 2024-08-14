resource "cloudflare_zone" "runabout_space" {
  account_id = local.cf_account_id
  zone       = "runabout.space"
}

module "runabout_space_email" {
  source = "./modules/fastmail"

  zone_id = cloudflare_zone.runabout_space.id
  fqdn    = cloudflare_zone.runabout_space.zone

  dmarc_report_address = "mailto:58a029c6907a487e89a1bbc2830bf93d@dmarc-reports.cloudflare.net"
}

resource "cloudflare_record" "runabout_space_keybase_verification" {
  zone_id = cloudflare_zone.runabout_space.id
  name    = "@"
  type    = "TXT"
  content   = "keybase-site-verification=RsL-7roB3x2Sv1GoI3MzZ8APh3Gt88CMBw_DTL1LKvk"
}
