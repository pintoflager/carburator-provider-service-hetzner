#!/usr/bin/env bash

secret_name="$PACKAGE_SECRET_NAME"

# Prompt secret if it doesn't exist yet.
if ! carburator has secret "$secret_name" --user root; then
    carburator print terminal warn \
		"Could not find secret containing Hetzner cloud API token."
	
    carburator prompt secret "Hetzner cloud API key" \
      --name "$secret_name" \
      --user root || exit 120
fi
