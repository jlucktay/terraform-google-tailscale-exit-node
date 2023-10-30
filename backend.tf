terraform {
  required_providers {
    google = {
      source = "hashicorp/google"

      # Pin to major version 4, and allow minor/patch upgrades.
      version = "~> 5.4"
    }

    tailscale = {
      source = "tailscale/tailscale"

      # Pin to major version 0, and allow minor/patch upgrades.
      version = "~> 0.0"
    }
  }

  # Pin to major version 1, and allow minor/patch upgrades.
  required_version = "~> 1.0"
}
