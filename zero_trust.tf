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
