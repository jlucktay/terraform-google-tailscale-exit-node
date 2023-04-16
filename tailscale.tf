resource "tailscale_tailnet_key" "one_time_use" {
  ephemeral     = true
  preauthorized = true
  reusable      = false

  expiry = 3600

  tags = []
}
