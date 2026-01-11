#!/usr/bin/env bash
set -euo pipefail

# Tailscale API docs are here: https://tailscale.com/api

if [[ -z ${TAILSCALE_API_KEY-} ]]; then
  echo >&2 "No API key found for Tailscale in the 'TAILSCALE_API_KEY' environment variable; exiting."
  exit 1
fi

if ! tailnet_devices=$(curl --location --request GET --silent --user "$TAILSCALE_API_KEY:" "https://api.tailscale.com/api/v2/tailnet/-/devices"); then
  echo >&2 "Could not get devices on Tailnet from Tailscale API; exiting."
  exit 1
fi

if [[ $tailnet_devices == '{"message":"API token invalid"}' ]]; then
  echo >&2 "The API key in the 'TAILSCALE_API_KEY' environment variable is invalid; exiting."
  exit 1
fi

if ! exit_node_id=$(jq --raw-output '.devices[] | select( .hostname == "exit-node-vm" ) | .nodeId' <<< "$tailnet_devices"); then
  echo >&2 "Could not parse exit node ID from list of Tailnet devices; exiting."
  exit 1
fi

if [[ -z $exit_node_id ]]; then
  echo "No previous exit node device found on Tailnet; exiting."
  exit 0
fi

if ! curl --request DELETE --user "$TAILSCALE_API_KEY:" "https://api.tailscale.com/api/v2/device/$exit_node_id"; then
  echo >&2 "Could not delete exit node ID '$exit_node_id' from Tailnet; exiting."
  exit 1
fi
