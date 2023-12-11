#!/usr/bin/env bash

carburator log info "Invoking Hetzner service provider..."

###
# Executes on server node.
#
if [[ $1 == "server" ]]; then
    carburator log info \
        "Volume create can only be invoked from client nodes."
    exit 0
fi

###
# Executes on client node.
#

# Provisioner defined with a parent command flag
# ...Or take the first package provider has in it's packages list.
provisioner="${PROVISIONER_NAME:-$SERVICE_PROVIDER_PACKAGES_0_NAME}"
provider="$SERVICE_PROVIDER_NAME"

###
# Service provider has information about the proxy nodes we have to pass along to the
# provisioner.
#
nodes=$(carburator get json nodes array-raw -p .exec.json)
tag=$(carburator get toml volume_name string -p .exec.toml)

size=$(carburator get env HETZNER_VOL_SIZE -s hetzner -p hetzner.env)

if [[ -z $size ]]; then
    carburator put env HETZNER_VOL_SIZE "10" \
        -s hetzner \
        -p hetzner.env || exit 120
fi

filesystem=$(carburator get env HETZNER_VOL_FILESYSTEM -s hetzner -p hetzner.env)

if [[ -z $filesystem ]]; then
    carburator put env HETZNER_VOL_FILESYSTEM "ext4" \
        -s hetzner \
        -p hetzner.env || exit 120
fi

carburator provisioner request \
    service-provider \
    create \
    volume \
        --provider "$provider" \
        --provisioner "$provisioner" \
        --key-val "volume_name=$tag" \
        --key-val "volume_size=$size" \
        --key-val "volume_filesystem=$filesystem" \
        --json-kv "nodes=$nodes"|| exit 120

