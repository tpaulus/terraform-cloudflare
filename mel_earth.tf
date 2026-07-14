resource "cloudflare_zone" "mel_earth" {
  account_id = local.cf_account_id
  zone       = "mel.earth"
}
