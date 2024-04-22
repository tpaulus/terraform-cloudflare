resource "cloudflare_zone" "melinda_tom_wedding" {
  account_id = local.cf_account_id
  paused     = false
  plan       = "pro"
  type       = "full"
  zone       = "melinda-tom.wedding"
}

module "melinda_tom_wedding_email" {
  source = "./modules/fastmail"

  zone_id                             = cloudflare_zone.melinda_tom_wedding.id
  fqdn                                = cloudflare_zone.melinda_tom_wedding.zone
  create_client_configuration_records = false

  allowed_senders      = "include:spf.messagingengine.com include:_spf.mx.cloudflare.net include:relay.mailchannels.net"
  dmarc_report_address = "mailto:9782f98c803c4a17afc4d07788d2af87@dmarc-reports.cloudflare.net"
}

resource "cloudflare_record" "www_melinda_tom_wedding" {
  comment = "WWW is redirected via a Redirect Rule."
  name    = "www"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  value   = "100::"
  zone_id = cloudflare_zone.melinda_tom_wedding.id
}

resource "cloudflare_record" "apex_melinda_tom_wedding" {
  name    = "melinda-tom.wedding"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "melinda-tom-wedding.pages.dev"
  zone_id = cloudflare_zone.melinda_tom_wedding.id
}

resource "cloudflare_record" "mailchannels_melinda_tom_wedding" {
  name    = "_mailchannels"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "v=mc1 cfid=melinda-tom.wedding cfid=melinda-tom-wedding.pages.dev"
  zone_id = cloudflare_zone.melinda_tom_wedding.id
}

resource "cloudflare_record" "workers_dkim_melinda_tom_wedding" {
  name    = "workers._domainkey"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "v=DKIM1; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4oTH+Tibu5o2eRknWUoPswvToLddfxUPq8TAfOxrte7gKVtVZF6R+W6MoNIYytBVWt+jQqgYFB1dfAm4/o8SFMNd6D1UjIViRE2+T9TBCTTUxQboBI/Yov2erNiQxwo4/lHuCcqsMZ/29SCwO92LZ1YW4Z8N5Pn1o0Y3w3rNGY8BwpWB9GnZ41Uzn8e0gVZOMVRa8CErygnWOCID2652firwExJUfCDcji3XDapSTG1f6mC1vh019a/WfEhJMrdQu6+DdUa92tkvGn64Ak+mOCTQx0AJ7zHzFmKDbTtGeQYMymgovS0Z7beuamQab2SX1BcL0GbjJcfEBNWFtPuCXwIDAQAB"
  zone_id = cloudflare_zone.melinda_tom_wedding.id
}

resource "cloudflare_ruleset" "melinda_tom_wedding_http_config_settings" {
  kind    = "zone"
  name    = "default"
  phase   = "http_config_settings"
  zone_id = cloudflare_zone.melinda_tom_wedding.id
}

resource "cloudflare_ruleset" "melinda_tom_wedding_rate_limiting" {
  kind    = "zone"
  name    = "default"
  phase   = "http_ratelimit"
  zone_id = cloudflare_zone.melinda_tom_wedding.id
  rules {
    action = "block"
    action_parameters {
      response {
        content      = "Rate Limit Exceeded - Try Again Later"
        content_type = "text/plain"
        status_code  = 429
      }
    }
    description = "RL RSVP Submissions"
    enabled     = true
    expression  = "(http.request.uri.path eq \"/rsvp/submit\")"
    ratelimit {
      characteristics     = ["ip.src", "cf.colo.id"]
      mitigation_timeout  = 3600
      period              = 60
      requests_per_period = 5
    }
  }
}

resource "cloudflare_ruleset" "melinda_tom_wedding_redirects" {
  kind    = "zone"
  name    = "default"
  phase   = "http_request_dynamic_redirect"
  zone_id = cloudflare_zone.melinda_tom_wedding.id
  rules {
    action = "redirect"
    action_parameters {
      from_value {
        preserve_query_string = true
        status_code           = 301
        target_url {
          expression = "concat(\"https://\", http.host, http.request.uri.path)"
        }
      }
    }
    description = "Upgrade HTTP Requests"
    enabled     = true
    expression  = "(not ssl)"
  }
  rules {
    action = "redirect"
    action_parameters {
      from_value {
        preserve_query_string = false
        status_code           = 307
        target_url {
          value = "https://melinda-tom.wedding/de"
        }
      }
    }
    description = "Send Germany to DE Language Page"
    enabled     = true
    expression  = "(ip.geoip.country in {\"DE\"} and http.request.uri.path eq \"/\")"
  }
  rules {
    action = "redirect"
    action_parameters {
      from_value {
        preserve_query_string = false
        status_code           = 301
        target_url {
          value = "https://medinda-tom.wedding"
        }
      }
    }
    description = "Redirect WWW"
    enabled     = true
    expression  = "(http.request.full_uri contains \"www.medinda-tom.wedding\")"
  }
}

resource "cloudflare_ruleset" "melinda_tom_wedding_custom_waf" {
  kind    = "zone"
  name    = "default"
  phase   = "http_request_firewall_custom"
  zone_id = cloudflare_zone.melinda_tom_wedding.id
  rules {
    action      = "managed_challenge"
    description = "Challenge Threat <= 10"
    enabled     = true
    expression  = "(cf.threat_score ge 10)"
  }
  rules {
    action      = "block"
    description = "Block Threat <= 50"
    enabled     = true
    expression  = "(cf.threat_score ge 50)"
  }
}

resource "cloudflare_ruleset" "melinda_tom_wedding_managed_waf" {
  kind    = "zone"
  name    = "default"
  phase   = "http_request_firewall_managed"
  zone_id = cloudflare_zone.melinda_tom_wedding.id
  rules {
    action = "execute"
    action_parameters {
      id      = "efb7b8c949ac4650a09736fc376e9aee"
      version = "latest"
    }
    enabled    = true
    expression = "true"
  }
}

resource "cloudflare_ruleset" "melinda_tom_wedding_transforms" {
  kind    = "zone"
  name    = "default"
  phase   = "http_request_transform"
  zone_id = cloudflare_zone.melinda_tom_wedding.id
}