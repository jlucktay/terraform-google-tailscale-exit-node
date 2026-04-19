# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres to [Semantic Versioning].

## [Unreleased]

### Added

- This backfilled CHANGELOG.
- Input variable to override the default machine type for the exit node VM.
- `mise` and `pre-commit` configs:
  - Use the latest versions available of both `terraform` and `terraform-docs`.
  - Run `terraform-docs` and miscellaneous other checks on any git hooks `pre-commit` is installed to.

### Changed

- Exit node VM:
  - Machine type default from `e2-micro` to `f1-micro`.
  - Metadata now uses a conditional `local`, instead of potentially ending up with a key having an empty value.

## [v0.9.0] - 2026-01-30

### Added

- The `enable_tailscale_ssh` input variable to enable [Tailscale SSH] on the exit node.
- An `instance_logs_url` output to access Google Cloud logging for the exit node VM.

### Changed

- The `remove_previous_exit_node.sh` helper script to use a dynamic hostname over a hard-coded one.
- Resource names to add a `tailscale-` prefix.
- Renamed the `vm_manager_service_account_id` output to `compute_google_service_account_id`.

### Removed

- The `enable_vm_manager` input variable and related OS Config and VM Manager components.

### Security

- Flagged the `healthchecks_io_uuid` input variable as sensitive.
- Switched to handling sensitive values with Google Secret Manager.

## [v0.8.0] - 2026-01-16

### Added

- A `project_id` input variable, to set the Google Cloud project for all resources.
- More error-checking to the `remove_previous_exit_node.sh` helper script.

### Changed

- VM base image from Debian 11 to Debian 13.
- Minimum version of Google provider required, from 5.6 up to 7.0.

## [v0.7.0] - 2023-11-18

### Changed

- Minimum version of Google provider required, from 4.0 up to 5.6.

## [v0.6.2] - 2023-05-05

### Changed

- Provider version constraints to reduce the minor versions required.

### Fixed

- Label precedence to prefer input variable values over hard-coded defaults.

## [v0.6.1] - 2023-05-02

### Removed

- System upgrade with `apt` from the VM bootstrap script; it is quicker to re-roll the VM than to run the upgrade.

## [v0.6.0] - 2023-05-02

### Added

- System upgrade with `apt` when VM is starting up.
- More detail to the README around Tailscale device approval and rotating the tailnet key.

## [v0.5.1] - 2023-05-02

### Changed

- The description on the `vm_manager_service_account_id` output.

## [v0.5.0] - 2023-05-02

### Added

- The `enable_vm_manager` input variable to make activation of [Google Cloud VM Manager] optional.
- A project-level metadata item setting `enable-guest-attributes` to `TRUE`.

### Changed

- Default value for the `input_region` input variable to an empty string, making it a required input.

## [v0.4.0] - 2023-04-24

### Added

- A random zone selector for the nominated Google Cloud region.
- Input variable to toggle use of Google Cloud's Premium Tier network.

### Changed

- The firewall to be replaced when the network changes.

## [v0.3.1] - 2023-04-23

### Added

- A description to the public IP output.

## [v0.3.0] - 2023-04-23

### Added

- The public IP of the VM as an output.

## [v0.2.1] - 2023-04-16

### Fixed

- Invalid characters in the `terraform-module` label.

## [v0.2.0] - 2023-04-16

### Added

- Usage notes to the README.
- A null resource and helper script to remove the previous exit node from the tailnet.

### Changed

- Value of the `terraform-module` label applied to provisioned resources.

## [v0.1.0] - 2023-04-16

### Added

- Google Cloud provider provisioning the following:
  - The following project APIs/services enabled:
    - [Cloud Resource Manager].
    - [Compute].
    - [OS Config].
  - Network with one subnet.
  - Firewall to allow SSH from Google Cloud's Identity-Aware Proxy.
  - Service account with Logs Writer role.
  - VM running Debian 11, run by the above SA.
  - Template of the startup script, attached to the above VM, to:
    - Install Tailscale.
    - Configure the VM.
    - Optionally set up a cron job for Healthchecks.io.
    - Join the tailnet and advertise as an exit node.
  - Project metadata entry to enable OS Config.
- Tailscale provider provisioning an ephemeral, pre-authorised, non-reusable tailnet key.
- Input variables to control the following:
  - Whether to activate the required APIs/services in the Google Cloud project.
  - Labels to apply to provisioned resources.
  - Region selector for where to provision resources.
  - Optional UUID of a check at [Healthchecks.io].
- Outputs to emit the following:
  - IDs of the main VPC, regional subnet, exit node VM, Tailscale auth key, and the SA attached to the VM.
  - Command line to run for SSH access into the exit node VM.
  - Project APIs/services enabled.

[Cloud Resource Manager]: https://console.cloud.google.com/apis/library/cloudresourcemanager.googleapis.com
[Compute]: https://console.cloud.google.com/apis/library/compute.googleapis.com
[Google Cloud VM Manager]: https://cloud.google.com/compute/docs/vm-manager
[Healthchecks.io]: https://healthchecks.io
[Keep a Changelog]: https://keepachangelog.com/en/1.1.0/
[OS Config]: https://console.cloud.google.com/apis/library/osconfig.googleapis.com
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
[Tailscale SSH]: https://tailscale.com/docs/features/tailscale-ssh

[unreleased]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.9.0...HEAD
[v0.9.0]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.8.0...v0.9.0
[v0.8.0]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.7.0...v0.8.0
[v0.7.0]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.6.2...v0.7.0
[v0.6.2]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.6.1...v0.6.2
[v0.6.1]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.6.0...v0.6.1
[v0.6.0]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.5.1...v0.6.0
[v0.5.1]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.5.0...v0.5.1
[v0.5.0]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.3.1...v0.4.0
[v0.3.1]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.3.0...v0.3.1
[v0.3.0]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.2.1...v0.3.0
[v0.2.1]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.2.0...v0.2.1
[v0.2.0]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/jlucktay/terraform-google-tailscale-exit-node/releases/tag/v0.1.0
