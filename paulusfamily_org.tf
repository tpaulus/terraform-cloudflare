resource "cloudflare_zone" "paulusfamily_org" {
  account_id = local.cf_account_id
  zone       = "paulusfamily.org"
}

import {
  to = cloudflare_zone.paulusfamily_org
  id = "90ee5b9a5f21de430563dbbabbd93c25"
}