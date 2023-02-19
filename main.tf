// TODO Make Default WAF Module and apply to all zones

// ==== runabout.space ====
resource "cloudflare_zone" "runabout_space" {
  account_id = local.cf_account_id
  zone       = "runabout.space"
}

module "runabout_space_email" {
  source = "./modules/fastmail"

  zone_id = cloudflare_zone.runabout_space.id
  fqdn    = cloudflare_zone.runabout_space.zone
}

resource "cloudflare_record" "runabout_space_keybase_verification" {
  zone_id         = cloudflare_zone.runabout_space.id
  name            = "@"
  type            = "TXT"
  value           = "keybase-site-verification=RsL-7roB3x2Sv1GoI3MzZ8APh3Gt88CMBw_DTL1LKvk"
}


// ==== mel.earth ====
resource "cloudflare_zone" "mel_earth" {
  account_id = local.cf_account_id
  zone       = "mel.earth"
}

module "mel_earth_email" {
  source = "./modules/fastmail"

  zone_id                             = cloudflare_zone.mel_earth.id
  fqdn                                = cloudflare_zone.mel_earth.zone
  create_client_configuration_records = true
}


// ==== seaviewcottages.org ====
resource "cloudflare_zone" "seaviewcottages_org" {
  account_id = local.cf_account_id
  zone       = "seaviewcottages.org"
}

module "seaviewcottages_org_email" {
  source = "./modules/topicbox"

  zone_id = cloudflare_zone.seaviewcottages_org.id
  fqdn    = cloudflare_zone.seaviewcottages_org.zone
}


// ==== tompaulus.com ====
resource "cloudflare_zone" "tompaulus_com" {
  account_id = local.cf_account_id
  zone       = "tompaulus.com"
}

module "tompaulus_com_email" {
  source = "./modules/fastmail"

  zone_id                             = cloudflare_zone.tompaulus_com.id
  fqdn                                = cloudflare_zone.tompaulus_com.zone
  create_client_configuration_records = true
  create_wildcard_mx_records          = true
  allowed_senders                     = "include:spf.messagingengine.com include:amazonses.com"
}

module "tompaulus_com_ses_dns" {
  source = "./modules/ses_dns"

  zone_id = cloudflare_zone.tompaulus_com.id
  dkim_ids = [
    "2gdibe3uaozthsp3q7qytnf3umkkjkkd", "63ilntu2hvaqbeoiq4d5jbqxhnuqhkjh",
    "bhjfun4cius7vyvqhmsf7xpbtbxszem4", "mslyrhhosvow7b5z5vsnys4kztl2jcrq",
    "uqkwjnfnzjdopfoutf3ih4pwqihrfhsf", "wwilycvdedvkqqwnnl25cxjp3bakkxxy"
  ]
  txt_verification = [
    "nhnRt/X9SkDn/5ASMYURGpGaUEPBo0u/9daGoCa5zxU=",
    "A/J5kW0VuiyGR3Y1MdsnMQYq4yujQHGqzbsO7jwow9Y="
  ]
}

resource "cloudflare_record" "tompaulus_com_keybase_verification" {
  zone_id         = cloudflare_zone.tompaulus_com.id
  name            = "@"
  type            = "TXT"
  value           = "keybase-site-verification=ANVrHna38pR4HiCmhXorD3QPw0bqpsqIGKtDvNLTtwA"
}

resource "cloudflare_record" "tompaulus_com_root" {
  zone_id         = cloudflare_zone.tompaulus_com.id
  name            = "@"
  type            = "CNAME"
  proxied         = true
  value           = "tom-www.pages.dev"
}

resource "cloudflare_record" "tompaulus_com_www" {
  zone_id         = cloudflare_zone.tompaulus_com.id
  name            = "www"
  type            = "CNAME"
  proxied         = true
  value           = "tompaulus.com"
}

resource "cloudflare_record" "tompaulus_com_blog" {
  zone_id         = cloudflare_zone.tompaulus_com.id
  name            = "blog"
  type            = "CNAME"
  proxied         = true
  value           = local.ws_n3d_fqdn
}

// TODO Zone Configuration (Like Cache Settings)


// ==== whitestarsystems.com ====
resource "cloudflare_zone" "whitestarsystems_com" {
  account_id = local.cf_account_id
  zone       = "whitestarsystems.com"
}

module "whitestarsystems_com_email" {
  source = "./modules/cloudflare_email_routing"

  zone_id         = cloudflare_zone.whitestarsystems_com.id
}


resource "cloudflare_record" "whitestarsystems_com_keybase_verification" {
  zone_id         = cloudflare_zone.whitestarsystems_com.id
  name            = "@"
  type            = "TXT"
  value           = "keybase-site-verification=m-CHCO8UMok9fCHxS4y7ZhbM7NbvhG8tMMPvKOaHccI"
}

