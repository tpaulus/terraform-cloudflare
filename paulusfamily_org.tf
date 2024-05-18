resource "cloudflare_zone" "paulusfamily_org" {
  account_id = local.cf_account_id
  zone       = "paulusfamily.org"
}

module "paulusfamily_org_email" {
  source = "./modules/fastmail"

  zone_id                             = cloudflare_zone.paulusfamily_org.id
  fqdn                                = cloudflare_zone.paulusfamily_org.zone
  create_client_configuration_records = false
  create_wildcard_mx_records          = true
  dmarc_report_address                = "mailto:d0be62b94fa648a59381e4712859e610@dmarc-reports.cloudflare.net"
}