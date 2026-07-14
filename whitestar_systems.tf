locals {
  brickyard_local_ips = {
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

resource "cloudflare_record" "whitestar_systems_brickyard_ips" {
  for_each = local.brickyard_local_ips

  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "${each.key}.brickyard"
  type    = "A"
  proxied = false
  content = each.value
}

resource "cloudflare_record" "whitestar_systems_ipmi_ips" {
  for_each = local.ipmi_addresses

  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "${each.key}.brickyard.ipmi"
  type    = "A"
  proxied = false
  content = each.value
}

resource "cloudflare_record" "k3s_primaries" {
  for_each = toset(local.k3s_primaries)

  zone_id = cloudflare_zone.whitestar_systems.id
  name    = "k3s.brickyard"
  type    = "A"
  proxied = false
  content = each.key
}

resource "cloudflare_argo" "whitestar_systems_argo" {
  smart_routing = "on"
  zone_id       = cloudflare_zone.whitestar_systems.id
}

// TODO Zone Configuration (Like Cache Settings)
