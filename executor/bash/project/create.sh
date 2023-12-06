#!/usr/bin/env bash

carburator log info "Invoking Hetzner service provider..."

###
# Executes on server node.
#
if [[ $1 == "server" ]]; then
    carburator log info \
        "Project create can only be invoked from client nodes."
    exit 0
fi

###
# Executes on client node.
#
# Provisioner defined with a parent command flag
# ...Or take the first package provider has in it's packages list.
provisioner="${PROVISIONER_NAME:-$SERVICE_PROVIDER_PACKAGES_0_NAME}"

# Hetzner recreates all nodes where root key changes. This will most likely
# destroy your complete environment so let's not do that and instead lock in
# our root key.
root_pubkey=$(carburator get env HETZNER_ROOT_PUBLIC_SSKEY -s hetzner -p hetzner.env)

if [[ -z $root_pubkey ]]; then
    root_pubkey=$(carburator get env REGISTER_ROOT_PUBLIC_SSHKEY_0 \
        -p .exec.env) || exit 120

    carburator put env HETZNER_ROOT_PUBLIC_SSKEY "$root_pubkey" \
        -s hetzner \
        -p hetzner.env || exit 120
fi

if [[ -z $root_pubkey ]]; then
    carburator log error \
        "Unable to find path to root public SSH key from .exec.env"
    exit 120
fi

###
# Run the provisioner and hope it succeeds. Provisioner function has
# retries baked in (if enabled in provisioner.toml).
#
carburator provisioner request \
    service-provider \
    create \
    project \
        --provider "$SERVICE_PROVIDER_NAME" \
        --provisioner "$provisioner" \
        --key-val "ROOT_SSH_PUBKEY=$root_pubkey" || exit 120

carburator log success "Hetzner project created."
