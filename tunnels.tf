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
    AccountTag = local.cf_account_id
    TunnelID = cloudflare_tunnel.brickyard_warp_tunnel.id
    TunnelSecret = random_id.brickyard_warp_tunnel_secret.b64_std
  }
}
