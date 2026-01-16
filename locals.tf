locals {
  network_tier = var.use_premium_network_tier ? "PREMIUM" : "STANDARD"

  labels = {
    "terraform-module" = "jlucktay_tailscale-exit-node_google"
  }

  project_services = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "osconfig.googleapis.com",
  ]
}
