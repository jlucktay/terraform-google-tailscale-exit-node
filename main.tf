locals {
  labels = {
    "terraform-module" = "https://registry.terraform.io/modules/jlucktay/tailscale-exit-node/google"
  }
}

resource "google_compute_network" "main" {
  name = "exit-node-network"

  description             = "The main VPC for the exit node and its subnet."
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "exit-node-subnet"
  ip_cidr_range = "10.128.0.0/20"
  network       = google_compute_network.main.id

  description = "Regional subnet of the main VPC for the exit node."
  purpose     = "PRIVATE"
  role        = "ACTIVE"

  private_ip_google_access = true
  region                   = var.region
  stack_type               = "IPV4_ONLY"
}

data "google_compute_image" "debian" {
  project = "debian-cloud"
  family  = "debian-11"
}

data "google_compute_zones" "region" {
  region = var.region
}

resource "google_compute_instance" "main" {
  machine_type = "e2-micro"

  name = "exit-node-vm"
  zone = element(data.google_compute_zones.region.names, 0)

  allow_stopping_for_update = true
  can_ip_forward            = true

  description = "Tailscale exit node VM within the dedicated VPC/subnet."

  metadata_startup_script = templatefile(format("%s/startup.tftpl", path.module),
    {
      healthchecks = length(var.healthchecks_io_uuid) == 0 ? [] : [var.healthchecks_io_uuid],
      ts_auth_key  = tailscale_tailnet_key.one_time_use.key,
    }
  )

  boot_disk {
    auto_delete = true
    device_name = "exit-node-vm-pd0"

    initialize_params {
      image  = data.google_compute_image.debian.self_link
      labels = merge(var.labels, local.labels)
      size   = 10
      type   = "pd-standard"
    }
  }

  lifecycle {
    ignore_changes = [
      boot_disk[0].initialize_params[0].labels,
      labels,
    ]
  }

  network_interface {
    subnetwork = google_compute_subnetwork.main.id

    // Ephemeral public IP
    access_config {}
  }

  service_account {
    email = google_service_account.vm_manager.email

    scopes = [
      "cloud-platform",
    ]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }

  labels = merge(var.labels, local.labels)

  tags = [
    "ssh"
  ]
}
