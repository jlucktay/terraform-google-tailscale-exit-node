#!/usr/bin/env bash
set -euxo pipefail

# Tailscale exit node VM startup script

declare -i attempts=0

# Loop until the network comes up and this instance can access the public internet.
until curl --fail --output /dev/null --silent -- "https://tailscale.com/install.sh"; do
	if ((attempts++ >= 100)); then
		exit 1
	fi

	sleep 3s
done

# Retrieve values from Google Cloud instance-level metadata.
declare -a curl_flags=(
	--connect-timeout 5
	--max-time 60
	--retry 5
	--header "Metadata-Flavor: Google"
)

readonly metadata_base="http://metadata.google.internal/computeMetadata/v1/instance/attributes"

enable_tailscale_ssh="$(curl "${curl_flags[@]}" "$metadata_base/enable-tailscale-ssh")"
healthchecks_io_uuid="$(curl "${curl_flags[@]}" "$metadata_base/healthchecks-io-uuid")"
tailscale_auth_key="$(curl "${curl_flags[@]}" "$metadata_base/tailscale-auth-key")"

# Install Tailscale: https://tailscale.com/kb/1031/install-linux/
curl --fail --location --show-error --silent -- "https://tailscale.com/install.sh" | sh

# Enable IP forwarding: https://tailscale.com/kb/1103/exit-nodes/?tab=linux#enable-ip-forwarding
echo 'net.ipv4.ip_forward = 1' | tee --append /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee --append /etc/sysctl.d/99-tailscale.conf
sysctl --load=/etc/sysctl.d/99-tailscale.conf

# Linux optimizations for exit nodes: https://tailscale.com/kb/1320/performance-best-practices#linux-optimizations-for-subnet-routers-and-exit-nodes
NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")

tee /etc/networkd-dispatcher/routable.d/50-tailscale > /dev/null << EOF
#!/bin/sh

ethtool --features $NETDEV rx-udp-gro-forwarding on rx-gro-list off
EOF

chmod 755 /etc/networkd-dispatcher/routable.d/50-tailscale
/etc/networkd-dispatcher/routable.d/50-tailscale

# Set up Healthchecks.io cron job, if a non-empty UUID string was passed in.
if [[ -n $healthchecks_io_uuid ]]; then
	cat <<- EOT > /etc/cron.d/healthchecks
		SHELL="/bin/bash"
		PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
		MAILTO=""

		# Health check ping
		*/15 * * * *   root   curl --fail --max-time 10 --retry 5 --show-error --silent "https://hc-ping.com/$healthchecks_io_uuid"
	EOT
fi

# Ensure node state encrypts at rest: https://tailscale.com/kb/1596/secure-node-state-storage#linux
sed -i '/FLAGS=""/c\FLAGS="--encrypt-state"' /etc/default/tailscaled
systemctl restart tailscaled

# Accumulate flags to call 'tailscale up' with.
declare -a tailscale_up_flags=(
	--advertise-exit-node
	--auth-key="$tailscale_auth_key"
)

if [[ $enable_tailscale_ssh == "1" ]]; then
	tailscale_up_flags+=(--ssh)
fi

# Advertise the VM as an exit node: https://tailscale.com/kb/1408/quick-guide-exit-nodes?tab=linux
tailscale up "${tailscale_up_flags[@]}"
