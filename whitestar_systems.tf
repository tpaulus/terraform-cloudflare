locals {
  ws_n3d_fqdn = "n3d.brickyard.whitestar.systems"

  ws_n3d_services = ["netbox", "consul.brickyard", "nomad.brickyard", "grafana.brickyard", "prometheus.brickyard", "alertmanager.brickyard", "home", "z2m.brickyard"]

  brickyard_local_ips = [
    {name: "protect", addr: "10.0.10.10"},
    {name: "broadmoor", addr: "10.0.10.16"},
    {name: "woodlandpark", addr: "10.0.10.32"},
    {name: "roosevelt", addr: "10.0.10.64"},
    {name: "ravenna", addr: "10.0.10.80"},
    {name: "unifi-controller", addr: "10.0.1.6"}
  ]

  ipmi_addresses = [
    {name: "ravenna", addr: "10.0.199.2"},
    {name: "roosevelt", addr: "10.0.199.3"},
    {name: "woodlandpark", addr: "10.0.199.4"},
    {name: "beaconhill", addr: "10.0.199.5"}
  ]
}

resource "cloudflare_zone" "whitestar_systems" {
  account_id = local.cf_account_id
  zone       = "whitestar.systems"
}

module "whitestar_systems_email" {
  source = "./modules/cloudflare_email_routing"

  zone_id         = cloudflare_zone.whitestar_systems.id
  allowed_senders = "include:_spf.mx.cloudflare.net include:amazonses.com"
}

resource "cloudflare_record" "whitestar_systems_keybase_verification" {
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = "@"
  type            = "TXT"
  value           = "keybase-site-verification=ZMKzMIfHqDIUV4SrGSCCRP09C0TSada5zNxdosjudGA"
}

resource "cloudflare_record" "whitestar_systems_github_verification" {
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = "_github-challenge-ws-systems-org"
  type            = "TXT"
  value           = "5a889d68b4"
}

resource "cloudflare_record" "whitestar_systems_n3d_services" {
  count = length(local.ws_n3d_services)
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = local.ws_n3d_services[count.index]
  type            = "CNAME"
  proxied         = true
  value           = local.ws_n3d_fqdn
}

resource "cloudflare_record" "whitestar_systems_service_directory" {
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = "sd.brickyard"
  type            = "CNAME"
  proxied         = true
  value           = "brickyard-landing.pages.dev"
}

resource "cloudflare_record" "whitestar_systems_brickyard_ips" {
  count = length(local.brickyard_local_ips)
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = "${local.brickyard_local_ips[count.index].name}.brickyard"
  type            = "A"
  proxied         = false
  value           = local.brickyard_local_ips[count.index].addr
}

resource "cloudflare_record" "whitestar_systems_ipmi_ips" {
  count = length(local.ipmi_addresses)
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = "${local.ipmi_addresses[count.index].name}.brickyard.ipmi"
  type            = "A"
  proxied         = false
  value           = local.ipmi_addresses[count.index].addr
}

resource "cloudflare_record" "whitestar_brickyard_ubnt" {
  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "ubnt.brickyard"
  type    = "CNAME"
  proxied = false
  value   = "unifi-controller.brickyard.whitestar.systems"
  ttl     = "30"
}

// TODO Zone Configuration (Like Cache Settings)