resource "google_project_service" "main" {
  for_each = var.enable_apis ? toset(local.project_services) : []

  project = data.google_project.this.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}
