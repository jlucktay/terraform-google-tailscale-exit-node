resource "google_secret_manager_secret" "tailscale_auth_key" {
  secret_id = "tailscale-auth-key"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "tailscale_auth_key" {
  secret = google_secret_manager_secret.tailscale_auth_key.id

  secret_data = tailscale_tailnet_key.one_time_use.key
}

resource "google_secret_manager_secret" "healthchecks_io_uuid" {
  count = length(var.healthchecks_io_uuid) > 0 ? 1 : 0

  secret_id = "healthchecks-io-uuid"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "healthchecks_io_uuid" {
  count = length(var.healthchecks_io_uuid) > 0 ? 1 : 0

  secret = google_secret_manager_secret.healthchecks_io_uuid[count.index].id

  secret_data = var.healthchecks_io_uuid
}
