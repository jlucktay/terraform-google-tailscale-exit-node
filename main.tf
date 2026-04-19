data "google_project" "this" {
  project_id = var.project_id
}

data "google_compute_image" "debian" {
  project = "debian-cloud"
  family  = "debian-13"
}

data "google_compute_zones" "region" {
  project = data.google_project.this.project_id
  region  = var.region
}

resource "random_integer" "region_selector" {
  min = 1
  max = length(data.google_compute_zones.region.names)

  keepers = {
    # Pick a new region for the exit node each time we regenerate the tailnet key, which in turns causes the exit node to be recreated.
    tail_key = tailscale_tailnet_key.one_time_use.key
  }
}

# Guest attributes are used to pass non-sensitive info into the VM's startup script.
# https://cloud.google.com/compute/docs/metadata/overview#guest_attributes
resource "google_compute_project_metadata_item" "vm_metadata_guest_attributes" {
  project = data.google_project.this.project_id

  key   = "enable-guest-attributes"
  value = "TRUE"
}

resource "google_compute_instance" "main" {
  name        = "tailscale-exit-node-vm"
  description = "Tailscale exit node VM within the dedicated VPC/subnet."

  project = data.google_project.this.project_id

  machine_type = var.vm_machine_type
  zone         = element(data.google_compute_zones.region.names, random_integer.region_selector.result)

  allow_stopping_for_update = true
  can_ip_forward            = true

  metadata = local.vm_metadata

  metadata_startup_script = file("${path.module}/startup.sh")

  boot_disk {
    auto_delete = true
    device_name = "tailscale-exit-node-vm-pd0"

    initialize_params {
      image  = data.google_compute_image.debian.self_link
      labels = merge(local.labels, var.labels)
      size   = 10
      type   = "pd-standard"
    }
  }

  lifecycle {
    ignore_changes = [
      boot_disk[0].initialize_params[0].image,
      boot_disk[0].initialize_params[0].labels,
      labels,
    ]
  }

  network_interface {
    subnetwork = google_compute_subnetwork.main.id

    access_config {
      nat_ip = google_compute_address.main.address
    }
  }

  service_account {
    email = google_service_account.compute.email

    scopes = [
      "cloud-platform",
    ]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }

  labels = merge(local.labels, var.labels)

  tags = [
    "allow-from-iap"
  ]

  depends_on = [
    google_project_service.main["compute.googleapis.com"],
    google_secret_manager_secret_version.tailscale_auth_key,
  ]
}
