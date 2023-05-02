# Tailscale Exit Node on Google Cloud

Infrastructure for a Tailscale exit node.

- VM running Debian that will join the tailnet at launch and advertise as an exit node.
  - If the user generating the auth key is set up as an `autoApprover` in tailnet policy then the exit node will be
    added without requiring manual approval.
- Dedicated VPC network and subnet, and a firewall rule to allow SSHing into the exit node VM via Identity-Aware Proxy.
- Enablement of the necessary Google Cloud APIs/services.

## Usage

Both the Google Cloud and Tailscale providers will require authentication:

- For Tailscale, it is recommended to
  [set the `TAILSCALE_API_KEY` environment variable](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs#api_key)
  with a [valid API access token](https://login.tailscale.com/admin/settings/keys) generated from the admin console.
  - The shell script executed by `null_resource.remove_previous_exit_node` will also make use of this
    `TAILSCALE_API_KEY` environment variable.
- Google Cloud provider authentication is
  [documented here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication).

<!-- BEGIN_TF_DOCS -->

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.4)

- <a name="requirement_google"></a> [google](#requirement\_google) (~> 4.61)

- <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) (~> 0.13)

## Providers

The following providers are used by this module:

- <a name="provider_google"></a> [google](#provider\_google) (~> 4.61)

- <a name="provider_null"></a> [null](#provider\_null)

- <a name="provider_random"></a> [random](#provider\_random)

- <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) (~> 0.13)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [google_compute_address.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) (resource)
- [google_compute_firewall.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) (resource)
- [google_compute_instance.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) (resource)
- [google_compute_network.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) (resource)
- [google_compute_project_default_network_tier.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_project_default_network_tier) (resource)
- [google_compute_project_metadata_item.vm_manager_os_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_project_metadata_item) (resource)
- [google_compute_project_metadata_item.vm_metadata_guest_attributes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_project_metadata_item) (resource)
- [google_compute_subnetwork.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) (resource)
- [google_project_iam_member.vm_manager_logwriter](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) (resource)
- [google_project_service.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) (resource)
- [google_service_account.vm_manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) (resource)
- [null_resource.remove_previous_exit_node](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)
- [random_integer.region_selector](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)
- [tailscale_tailnet_key.one_time_use](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/tailnet_key) (resource)
- [google_compute_image.debian](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) (data source)
- [google_compute_zones.region](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) (data source)
- [google_project.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_region"></a> [region](#input\_region)

Description: Google Cloud region to deploy resources in.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_apis"></a> [enable\_apis](#input\_enable\_apis)

Description: Activate required API services for the Google Cloud project.

Type: `bool`

Default: `true`

### <a name="input_enable_vm_manager"></a> [enable\_vm\_manager](#input\_enable\_vm\_manager)

Description: Activate [Google Cloud VM Manager](https://cloud.google.com/compute/docs/vm-manager).

Type: `bool`

Default: `false`

### <a name="input_use_premium_network_tier"></a> [use\_premium\_network\_tier](#input\_use\_premium\_network\_tier)

Description: Whether or not to use [Google Cloud's Premium Tier network](https://cloud.google.com/network-tiers/docs/overview).

Type: `bool`

Default: `false`

### <a name="input_labels"></a> [labels](#input\_labels)

Description: A map of labels to apply to contained resources.

Type: `map(string)`

Default: `{}`

### <a name="input_healthchecks_io_uuid"></a> [healthchecks\_io\_uuid](#input\_healthchecks\_io\_uuid)

Description: UUID of a check at Healthchecks.io that the exit node VM will poll every 15 minutes with curl from a cron job. If left unset then the check will not be set up.

Type: `string`

Default: `""`

## Outputs

The following outputs are exported:

### <a name="output_enabled_apis"></a> [enabled\_apis](#output\_enabled\_apis)

Description: The service APIs that have been enabled by this module.

### <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id)

Description: The ID of the exit node VM.

### <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip)

Description: The public IP address of the exit node VM.

### <a name="output_instance_ssh_command"></a> [instance\_ssh\_command](#output\_instance\_ssh\_command)

Description: The command line to run for SSH access into the exit node VM.

### <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id)

Description: The ID of the regional subnet.

### <a name="output_tailscale_key_id"></a> [tailscale\_key\_id](#output\_tailscale\_key\_id)

Description: The ID of the Tailscale auth key that the exit node VM joined the tailnet with.

### <a name="output_vm_manager_service_account_id"></a> [vm\_manager\_service\_account\_id](#output\_vm\_manager\_service\_account\_id)

Description: The ID of the service account attached to the VM. If the `enable_vm_manager` input variable is set to `true` then this SA will also enable VM Manager.

### <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id)

Description: The ID of the main VPC.

<!-- END_TF_DOCS -->
