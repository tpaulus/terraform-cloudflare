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
  type        = list
  default     = []
}

variable "dmarc_report_address" {
  description = "DMARC Report Adress"
  type        = string
  default     = "mailto:dmarcreports@whitestar.systems"
}

variable "create_client_configuration_records" {
  description = "If Client Configuration SRV Records should be created"
  type        = bool
  default     = false
}

variable "create_wildcard_mx_records" {
  description = "Create Wildcard `*.fqdn` MX Records"
  type        = bool
  default     = false
}

variable "allow_overwrite" {
  description = "Overwrite any existing records that conflict with the records to be created."
  type        = bool
  default     = false
}
