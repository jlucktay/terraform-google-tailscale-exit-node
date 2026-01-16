resource "google_compute_project_default_network_tier" "main" {
  project      = data.google_project.this.project_id
  network_tier = local.network_tier
}

resource "google_compute_network" "main" {
  name        = "tailscale-exit-node-network"
  description = "Main VPC for the exit node and its subnet."

  project = data.google_project.this.project_id

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name        = "tailscale-exit-node-subnet"
  description = "Regional subnet of the main VPC for the exit node."

  project = data.google_project.this.project_id

  ip_cidr_range = "10.128.0.0/20"
  network       = google_compute_network.main.id

  purpose = "PRIVATE"
  role    = "ACTIVE"

  private_ip_google_access = true
  region                   = var.region
  stack_type               = "IPV4_ONLY"
}

resource "google_compute_address" "main" {
  name        = "tailscale-exit-node-ip"
  description = "Static IP address for the exit node."

  address_type = "EXTERNAL"
  network_tier = local.network_tier
  region       = var.region
}
