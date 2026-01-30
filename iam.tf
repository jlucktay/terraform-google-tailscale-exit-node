resource "google_service_account" "compute" {
  project = data.google_project.this.project_id

  account_id   = "tailscale-exit-node-compute"
  display_name = "Tailscale exit node Compute"
  description  = "Runs the Compute instance for the Tailscale exit node"
}

resource "google_project_iam_member" "compute_gsa_logwriter" {
  project = data.google_project.this.project_id

  role   = "roles/logging.logWriter"
  member = google_service_account.compute.member
}

resource "google_secret_manager_secret_iam_member" "compute_gsa_secretaccessor_tailscale" {
  project = data.google_project.this.project_id

  secret_id = google_secret_manager_secret.tailscale_auth_key.id

  role   = "roles/secretmanager.secretAccessor"
  member = google_service_account.compute.member
}

resource "google_secret_manager_secret_iam_member" "compute_gsa_secretaccessor_healthchecks" {
  count = length(var.healthchecks_io_uuid) > 0 ? 1 : 0

  project = data.google_project.this.project_id

  secret_id = google_secret_manager_secret.healthchecks_io_uuid[count.index].id

  role   = "roles/secretmanager.secretAccessor"
  member = google_service_account.compute.member
}
