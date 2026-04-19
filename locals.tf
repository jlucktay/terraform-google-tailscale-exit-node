locals {
  firewall_ports = concat([22], var.vm_extra_iap_ports)

  network_tier = var.use_premium_network_tier ? "PREMIUM" : "STANDARD"

  labels = {
    "terraform-module" = "jlucktay_tailscale-exit-node_google"
  }

  project_services = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "secretmanager.googleapis.com",
  ]

  vm_metadata = var.enable_tailscale_ssh ? {
    "enable-tailscale-ssh" = "1"
  } : {}
}
