# Input variable definitions

variable "zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "allowed_senders" {
  description = "Allowed Senders for the SPF Record"
  type        = list
  default     = []
}

variable "allow_overwrite" {
  description = "Overwrite any existing records that conflict with the records to be created."
  type        = bool
  default     = false
}
