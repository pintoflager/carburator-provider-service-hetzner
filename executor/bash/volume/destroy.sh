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

carburator provisioner request \
    service-provider \
    destroy \
    volume \
        --provider "$provider" \
        --provisioner "$provisioner" \
        --key-val "volume_name=$tag" \
        --json-kv "nodes=$nodes"|| exit 120

