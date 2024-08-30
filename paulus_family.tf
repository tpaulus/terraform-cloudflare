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
  allowed_senders                     = ["include:spf.mtasv.net"]
}

resource "cloudflare_record" "pirate_ship_dkim" {
  zone_id = cloudflare_zone.paulus_family.id
  name    = "20240619041211pm._domainkey"
  type    = "TXT"
  content = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDNQxj6/H4/+X1gbz0khrP5c+LI7JMZNW/FC4laAJsuLThYh48ENFDH/6lW5MmjDdQcERbDYF6qm9bLmUjZzKkrXRQsPigf9+VSufKE4OU5QeT8zGZ/JdDKfHQLvIT6rqXgmPTd/7/SADQ6NSZSBN5NP30/z85EcEEJGzhD4FypVwIDAQAB"
}

resource "cloudflare_record" "pirate_ship_bounces" {
  zone_id = cloudflare_zone.paulus_family.id
  name    = "pm-bounces"
  type    = "CNAME"
  content = "pm.mtasv.net"
  proxied = false
}

resource "cloudflare_record" "home-assistant" {
  zone_id         = cloudflare_zone.paulus_family.id
  name            = "home"
  type            = "CNAME"
  proxied         = true
  content         = cloudflare_tunnel.brickyard_warp_tunnel.cname
  allow_overwrite = true
}

resource "cloudflare_record" "paperless" {
  zone_id = cloudflare_zone.paulus_family.id
  name    = "paperless"
  type    = "CNAME"
  proxied = true
  content = "paperless.auth-ing.k3s.brickyard.whitestar.systems"
}