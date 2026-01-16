resource "google_compute_project_metadata_item" "vm_manager_os_config" {
  for_each = var.enable_vm_manager ? { "enabled" = true } : {}

  project = data.google_project.this.project_id

  key   = "enable-osconfig"
  value = "TRUE"
}

data "google_project" "this" {
  project_id = var.project_id
}

resource "google_service_account" "vm_manager" {
  project     = data.google_project.this.project_id
  description = "VM Manager (OS Config API)"

  account_id   = format("service-%s", data.google_project.this.number)
  display_name = "VM Manager (OS Config API)"
}

resource "google_project_iam_member" "vm_manager_logwriter" {
  for_each = var.enable_vm_manager ? { "enabled" = true } : {}

  project = data.google_project.this.project_id
  role    = "roles/logging.logWriter"
  member  = google_service_account.vm_manager.member
}

# https://cloud.google.com/compute/docs/metadata/overview#guest_attributes
resource "google_compute_project_metadata_item" "vm_metadata_guest_attributes" {
  project = data.google_project.this.project_id

  key   = "enable-guest-attributes"
  value = "TRUE"
}