// ==== whitestar.systems ====
locals {
  ws_n3d_fqdn = "n3d.brickyard.whitestar.system"

  ws_n3d_services = ["netbox", "m3d.brickyard",  "consul.brickyard", "nomad.brickyard", "grafana.brickyard", "prometheus.brickyard", "alertmanager.brickyard"]
  ws_router_services = ["home", "woodlandpark-access.brickyard", "woodlandpark-smb.brickyard"]

  brickyard_local_ips = [
    {name: "ubnt", addr: "10.0.1.1"},
    {name: "protect", addr: "10.0.10.10"},
    {name: "broadmoor", addr: "10.0.10.16"},
    {name: "woodlandpark", addr: "10.0.10.32"},
    {name: "roosevelt", addr: "10.0.10.64"},
    {name: "ravenna", addr: "10.0.10.80"},
  ]

  ws_consul_servers = ["woodlandpark.brickyard.whitestar.systems", "roosevelt.brickyard.whitestar.systems", "ravenna.brickyard.whitestar.systems"]

  router_argo_tunnel_cname = "4ca02328-8cd1-4f24-bfb4-f59bd32ed651.cfargotunnel.com"
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


resource "cloudflare_record" "whitestar_systems_router_services" {
  count = length(local.ws_router_services)
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = local.ws_router_services[count.index]
  type            = "CNAME"
  proxied         = true
  value           = local.router_argo_tunnel_cname
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

resource "cloudflare_record" "whitestar_systems_consul_srv" {
  count           = length(local.ws_consul_servers)
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = "_server._tcp.consul.brickyard.whitestar.systems"
  type            = "SRV"
  allow_overwrite = true

  data {
    name     = "consul.brickyard.whitestar.systems"
    service  = "_server"
    proto    = "_tcp"
    priority = 1
    weight   = 10
    port     = 8500
    target   = local.brickyard_local_ips[count.index].addr
  }
}


// TODO Zone Configuration (Like Cache Settings)


// ==== Zero Trust ====
// TODO Access Policies


// ==== Gateway Policies ====
resource "cloudflare_teams_rule" "allowed" {
  name = "Allowed"
  description = ""
  account_id  = local.cf_account_id
  precedence = 10000
  action = "allow"
  enabled = true
  filters = ["dns"]
  traffic = "any(dns.domains[*] in $b880f23bb11a45c29e8149401dd67592)"
  rule_settings {
    block_page_enabled = false
  }
}

resource "cloudflare_teams_rule" "block_ads" {
  name = "Block Ads"
  description = ""
  account_id  = local.cf_account_id
  precedence = 11000
  action = "block"
  enabled = true
  filters = ["dns"]
  traffic = "any(dns.content_category[*] in {1 66})"  # https://developers.cloudflare.com/cloudflare-one/policies/filtering/dns-policies/dns-categories/#category-and-subcategory-ids
  rule_settings {
    block_page_enabled = false
  }
}

resource "cloudflare_teams_rule" "block_content_categories" {
  name = "Block Content Categories"
  description = ""
  account_id  = local.cf_account_id
  precedence = 12000
  action = "block"
  enabled = true
  filters = ["dns"]
  traffic = "any(dns.content_category[*] in {85 162 128 161 177 169 124 170})"  # https://developers.cloudflare.com/cloudflare-one/policies/filtering/dns-policies/dns-categories/#category-and-subcategory-ids
  rule_settings {
    block_page_enabled = true
  }
}

resource "cloudflare_teams_rule" "block_security_risks" {
  name = "Block Security Risks"
  description = ""
  account_id  = local.cf_account_id
  precedence = 13000
  action = "block"
  enabled = true
  filters = ["dns"]
  traffic = "any(dns.security_category[*] in {68 178 80 83 176 175 117 131 134 151 153})"  # https://developers.cloudflare.com/cloudflare-one/policies/filtering/dns-policies/dns-categories/#category-and-subcategory-ids
  rule_settings {
    block_page_enabled = true
  }
}

resource "cloudflare_teams_rule" "block_manual_trackers_and_ads" {
  name = "Block Manual Trackers & Ads"
  description = ""
  account_id  = local.cf_account_id
  precedence = 14000
  action = "block"
  enabled = true
  filters = ["dns"]
  traffic = "any(dns.domains[*] in $534bce67f20a4ac698fc003f6c139767)"
  rule_settings {
    block_page_enabled = false
  }
}

resource "cloudflare_teams_rule" "block_tor" {
  name = "Block TOR"
  description = ""
  account_id  = local.cf_account_id
  precedence = 15000
  action = "block"
  enabled = true
  filters = ["dns"]
  traffic = "any(dns.dst.geo.continent[*] == \"T1\")"
  rule_settings {
    block_page_enabled = true
    block_page_reason = "Access to TOR Sites is blocked."
  }
}
