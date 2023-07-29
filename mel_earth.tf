resource "cloudflare_zone" "mel_earth" {
  account_id = local.cf_account_id
  zone       = "mel.earth"
}

module "mel_earth_email" {
  source = "./modules/fastmail"

  zone_id                             = cloudflare_zone.mel_earth.id
  fqdn                                = cloudflare_zone.mel_earth.zone
  create_client_configuration_records = true
}