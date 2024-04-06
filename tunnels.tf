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

    ingress_rule {
      hostname = "woodlandpark-ssh.access.brickyard.whitestar.systems"
      path     = "/"
      service  = "tcp://10.0.10.32:22"
      origin_request {
        access {
          aud_tag   = ["bdade16db3fd775d1a784f2cdafb7e6e4ec66302202aa0ff1c1dea2151d7bcc9"]
          required  = true
          team_name = "whitestar"
        }
      }
    }

    ingress_rule {
      service = "http_status:503"
    }
  }
}

resource "cloudflare_tunnel_route" "seaview_ip" {
  account_id         = local.cf_account_id
  tunnel_id          = cloudflare_tunnel.brickyard_warp_tunnel.id
  network            = "10.0.0.0/9"
  comment            = "Home Network Route"
}
