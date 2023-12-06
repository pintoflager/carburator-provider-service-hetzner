#!/usr/bin/env bash

###
# Executes on server node.
#
if [[ $1 == "server" ]]; then
    carburator log info \
        "Node destroy can only be invoked from client nodes."
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
# Service provider has information about the nodes we have to pass along to the
# provisioner.
#
nodes=$(carburator get json nodes array-raw -p .exec.json)

# Go in reversed order with the destroy and start unwrapping from private network
carburator log info 'Destroying private networks of Hetzner nodes...'

carburator provisioner request \
    service-provider \
        destroy \
        network \
            --provider "$provider" \
            --provisioner "$provisioner" \
            --json-kv "nodes=$nodes" || exit 120

# When resources created with nodes are gone kill nodes as well
carburator provisioner request \
    service-provider \
    destroy \
    node \
    --provider "$provider" \
    --provisioner "$provisioner" \
    --json-kv "nodes=$nodes"|| exit 120
