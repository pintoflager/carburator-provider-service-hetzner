#!/usr/bin/env bash

carburator fn paint green "Invoking Hetzner service provider..."

###
# Run the provisioner and hope it succeeds. Provisioner function has
# retries baked in (if enabled in provisioner.toml).
#
carburator-rule provisioner request \
    service-provider \
    destroy \
    project \
    --provider "$PROVIDER_NAME" \
    --provisioner "$PROVISIONER_NAME" || exit 120

carburator print terminal info "Destroying Hetzner service provider environment..."

# TODO: keeping these in .env ... better to prefer toml?
rm -f "$PROVIDER_PATH/.env"

carburator print terminal success "Hetzner service provider environment destoryed."
