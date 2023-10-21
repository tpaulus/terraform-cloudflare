resource "random_id" "brickyard_warp_tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "brickyard_warp_tunnel" {
  account_id = local.cf_account_id
  name       = "brickyard-warp"
  secret     = random_id.brickyard_warp_tunnel_secret.b64_std
}

resource "nomad_variable" "brickyard_warp_tunnel" {
  path  = "cloudflared/brickyard-warp"
  items = {
    TunnelToken = cloudflare_tunnel.brickyard_warp_tunnel.tunnel_token
  }
}

resource "cloudflare_tunnel_virtual_network" "seaview_vnet" {
  account_id = local.cf_account_id
  name = "seaview"
  comment = "Seaview Network"
}

resource "cloudflare_tunnel_route" "seaview_ip" {
  account_id         = local.cf_account_id
  tunnel_id          = cloudflare_tunnel.brickyard_warp_tunnel.id
  network            = "10.0.0.0/8"
  comment            = "Home Network Route"
  virtual_network_id = cloudflare_tunnel_virtual_network.seaview_vnet.id
}