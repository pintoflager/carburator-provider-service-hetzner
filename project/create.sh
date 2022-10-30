#!/bin/bash

# ATTENTION: Scripts run from carburator project's public root directory:
# echo "$PWD"

# ATTENTION: to check the environment variables uncomment:
# env

# REMEMBER: provider could be hard coded to 'hetzner' here, but carburator returns
# the name so might as well use it.

# REMEMBER: If service provider only supports one provisioner, it should be used
# instead of "$PROVISIONER_NAME" variable.

###
# Run the provisioner and hope it succeeds. Provisioner function has
# retries baked in (if enabled in provisioner.toml).
#
carburator provisioner request \
    create \
    project \
    --provider "$PROVIDER_NAME" \
    --provisioner "$PROVISIONER_NAME" || exit 1

# Following checks apply only hetzner output.
if [[ $PROVIDER_NAME != 'hetzner' ]]; then
    carburator fn paint red "What the hell did you do to find this error?"
    exit 1
fi

###
# Extract required values from provisioner output and save it to service provider.
#
if [[ $PROVISIONER_NAME == 'terraform' ]]; then
    # We know how terraform spits out it's response (json) and we even know the
    # format of data. Lets extract what's needed (ssh key name and ID)
    # Save project ssh key name / id to environment.
    output="$PROVISIONER_PROVIDER_PATH/project.json"

    name=$(jq -rc '.project.value.sshkey_name' "$output")
    id=$(jq -rc '.project.value.sshkey_id' "$output")
    
    # TODO: renamed var: PROJECT_SSH_KEY_NAME => SSH_KEY_NAME
    carburator put env SSH_KEY_NAME "$name" \
        --service-provider "$PROVIDER_NAME"

    # TODO: renamed var: PROJECT_SSH_KEY_ID => SSH_KEY_ID
    carburator put env SSH_KEY_ID "$id" \
        --service-provider "$PROVIDER_NAME"
fi

# ... test other provisioners with else if [[  ]]...