resource "google_compute_project_metadata_item" "enable_vm_manager_os_config" {
  key   = "enable-osconfig"
  value = "TRUE"
}

data "google_project" "this" {}

resource "google_service_account" "vm_manager" {
  account_id   = format("service-%s", data.google_project.this.number)
  display_name = "VM Manager (OS Config API)"
  description  = "VM Manager (OS Config API)"
}

resource "google_project_iam_member" "vm_manager_logwriter" {
  project = data.google_project.this.project_id
  role    = "roles/logging.logWriter"
  member  = google_service_account.vm_manager.member
}
