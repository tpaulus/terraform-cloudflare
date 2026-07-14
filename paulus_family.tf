resource "cloudflare_zone" "paulus_family" {
  account_id = local.cf_account_id
  zone       = "paulus.family"
}
 