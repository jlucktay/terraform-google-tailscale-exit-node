locals {
  labels = {
    "terraform-module" = "jlucktay_tailscale-exit-node_google"
  }
}

data "google_compute_image" "debian" {
  project = "debian-cloud"
  family  = "debian-13"
}

data "google_compute_zones" "region" {
  region = var.region
}

resource "random_integer" "region_selector" {
  min = 1
  max = length(data.google_compute_zones.region.names)

  keepers = {
    # Pick a new region for the exit node each time we regenerate the Tailnet key, which in turns causes the exit node to be recreated.
    tail_key = tailscale_tailnet_key.one_time_use.key
  }
}

resource "google_compute_instance" "main" {
  name = "exit-node-vm"

  machine_type = "e2-micro"
  zone         = element(data.google_compute_zones.region.names, random_integer.region_selector.result)

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
      labels = merge(local.labels, var.labels)
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

    access_config {
      nat_ip = google_compute_address.main.address
    }
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

  labels = merge(local.labels, var.labels)

  tags = [
    "ssh"
  ]
}
