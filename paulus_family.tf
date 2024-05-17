resource "cloudflare_zone" "paulus_family" {
  account_id = local.cf_account_id
  zone       = "paulus.family"
}

import {
  to = cloudflare_zone.paulus_family
  id = "c4c79e93d4d2afd6c0abd49d6f26edad"
}