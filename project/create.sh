#!/bin/bash

# ATTENTION: Scripts run from carburator project's public root directory.

# TODO: following env should be present
# PROVIDER_NAME = "hetzner"
# PROVIDER_DEFAULT = true
# PROVIDER_SECRET_0 = hetzner_cloud_apikey
# PROVIDER_TARGET = "production"
# PROVIDER_PATH = "/home/..../providers/service/{name}"

# PROVISIONER_NAME = "terraform"
# PROVISIONER_BIN = "\"terraform\""
# PROVISIONER_default = true
# PROVISIONER_retry_times = 3
# PROVISIONER_retry_interval = 10
# PROVISIONER_boot_wait = 20
# PROVISIONER_target = "production"
# PROVISIONER_PROVIDER_PATH = "/home/..../provisioners/{name}/providers{service_provider}"
# PROVISIONER_HOME = "/home/..../provisioners/{name}"

# TODO: peek if so... 
env

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

    # TODO: put env is fixed to app or fullpath. allow fast env path to providers.
    ssh_name=$(jq -rc '.ssh_key.value.name' "$output")
    put-env PROJECT_SSH_KEY_NAME "$ssh_name" "$PWD/.env"

    ssh_id=$(jq -rc '.ssh_key.value.id' "$output")
    put-env PROJECT_SSH_KEY_ID "$ssh_id" "$PWD/.env"
fi




"$provisioner_sh" provisioner-register-project "$project" "$pr_id"

provider-response-valid "$project_json" || register-project "$@"


# TODO: this stuff should never leave from provider


