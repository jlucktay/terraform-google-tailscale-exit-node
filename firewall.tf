resource "google_compute_firewall" "main" {
  name = "exit-node-firewall"

  project     = data.google_project.this.project_id
  network     = google_compute_network.main.id
  description = "Allow incoming SSH from Identity-Aware Proxy into resources tagged with 'ssh'."

  allow {
    protocol = "tcp"

    ports = [
      "22"
    ]
  }

  source_ranges = [
    "35.235.240.0/20"
  ]

  target_tags = [
    "ssh"
  ]

  lifecycle {
    replace_triggered_by = [
      google_compute_network.main
    ]
  }
}
