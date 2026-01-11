terraform {
  # Pin to a major version, and allow minor/patch upgrades.
  required_version = "~> 1.0"

  required_providers {
    google = {
      source = "hashicorp/google"

      # Pin to a major version, and allow minor/patch upgrades.
      version = "~> 7.0"
    }

    tailscale = {
      source = "tailscale/tailscale"

      # Pin to a major version, and allow minor/patch upgrades.
      version = "~> 0.0"
    }
  }
}
