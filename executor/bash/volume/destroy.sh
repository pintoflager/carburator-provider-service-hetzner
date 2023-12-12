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

carburator provisioner request \
    service-provider \
    destroy \
    volume \
        --provider "$provider" \
        --provisioner "$provisioner" \
        --json-kv "volumes=$volumes"|| exit 120

