#!/usr/bin/env bash
set -euxo pipefail

# Tailscale API docs are here: https://github.com/tailscale/tailscale/blob/main/api.md

if [[ -z $TAILSCALE_API_KEY ]]; then
  echo >&2 "No API key found for Tailscale; exiting."
  exit 1
fi

if ! tailnet_devices=$(curl --request GET --silent --user "$TAILSCALE_API_KEY:" \
  "https://api.tailscale.com/api/v2/tailnet/-/devices"); then
  echo >&2 "Could not get Tailnet devices; exiting."
  exit 1
fi

if ! exit_node_id=$(jq --exit-status --raw-output \
  '.devices[] | select( .hostname == "exit-node-vm" ) | .nodeId' <<< "$tailnet_devices"); then
  echo "No previous exit node device found on Tailnet."
  exit 0
else
  curl --request DELETE --user "$TAILSCALE_API_KEY:" "https://api.tailscale.com/api/v2/device/$exit_node_id"
fi
