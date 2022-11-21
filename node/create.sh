#!/usr/bin/env bash

carburator fn paint green "Invoking Hetzner service provider..."

###
# Run the provisioner and hope it succeeds. Provisioner function has
# retries baked in (if enabled in provisioner.toml).
#
carburator provisioner request \
    create \
    node \
    --provider "$PROVIDER_NAME" \
    --provisioner "$PROVISIONER_NAME" || exit 120

carburator fn paint green "Hetzner node(s) created."
