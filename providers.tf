terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.37.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}


provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "random" {
}
