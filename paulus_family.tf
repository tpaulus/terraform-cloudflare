resource "cloudflare_zone" "paulus_family" {
  account_id = local.cf_account_id
  zone       = "paulus.family"
}

module "paulus_family_email" {
  source = "./modules/fastmail"

  zone_id                             = cloudflare_zone.paulus_family.id
  fqdn                                = cloudflare_zone.paulus_family.zone
  create_client_configuration_records = false
  create_wildcard_mx_records          = true
  dmarc_report_address                = "mailto:d6b6ea49728e40aabe6f5d3b65646b12@dmarc-reports.cloudflare.net"
}