#!/usr/bin/env bash

# ATTENTION: Supports only client nodes, pointless to read role from $1

# We know we have secrets but this is a good practice anyways.
if carburator has json service_provider.secrets -p '.exec.json'; then

    # Read secrets from json exec environment line by line
    while read -r secret; do
        # Prompt secret if it doesn't exist yet.
        if ! carburator has secret "$secret" --user root; then
            # ATTENTION: We know only one secret is present. Otherwise
            # prompt texts should be adjusted accordingly.
            carburator print terminal warn \
                "Could not find secret containing Hetzner cloud API token."
            
            carburator prompt secret "Hetzner cloud API key" \
            --name "$secret" \
            --user root || exit 120
        fi
    done < <(carburator get json service_provider.secrets array -p '.exec.json')
fi
