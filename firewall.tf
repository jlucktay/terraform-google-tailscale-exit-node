resource "google_compute_firewall" "main" {
  name        = "tailscale-exit-node-firewall"
  description = "Allow incoming traffic from Google Cloud's Identity-Aware Proxy into resources tagged with 'allow-from-iap'."

  project = data.google_project.this.project_id
  network = google_compute_network.main.id

  allow {
    ports    = local.firewall_ports
    protocol = "tcp"
  }

  source_ranges = [
    "35.235.240.0/20"
  ]

  target_tags = [
    "allow-from-iap"
  ]

  lifecycle {
    replace_triggered_by = [
      google_compute_network.main
    ]
  }
}
