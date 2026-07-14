resource "cloudflare_zone" "paulusfamily_org" {
  account_id = local.cf_account_id
  zone       = "paulusfamily.org"
}
