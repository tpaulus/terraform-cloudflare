resource "cloudflare_zone" "whitestar_systems" {
  account_id = local.cf_account_id
  zone       = "whitestar.systems"
}

resource "cloudflare_argo" "whitestar_systems_argo" {
  smart_routing = "on"
  zone_id       = cloudflare_zone.whitestar_systems.id
}

// TODO Zone Configuration (Like Cache Settings)
