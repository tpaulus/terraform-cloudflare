variable "cloudflare_email" {
  description = "Cloudflare Email"
  type        = string
}

variable "cloudflare_api_key" {
  description = "Cloudflare API Key"
  type        = string
  sensitive   = true
}

variable "cf_access_client_id" {
    type = string
}

variable "cf_access_client_secret" {
    type = string
    sensitive = true
}
