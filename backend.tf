terraform {
  cloud {
    organization = "tpaulus"

    workspaces {
      name = "cloudflare"
    }
  }
}
