terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.18.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}


provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}


provider "nomad" {
  address = "https://nomad.brickyard.whitestar.systems"

  headers {
    name = "CF-Access-Client-Id"
    value = var.cf_access_client_id
  }

  headers {
    name = "CF-Access-Client-Secret"
    value = var.cf_access_client_secret
  }
}

provider "random" {
}
