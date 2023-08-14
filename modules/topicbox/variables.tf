# Input variable definitions

variable "zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "fqdn" {
  description = "Zone FQDN"
  type        = string
}

variable "allowed_senders" {
  description = "Allowed Senders for the SPF Record"
  type        = string
  default     = "ip4:64.147.108.0/24 ip4:173.228.157.0/24"
}

variable "dmarc_report_address" {
  description = "DMARC Report Adress"
  type        = string
  default     = "mailto:dmarcreports@whitestar.systems"
}

variable "allow_overwrite" {
  description = "Overwrite any existing records that conflict with the records to be created."
  type        = bool
  default     = false
}
