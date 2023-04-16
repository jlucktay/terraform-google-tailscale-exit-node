locals {
  project_services = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "osconfig.googleapis.com",
  ]
}

resource "google_project_service" "main" {
  for_each = var.enable_apis ? toset(local.project_services) : []

  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}
