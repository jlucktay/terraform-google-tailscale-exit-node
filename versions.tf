# https://docs.cloud.google.com/docs/terraform/best-practices/reusable-modules#providers-backends
# Pin to a major version, and allow minor/patch upgrades.

terraform {
  required_version = "~> 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.0"
    }
  }
}
