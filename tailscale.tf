resource "tailscale_tailnet_key" "one_time_use" {
  description = "Used by the exit node VM to join the Tailnet"

  ephemeral     = true
  preauthorized = true
  reusable      = false

  expiry = 3600

  tags = []
}

resource "null_resource" "remove_previous_exit_node" {
  provisioner "local-exec" {
    command = format("%s/remove_previous_exit_node.sh", path.module)
    when    = destroy

    environment = {
      # This string value must match the exit node VM's hostname, but cannot be a `local.*` reference.
      "DEVICE_HOSTNAME" = "tailscale-exit-node-vm"
    }
  }

  lifecycle {
    replace_triggered_by = [
      google_compute_instance.main
    ]
  }
}
