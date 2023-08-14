resource "cloudflare_zone" "seaviewcottages_org" {
  account_id = local.cf_account_id
  zone       = "seaviewcottages.org"
}

module "seaviewcottages_org_email" {
  source = "./modules/topicbox"

  zone_id = cloudflare_zone.seaviewcottages_org.id
  fqdn    = cloudflare_zone.seaviewcottages_org.zone

  dmarc_report_address = "mailto:52dd6b63f3c44bc98d72b20d9d6b854c@dmarc-reports.cloudflare.net"
}

