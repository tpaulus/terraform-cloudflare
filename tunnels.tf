resource "random_id" "brickyard_warp_tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "brickyard_warp_tunnel" {
  account_id = local.cf_account_id
  name       = "brickyard-warp"
  secret     = random_id.brickyard_warp_tunnel_secret.b64_std
}

resource "cloudflare_tunnel_config" "brickyard_warp_tunnel_config" {
  account_id = local.cf_account_id
  tunnel_id  = cloudflare_tunnel.brickyard_warp_tunnel.id

  config {
    warp_routing {
      enabled = true
    }
    
    ingress_rule {
      hostname = "home.whitestar.systems"
      path     = "/"
      service  = "http://127.0.0.1:8123"
      origin_request {
        disable_chunked_encoding = true
        http_host_header = "home.whitestar.systems"
      }
    }
  }
}

resource "cloudflare_tunnel_route" "seaview_ip" {
  account_id         = local.cf_account_id
  tunnel_id          = cloudflare_tunnel.brickyard_warp_tunnel.id
  network            = "10.0.0.0/8"
  comment            = "Home Network Route"
}
