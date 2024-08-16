// ==== Zero Trust ====
// TODO Access Policies


// ==== Gateway Policies ====
resource "cloudflare_teams_rule" "allowed" {
  name        = "Allowed"
  description = ""
  account_id  = local.cf_account_id
  precedence  = 10000
  action      = "allow"
  enabled     = true
  filters     = ["dns"]
  traffic     = "any(dns.domains[*] in $b880f23bb11a45c29e8149401dd67592)"
}

resource "cloudflare_teams_rule" "block_content_categories" {
  name        = "Block Content Categories"
  description = ""
  account_id  = local.cf_account_id
  precedence  = 12000
  action      = "block"
  enabled     = true
  filters     = ["dns"]
  traffic     = "any(dns.content_category[*] in {85 162 170})" # https://developers.cloudflare.com/cloudflare-one/policies/filtering/dns-policies/dns-categories/#category-and-subcategory-ids
  rule_settings {
    block_page_enabled = true
    block_page_reason  = "Access to this category of sites is blocked."
  }
}

resource "cloudflare_teams_rule" "block_security_risks" {
  name        = "Block Security Risks"
  description = ""
  account_id  = local.cf_account_id
  precedence  = 13000
  action      = "block"
  enabled     = true
  filters     = ["dns"]
  traffic     = "any(dns.security_category[*] in {178 80 83 176 175 117 131 134 151 153})" # https://developers.cloudflare.com/cloudflare-one/policies/filtering/dns-policies/dns-categories/#category-and-subcategory-ids
  rule_settings {
    block_page_enabled = true
    block_page_reason  = "This site is a security risk, and is therefor blocked."
  }
}

resource "cloudflare_teams_rule" "block_manual_trackers_and_ads" {
  name        = "Block Manual Trackers & Ads"
  description = ""
  account_id  = local.cf_account_id
  precedence  = 14000
  action      = "block"
  enabled     = true
  filters     = ["dns"]
  traffic     = "any(dns.domains[*] in $534bce67f20a4ac698fc003f6c139767)"
}

resource "cloudflare_teams_rule" "block_tor" {
  name        = "Block TOR"
  description = ""
  account_id  = local.cf_account_id
  precedence  = 15000
  action      = "block"
  enabled     = true
  filters     = ["dns"]
  traffic     = "any(dns.dst.geo.continent[*] == \"T1\")"
  rule_settings {
    block_page_enabled = true
    block_page_reason  = "Access to TOR Sites is blocked."
  }
}

resource "cloudflare_device_managed_networks" "seaview" {
  account_id = local.cf_account_id
  name       = "Seaview"
  type       = "tls"
  config {
    tls_sockaddr = "10.0.10.220:443"
    sha256       = lower("D693C2456E86E0535A2801F6335FD801BD1CF1ADCC51413E1946D1FA696655C6")
  }
}

# Warp Client Policies
resource "cloudflare_device_settings_policy" "trusted_location_warp_policy" {
  account_id            = local.cf_account_id
  name                  = "Disable when on trusted network"
  description           = ""
  precedence            = 10
  match                 = "network in {\"Seaview\"}"
  default               = false
  enabled               = true
  allow_mode_switch     = false
  allow_updates         = true
  allowed_to_leave      = true
  auto_connect          = 0
  captive_portal        = 180
  disable_auto_fallback = false
  switch_locked         = false
  service_mode_v2_mode  = "posture_only"
  service_mode_v2_port  = 0
  exclude_office_ips    = false
}

resource "cloudflare_device_settings_policy" "mobile_device_warp_policy" {
  account_id            = local.cf_account_id
  name                  = "Mobile Client"
  description           = ""
  precedence            = 20
  match                 = "os.name in {\"ios\" \"android\"}"
  default               = false
  enabled               = true
  allow_mode_switch     = false
  allow_updates         = true
  allowed_to_leave      = true
  auto_connect          = 180
  captive_portal        = 600
  disable_auto_fallback = false
  switch_locked         = false
  service_mode_v2_mode  = "warp"
  service_mode_v2_port  = 0
  exclude_office_ips    = false
}

resource "cloudflare_device_settings_policy" "desktop_device_warp_policy" {
  account_id            = local.cf_account_id
  name                  = "Desktops"
  description           = ""
  precedence            = 30
  match                 = "os.name in {\"windows\" \"mac\" \"chromeos\" \"linux\"}"
  default               = false
  enabled               = true
  allow_mode_switch     = true
  allow_updates         = true
  allowed_to_leave      = true
  auto_connect          = 180
  captive_portal        = 600
  disable_auto_fallback = false
  switch_locked         = false
  service_mode_v2_mode  = "warp"
  service_mode_v2_port  = 0
  exclude_office_ips    = false
}

resource "cloudflare_device_settings_policy" "default_warp_policy" {
  account_id            = local.cf_account_id
  name                  = ""
  description           = ""
  default               = true
  enabled               = true
  allow_mode_switch     = true
  allow_updates         = true
  allowed_to_leave      = true
  auto_connect          = 0
  captive_portal        = 600
  disable_auto_fallback = false
  switch_locked         = false
  service_mode_v2_mode  = "warp"
  service_mode_v2_port  = 0
  exclude_office_ips    = false
}

# Split Tunnel Configs
variable "zt_split_tunnel_file" {
  default = "zt_split_tunnel.txt"
}

locals {
  cidr_list = [
    for cidr in split("\n", file(var.zt_split_tunnel_file)) : trimspace(cidr)
    if cidr != "" && !startswith(trimspace(cidr), "#")
  ]

  device_settings_policy_ids = [
    cloudflare_device_settings_policy.trusted_location_warp_policy.id,
    cloudflare_device_settings_policy.mobile_device_warp_policy.id,
    cloudflare_device_settings_policy.desktop_device_warp_policy.id,
    cloudflare_device_settings_policy.default_warp_policy.id,
  ]
}

resource "cloudflare_split_tunnel" "split_tunnel_exclude" {
  for_each   = toset(local.device_settings_policy_ids)
  account_id = local.cf_account_id
  policy_id  = each.value
  mode       = "exclude"

  dynamic "tunnels" {
    for_each = local.cidr_list
    content {
      address     = tunnels.value
      description = ""
    }
  }
}