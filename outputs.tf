output "vpc_id" {
  description = "The ID of the main VPC."
  value       = google_compute_network.main.id
  sensitive   = false
}

output "subnet_id" {
  description = "The ID of the regional subnet."
  value       = google_compute_subnetwork.main.id
  sensitive   = false
}

output "instance_id" {
  description = "The ID of the exit node VM."
  value       = google_compute_instance.main.id
  sensitive   = false
}

output "instance_logs_url" {
  description = "The URL to access Google Cloud logging for the exit node VM."
  sensitive   = false

  value = format(
    "https://console.cloud.google.com/logs/query;query=labels.instance_name%%3D%%22%s%%22;duration=P1D?project=%s",
    google_compute_instance.main.name,
    google_compute_instance.main.project,
  )
}

output "instance_ssh_command" {
  description = "The command line to run for SSH access into the exit node VM."
  sensitive   = false

  value = format(
    "gcloud compute ssh %s --project=%s --tunnel-through-iap --zone=%s",
    google_compute_instance.main.name,
    google_compute_instance.main.project,
    google_compute_instance.main.zone,
  )
}

output "instance_public_ip" {
  description = "The public IP address of the exit node VM."
  value       = google_compute_instance.main.network_interface[0].access_config[0].nat_ip
  sensitive   = false
}

output "tailscale_key_id" {
  description = "The ID of the Tailscale auth key that the exit node VM joined the tailnet with."
  value       = tailscale_tailnet_key.one_time_use.id
  sensitive   = false
}

output "vm_manager_service_account_id" {
  description = "The ID of the service account attached to the VM. If the `enable_vm_manager` input variable is set to `true` then this SA will also enable VM Manager."
  value       = google_service_account.vm_manager.id
  sensitive   = false
}

output "enabled_apis" {
  description = "The service APIs that have been enabled by this module."
  value       = values(google_project_service.main).*.service
  sensitive   = false
}
