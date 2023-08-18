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
  dmarc_report_address                = "mailto:3f08cb85c9d54864871c1d8351cf31e6@dmarc-reports.cloudflare.net"
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
  zone_id = cloudflare_zone.tompaulus_com.id
  name    = "@"
  type    = "TXT"
  value   = "keybase-site-verification=ANVrHna38pR4HiCmhXorD3QPw0bqpsqIGKtDvNLTtwA"
}

resource "cloudflare_record" "tompaulus_com_root" {
  zone_id = cloudflare_zone.tompaulus_com.id
  name    = "@"
  type    = "CNAME"
  proxied = true
  value   = "tom-www.pages.dev"
}

resource "cloudflare_record" "tompaulus_com_www" {
  zone_id = cloudflare_zone.tompaulus_com.id
  name    = "www"
  type    = "CNAME"
  proxied = true
  value   = "tompaulus.com"
}

resource "cloudflare_record" "tompaulus_com_blog" {
  zone_id = cloudflare_zone.tompaulus_com.id
  name    = "blog"
  type    = "CNAME"
  proxied = true
  value   = cloudflare_load_balancer.n3d_lb.name
}

// TODO Zone Configuration (Like Cache Settings)
