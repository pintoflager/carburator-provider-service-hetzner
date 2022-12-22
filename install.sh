#!/usr/bin/env bash

secret_name="$PROVIDER_SECRET_NAME"

# Prompt secret if it doesn't exist yet.
if ! carburator has secret "$secret_name" --user root; then
    carburator print terminal warn \
		"Could not find secret containing Hetzner cloud API token."
	
    ask="Hetzner cloud API key"
    secret=$(carburator prompt secret "$ask") || exit 120

    carburator put secret "$secret_name" "$secret" --user root || exit 120
fi
