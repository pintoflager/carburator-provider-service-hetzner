#!/usr/bin/env bash

carburator log success "Invoking Hetzner service provider..."

###
# Executes on server node.
#
if [[ $1 == "server" ]]; then
    carburator log info \
        "Project destroy can only be invoked from client nodes."
    exit 0
fi

###
# Executes on client node.
#
# Run the provisioner and hope it succeeds. Provisioner function has
# retries baked in (if enabled in provisioner.toml).
#
carburator provisioner request \
    service-provider \
    destroy \
    project \
    --provider "$SERVICE_PROVIDER_NAME" \
    --provisioner "$PROVISIONER_NAME" || exit 120

carburator log info "Destroying Hetzner service provider environment..."

# TODO: keeping these in .env ... better to prefer toml?
rm -f "$SERVICE_PROVIDER_PATH/.env"

carburator log success "Hetzner service provider environment destoryed."
