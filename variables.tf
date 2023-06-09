variable "enable_apis" {
  description = "Activate required API services for the Google Cloud project."
  type        = bool
  default     = true
}

variable "enable_vm_manager" {
  description = "Activate [Google Cloud VM Manager](https://cloud.google.com/compute/docs/vm-manager)."
  type        = bool
  default     = false
}

variable "labels" {
  description = "A map of labels to apply to contained resources."
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "Google Cloud region to deploy resources in."
  type        = string

  validation {
    condition     = length(var.region) > 0
    error_message = "The 'region' input variable must be a string longer than zero characters."
  }
}

variable "healthchecks_io_uuid" {
  description = "UUID of a check at Healthchecks.io that the exit node VM will poll every 15 minutes with curl from a cron job. If left unset then the check will not be set up."
  type        = string
  default     = ""

  validation {
    condition     = length(var.healthchecks_io_uuid) == 0 || length(var.healthchecks_io_uuid) == 36
    error_message = "If providing a UUID, please use the following format: aaaaaaaa-1111-2222-3333-bbbbbbbbbbbb"
  }
}

variable "use_premium_network_tier" {
  description = "Whether or not to use [Google Cloud's Premium Tier network](https://cloud.google.com/network-tiers/docs/overview)."
  type        = bool
  default     = false
  sensitive   = false
}
