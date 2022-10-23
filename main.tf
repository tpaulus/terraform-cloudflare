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
  value           = cloudflare_argo_tunnel.nuc.cname
  allow_overwrite = true
}

// TODO Non Email DNS Records

// TODO Zone Configuration (Like Cache Settings)

// TODO Page Rules

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

// ==== whitestar_systems ====
locals {
  ws_nuc_services = ["n8n.brickyard", "netbox", "portainer.nuc.brickyard"]
  ws_router_services = ["home", "woodlandpark-access.brickyard", "woodlandpark-smb.brickyard", "z2m.nuc.brickyard"]

  brickyard_local_ips = [
    {name: "magnolia", addr: "10.0.10.48"},
    {name: "nuc", addr: "10.0.10.16"},
    {name: "restic", addr: "10.0.10.34"},
    {name: "ubnt", addr: "10.0.1.1"},
    {name: "woodlandpark", addr: "10.0.10.32"},
  ]
}

resource "cloudflare_zone" "whitestar_systems" {
  account_id = local.cf_account_id
  zone       = "whitestar.systems"
}

module "whitestar_systems_email" {
  source = "./modules/cloudflare_email_routing"

  zone_id         = cloudflare_zone.whitestar_systems.id
  allow_overwrite = true
  allowed_senders = "include:_spf.mx.cloudflare.net include:amazonses.com"
}

resource "cloudflare_record" "whitestar_systems_keybase_verification" {
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = "@"
  type            = "TXT"
  value           = "keybase-site-verification=ZMKzMIfHqDIUV4SrGSCCRP09C0TSada5zNxdosjudGA"
}

resource "cloudflare_record" "whitestar_systems_nuc_services" {
  count = length(local.ws_nuc_services)
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = local.ws_nuc_services[count.index]
  type            = "CNAME"
  proxied         = true
  value           = cloudflare_argo_tunnel.nuc.cname
  allow_overwrite = true
}

resource "cloudflare_record" "whitestar_systems_router_services" {
  count = length(local.ws_router_services)
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = local.ws_router_services[count.index]
  type            = "CNAME"
  proxied         = true
  value           = cloudflare_argo_tunnel.router.cname
  allow_overwrite = true
}

resource "cloudflare_record" "whitestar_systems_static_r2" {
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = "s"
  type            = "CNAME"
  proxied         = true
  value           = "public.r2.dev"
  allow_overwrite = true
}

resource "cloudflare_record" "whitestar_systems_service_directory" {
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = "sd.brickyard"
  type            = "CNAME"
  proxied         = true
  value           = "brickyard-landing.pages.dev"
  allow_overwrite = true
}

resource "cloudflare_record" "whitestar_systems_brickyard_ips" {
  count = length(local.brickyard_local_ips)
  zone_id         = cloudflare_zone.whitestar_systems.id
  name            = local.brickyard_local_ips[count.index].name
  type            = "A"
  proxied         = false
  value           = local.brickyard_local_ips[count.index].addr
  allow_overwrite = true
}

// TODO Zone Configuration (Like Cache Settings)

// TODO Page Rules


// ==== Zero Trust ====
resource "cloudflare_argo_tunnel" "nuc" {
  account_id = locals.cf_account_id
  name       = "NUC"
}

resource "cloudflare_argo_tunnel" "magnolia" {
  account_id = locals.cf_account_id
  name       = "Magnolia"
}

resource "cloudflare_argo_tunnel" "router" {
  account_id = locals.cf_account_id
  name       = "STTLWASCSG1"
}
