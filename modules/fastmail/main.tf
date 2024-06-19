locals {
  mx_servers = [
    { name : "in1-smtp.messagingengine.com", priority : 10 },
    { name : "in2-smtp.messagingengine.com", priority : 20 }
  ]

  spf_default = [
      "include:spf.messagingengine.com"
  ]
}


resource "cloudflare_record" "mx" {
  count           = length(local.mx_servers)
  zone_id         = var.zone_id
  name            = "@"
  type            = "MX"
  value           = local.mx_servers[count.index].name
  priority        = local.mx_servers[count.index].priority
  ttl             = 86400
  allow_overwrite = var.allow_overwrite
}

resource "cloudflare_record" "mx_wildcard" {
  count           = var.create_wildcard_mx_records ? length(local.mx_servers) : 0
  zone_id         = var.zone_id
  name            = "*"
  type            = "MX"
  value           = local.mx_servers[count.index].name
  priority        = local.mx_servers[count.index].priority
  ttl             = 86400
  allow_overwrite = var.allow_overwrite
}

resource "cloudflare_record" "dkim_mesmtp" {
  zone_id         = var.zone_id
  name            = "mesmtp._domainkey"
  type            = "CNAME"
  value           = "mesmtp.${var.fqdn}.dkim.fmhosted.com"
  allow_overwrite = var.allow_overwrite
}

resource "cloudflare_record" "dkim" {
  count           = 3
  zone_id         = var.zone_id
  name            = "fm${count.index + 1}._domainkey"
  type            = "CNAME"
  value           = "fm${count.index + 1}.${var.fqdn}.dkim.fmhosted.com"
  allow_overwrite = var.allow_overwrite
}

resource "cloudflare_record" "dmarc" {
  zone_id         = var.zone_id
  name            = "_dmarc"
  type            = "TXT"
  value           = "v=DMARC1; p=quarantine; rua=${var.dmarc_report_address}"
  allow_overwrite = var.allow_overwrite
}

resource "cloudflare_record" "spf" {
  zone_id         = var.zone_id
  name            = "@"
  type            = "TXT"
  value           = "v=spf1 ${join(" ", concat(tolist(local.spf_default), var.allowed_senders))} -all"
  allow_overwrite = var.allow_overwrite
}

resource "cloudflare_record" "client_submission" {
  count           = var.create_client_configuration_records ? 1 : 0
  zone_id         = var.zone_id
  name            = "_submission._tcp"
  type            = "SRV"
  allow_overwrite = var.allow_overwrite

  data {
    priority = 0
    weight   = 1
    port     = 587
    target   = "smtp.fastmail.com"
  }
}

resource "cloudflare_record" "client_imap" {
  count           = var.create_client_configuration_records ? 1 : 0
  zone_id         = var.zone_id
  name            = "_imap._tcp"
  type            = "SRV"
  allow_overwrite = var.allow_overwrite

  data {
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_record" "client_imaps" {
  count           = var.create_client_configuration_records ? 1 : 0
  zone_id         = var.zone_id
  name            = "_imaps._tcp"
  type            = "SRV"
  allow_overwrite = var.allow_overwrite

  data {
    priority = 0
    weight   = 1
    port     = 993
    target   = "imap.fastmail.com"
  }
}

resource "cloudflare_record" "client_pop3" {
  count           = var.create_client_configuration_records ? 1 : 0
  zone_id         = var.zone_id
  name            = "_pop3._tcp"
  type            = "SRV"
  allow_overwrite = var.allow_overwrite

  data {
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_record" "client_pop3s" {
  count           = var.create_client_configuration_records ? 1 : 0
  zone_id         = var.zone_id
  name            = "_pop3s._tcp"
  type            = "SRV"
  allow_overwrite = var.allow_overwrite

  data {
    priority = 10
    weight   = 1
    port     = 995
    target   = "pop.fastmail.com"
  }
}

resource "cloudflare_record" "client_jmap" {
  count           = var.create_client_configuration_records ? 1 : 0
  zone_id         = var.zone_id
  name            = "_jmap._tcp"
  type            = "SRV"
  allow_overwrite = var.allow_overwrite

  data {
    priority = 0
    weight   = 1
    port     = 443
    target   = "api.fastmail.com"
  }
}


resource "cloudflare_record" "client_carddav" {
  count           = var.create_client_configuration_records ? 1 : 0
  zone_id         = var.zone_id
  name            = "_cardav._tcp"
  type            = "SRV"
  allow_overwrite = var.allow_overwrite

  data {
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_record" "client_carddavs" {
  count           = var.create_client_configuration_records ? 1 : 0
  zone_id         = var.zone_id
  name            = "_carddavs._tcp"
  type            = "SRV"
  allow_overwrite = var.allow_overwrite

  data {
    priority = 0
    weight   = 1
    port     = 443
    target   = "carddav.fastmail.com"
  }
}

resource "cloudflare_record" "client_caldav" {
  count           = var.create_client_configuration_records ? 1 : 0
  zone_id         = var.zone_id
  name            = "_caldav._tcp"
  type            = "SRV"
  allow_overwrite = var.allow_overwrite

  data {
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_record" "client_caldavs" {
  count           = var.create_client_configuration_records ? 1 : 0
  zone_id         = var.zone_id
  name            = "_caldavs._tcp"
  type            = "SRV"
  allow_overwrite = var.allow_overwrite

  data {
    priority = 0
    weight   = 1
    port     = 443
    target   = "caldav.fastmail.com"
  }
}
