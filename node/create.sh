#!/usr/bin/env bash

carburator print terminal info "Invoking Hetzner service provider..."

###
# Run the provisioner and hope it succeeds. Provisioner function has
# retries baked in (if enabled in provisioner.toml).
#
provisioner="$PROVISIONER_NAME"

if [[ -z $provisioner ]]; then
    provisioner="$PROVIDER_PROVISIONERS_0_NAME"
fi

carburator provisioner request \
    create \
    node \
    --provider "$PROVIDER_NAME" \
    --provisioner "$PROVISIONER_NAME" || exit 120

carburator print terminal success "Hetzner node(s) created."
