locals {
  mx_servers = [
    { name : "isaac.mx.cloudflare.net", priority : 41 },
    { name : "linda.mx.cloudflare.net", priority : 57 },
    { name : "amir.mx.cloudflare.net", priority : 6 },
  ]

  spf_default = [
    "include:_spf.mx.cloudflare.net"
  ]
}

resource "cloudflare_record" "mx" {
  count           = length(local.mx_servers)
  zone_id         = var.zone_id
  name            = "@"
  type            = "MX"
  content           = local.mx_servers[count.index].name
  priority        = local.mx_servers[count.index].priority
  ttl             = 1
  allow_overwrite = var.allow_overwrite
}

resource "cloudflare_record" "spf" {
  zone_id         = var.zone_id
  name            = "@"
  type            = "TXT"
  content           = "v=spf1 ${join(" ", concat(tolist(local.spf_default), var.allowed_senders))} -all"
  allow_overwrite = var.allow_overwrite
}
