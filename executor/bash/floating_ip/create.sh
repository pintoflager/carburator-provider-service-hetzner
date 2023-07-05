#!/usr/bin/env bash

carburator print terminal info "Invoking Hetzner service provider..."

# Provisioner defined with a parent command flag
provisioner="$PROVISIONER_NAME"
provider="$SERVICE_PROVIDER_NAME"

# ...Or take the first package provider has in it's packages list.
# with service / dns provider we know packages are provisioners.
if [[ -z $provisioner ]]; then
    provisioner="$SERVICE_PROVIDER_PACKAGES_0_NAME"
fi

###
# Service provider has information about the proxy nodes we have to pass along to the
# provisioner.
#
nodes=$(carburator get json nodes array-raw -p .exec.json)
tag=$(carburator get toml floating_ip_name string -p .exec.toml)
ipv4=$(carburator get toml floating_ip_v4 boolean -p .exec.toml)
ipv6=$(carburator get toml floating_ip_v4 boolean -p .exec.toml)

carburator provisioner request \
    service-provider \
    create \
    floating_ip \
        --provider "$provider" \
        --provisioner "$provisioner" \
        --key-val "ip_name=$tag" \
        --key-val "ip_v4=$ipv4" \
        --key-val "ip_v6=$ipv6" \
        --json-kv "nodes=$nodes"|| exit 120

