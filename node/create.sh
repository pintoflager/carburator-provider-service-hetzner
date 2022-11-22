#!/usr/bin/env bash

carburator fn echo info "Invoking Hetzner service provider..."

###
# Run the provisioner and hope it succeeds. Provisioner function has
# retries baked in (if enabled in provisioner.toml).
#
carburator provisioner request \
    create \
    node \
    --provider "$PROVIDER_NAME" \
    --provisioner "$PROVISIONER_NAME" \
    --preserve_env || exit 120

carburator fn echo success "Hetzner node(s) created."
