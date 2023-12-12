#!/usr/bin/env bash

carburator log info "Invoking Hetzner service provider..."

###
# Executes on server node.
#
if [[ $1 == "server" ]]; then
    carburator log info \
        "Volume create can only be invoked from client volumes."
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
# Service provider has information about the proxy volumes we have to pass along to the
# provisioner.
#
volumes=$(carburator get json volumes array-raw -p .exec.json)

# Binary doesn't know shit about available volume sizes or filesystems.
# Set 'global' preference for hetzner which applies if volume size is empty.
size=$(carburator get env HETZNER_VOL_SIZE -s hetzner -p hetzner.env)
filesystem=$(carburator get env HETZNER_VOL_FILESYSTEM -s hetzner -p hetzner.env)

if [[ -z $size ]]; then
    size=10

    carburator put env HETZNER_VOL_SIZE "$size" \
        -s hetzner \
        -p hetzner.env || exit 120
fi

if [[ -z $filesystem ]]; then
    filesystem="ext4"

    carburator put env HETZNER_VOL_FILESYSTEM "$filesystem" \
        -s hetzner \
        -p hetzner.env || exit 120
fi

carburator provisioner request \
    service-provider \
    create \
    volume \
        --provider "$provider" \
        --provisioner "$provisioner" \
        --key-val "volume_default_size=$size" \
        --key-val "volume_default_filesystem=$filesystem" \
        --json-kv "volumes=$volumes"|| exit 120

