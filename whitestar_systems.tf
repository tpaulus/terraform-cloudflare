locals {
  brickyard_local_ips = {
    "protect" : "10.0.10.10",
    "broadmoor" : "10.0.10.16",
    "laurelhurst" : "10.0.40.2",
    "woodlandpark" : "10.0.10.32",
    "roosevelt" : "10.0.40.4",
    "ravenna" : "10.0.40.3",
    "unifi-controller" : "10.0.1.6",
    "beaconhill" : "10.0.1.1",
  }

  k3s_primaries = [
    "10.0.40.2",
    "10.0.40.3",
    "10.0.40.4",
  ]

  ipmi_addresses = {
    "ravenna" : "10.0.199.2",
    "roosevelt" : "10.0.199.3",
    "woodlandpark" : "10.0.199.4",
    "beaconhill" : "10.0.199.5",
    "laurelhurst" : "10.0.199.6",
  }
}

resource "cloudflare_zone" "whitestar_systems" {
  account_id = local.cf_account_id
  zone       = "whitestar.systems"
}

module "whitestar_systems_email" {
  source = "./modules/cloudflare_email_routing"

  zone_id         = cloudflare_zone.whitestar_systems.id
  allowed_senders = ["include:amazonses.com"]
}

resource "cloudflare_record" "whitestar_systems_keybase_verification" {
  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "@"
  type    = "TXT"
  value   = "keybase-site-verification=ZMKzMIfHqDIUV4SrGSCCRP09C0TSada5zNxdosjudGA"
}

resource "cloudflare_record" "whitestar_systems_github_verification" {
  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "_github-challenge-ws-systems-org"
  type    = "TXT"
  value   = "5a889d68b4"
}

resource "cloudflare_record" "whitestar_systems_brickyard_ips" {
  for_each = local.brickyard_local_ips

  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "${each.key}.brickyard"
  type    = "A"
  proxied = false
  value   = each.value
}

resource "cloudflare_record" "whitestar_systems_ipmi_ips" {
  for_each = local.ipmi_addresses

  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "${each.key}.brickyard.ipmi"
  type    = "A"
  proxied = false
  value   = each.value
}

resource "cloudflare_record" "whitestar_brickyard_ubnt" {
  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "ubnt.brickyard"
  type    = "CNAME"
  proxied = false
  value   = "unifi-controller.brickyard.whitestar.systems"
  ttl     = "30"
}

resource "cloudflare_record" "dmarc" {
  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "_dmarc"
  type    = "TXT"
  value   = "v=DMARC1; p=quarantine; rua=mailto:64203f8a3e304420b20686d30874ffc9@dmarc-reports.cloudflare.net"
}

resource "cloudflare_record" "k3s_primaries" {
  for_each = toset(local.k3s_primaries)

  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "k3s.brickyard"
  type    = "A"
  proxied = false
  value   = each.key
}

resource "cloudflare_record" "k3s_ingress" {
  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "*.ing.k3s.brickyard"
  type    = "A"
  proxied = false
  value   = "10.30.0.0"
}

resource "cloudflare_record" "k3s_auth_ingress" {
  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "*.auth-ing.k3s.brickyard"
  type    = "CNAME"
  proxied = true
  value   = "6bd25c6e-9222-43e6-bdb3-f989da6cbdb2.cfargotunnel.com"
}

resource "cloudflare_record" "brickyard_vlmcsd" {
  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "vlmcsd.brickyard"
  type    = "A"
  proxied = false
  value   = "10.30.0.1"
}

resource "cloudflare_record" "netbox" {
  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "netbox"
  type    = "CNAME"
  proxied = true
  value   = "netbox.auth-ing.k3s.brickyard.whitestar.systems"
}

resource "cloudflare_record" "home-assistant" {
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = "home"
  type            = "CNAME"
  proxied         = true
  value           = cloudflare_tunnel.brickyard_warp_tunnel.cname
  allow_overwrite = true
}

resource "cloudflare_record" "grafana-brickyard" {
  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "grafana.brickyard"
  type    = "CNAME"
  proxied = true
  value   = "grafana.auth-ing.k3s.brickyard.whitestar.systems"
}

resource "cloudflare_record" "n8n-brickyard" {
  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "n8n.brickyard"
  type    = "CNAME"
  proxied = true
  value   = "n8n.auth-ing.k3s.brickyard.whitestar.systems"
}

resource "cloudflare_record" "auth" {
  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "auth"
  type    = "CNAME"
  proxied = true
  value   = "zitadel.auth-ing.k3s.brickyard.whitestar.systems"
}

resource "cloudflare_record" "woodlandpark-smb" {
  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "woodlandpark-ssh.access.brickyard"
  type    = "CNAME"
  proxied = true
  value   = cloudflare_tunnel.brickyard_warp_tunnel.cname
}

resource "cloudflare_argo" "whitestar_systems_argo" {
  smart_routing = "on"
  zone_id       = cloudflare_zone.whitestar_systems.id
}

// TODO Zone Configuration (Like Cache Settings)
