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

###
# Service provider has information about the nodes we have to pass along to the
# provisioner.
#
provisioner_node="$PROJECT_PATH/provisioners/$provisioner/providers/$PROVIDER_NAME/node"
provider_node="$provider_node/node"

# We could process the nodes array here to the format the provisioner is expecting
# but better keep provider layer thin and let the provisioner do what it needs
# with the original data
if [[ -e $provider_node/.exec.env ]]; then
    carburator print terminal fyi \
        "Copying $PROVIDER_NAME .exec.env to $provisioner as .provider.exec.env..."
    cp -f "$provider_node/.exec.env" "$provisioner_node/.provider.exec.env"
fi

if [[ -e $provider_node/.exec.json ]]; then
    carburator print terminal fyi \
        "Copying $PROVIDER_NAME .exec.json to $provisioner as .provider.exec.json..."
    cp -f "$provider_node/.exec.json" "$provisioner_node/.provider.exec.json"
fi

if [[ -e $provider_node/.exec.yaml ]]; then
    carburator print terminal fyi \
        "Copying $PROVIDER_NAME .exec.yaml to $provisioner as .provider.exec.yaml..."
    cp -f "$provider_node/.exec.yaml" "$provisioner_node/.provider.exec.yaml"
fi

if [[ -e $provider_node/.exec.toml ]]; then
    carburator print terminal fyi \
        "Copying $PROVIDER_NAME .exec.toml to $provisioner as .provider.exec.toml..."
    cp -f "$provider_node/.exec.toml" "$provisioner_node/.provider.exec.toml"
fi

carburator provisioner request \
    create \
    node \
    --provider "$PROVIDER_NAME" \
    --provisioner "$provisioner" || exit 120

carburator print terminal success "Hetzner node(s) created."
