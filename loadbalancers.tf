resource "cloudflare_load_balancer_monitor" "cloudflare_tunnel_hc" {
  account_id       = local.cf_account_id
  allow_insecure   = true
  description      = "Cloudflared Up"
  expected_codes   = "200"
  follow_redirects = false
  interval         = 60
  method           = "GET"
  path             = "/"
  port             = 443
  retries          = 2
  timeout          = 5
  type             = "https"
  header {
          header = "Host"
          values = [
              "n3d.brickyard.whitestar.systems",
          ]
        }
}

resource "cloudflare_load_balancer_pool" "n3d_pool" {
  account_id      = local.cf_account_id
  check_regions   = ["WNAM"]
  enabled         = true
  minimum_origins = 1
  monitor         = cloudflare_load_balancer_monitor.cloudflare_tunnel_hc.id
  name            = "seaview"
  origin_steering {
    policy = "hash"
  }
  origins {
    address = "297a2aaf-2c30-48b8-8e4a-5c9b9c2eab4e.cfargotunnel.com"
    enabled = true
    name    = "laurelhurst.seaview.us"
    weight  = 1
  }
  origins {
    address = "76717746-51b3-49d2-8152-0e8a6f0c0c12.cfargotunnel.com"
    enabled = true
    name    = "ravenna.seaview.us"
    weight  = 1
  }
  origins {
    address = "d7792f60-cb90-4fba-868a-dd58d4e546b6.cfargotunnel.com"
    enabled = true
    name    = "roosevelt.seaview.us"
    weight  = 1
  }
}

resource "cloudflare_load_balancer" "n3d_lb" {
  default_pool_ids = [cloudflare_load_balancer_pool.n3d_pool.id]
  enabled          = true
  fallback_pool_id = cloudflare_load_balancer_pool.n3d_pool.id
  name             = "n3d.brickyard.whitestar.systems"
  session_affinity = "none"
  steering_policy  = "off"
  ttl              = 30
  zone_id          = cloudflare_zone.whitestar_systems.id
}