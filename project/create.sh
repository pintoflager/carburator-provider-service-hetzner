#!/usr/bin/env bash

# ATTENTION: Scripts run from carburator project's public root directory:
# echo "$PWD"

# ATTENTION: to check the environment variables uncomment:
# env

carburator print terminal info "Invoking Hetzner service provider..."

# REMEMBER: provider could be hard coded to 'hetzner' here, but carburator returns
# the name so might as well use it.

# REMEMBER: If service provider only supports one provisioner, it should be used
# instead of "$PROVISIONER_NAME" variable.

# Provisioner defined with a parent command flag
provisioner="$PROVISIONER_NAME"

# ...Or take the first package provider has in it's packages list.
# with service / dns provider we know packages are provisioners.
if [[ -z $provisioner ]]; then
    provisioner="$PROVIDER_PACKAGES_0_NAME"
fi


###
# Run the provisioner and hope it succeeds. Provisioner function has
# retries baked in (if enabled in provisioner.toml).
#
carburator-rule provisioner request \
    service-provider \
    create \
    project \
    --provider "$PROVIDER_NAME" \
    --provisioner "$provisioner" || exit 120

# Example:
# Extract values from provisioner output and save it to service provider?
# if [[ $PROVISIONER_NAME == 'terraform' ]]; then
    # We know how terraform spits out it's response (json) and we even know the
    # format of data. Lets extract what's needed (ssh key name and ID)
    # Save project ssh key name / id to environment.
    
    # output="$PROVISIONER_PROVIDER_PATH/project.json"

    # id=$(jq -rc '.project.value.sshkey_id' "$output")

    # carburator put env SSH_KEY_ID "$id" \
    #     --service-provider "$PROVIDER_NAME"
# fi

# ... test other provisioners with else if [[  ]]...

carburator print terminal success "Hetzner project created."