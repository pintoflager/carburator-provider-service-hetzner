#!/bin/bash

# ATTENTION: Scripts run from carburator project's public root directory.

# TODO: following env should be present
# PROVIDER_name = "hetzner"
# PROVIDER_default = true
# PROVIDER_SECRET_0 = hetzner_cloud_apikey
# PROVIDER_target = "production"
# PROVIDER_PATH = "/home/...."

# PROVISIONER_name = "terraform"
# PROVISIONER_bin = "\"terraform\""
# PROVISIONER_default = true
# PROVISIONER_retry_times = 3
# PROVISIONER_retry_interval = 10
# PROVISIONER_boot_wait = 20
# PROVISIONER_target = "production"
# PROVISIONER_PATH = "/home/...."

# TODO: peek if so... 
env


# Execute provisioner logic of the selected program.
provisioner_sh=$(get-resource-provisioner)


# TODO: simple way would be to just use $PROVISIONER_PATH to call the matching
# script... but this would be fixed to shell or lots of script searching logic
# would be duplicated all over the place.............

"$PROVISIONER_PATH/providers/$PROVIDER_NAME/project/create.sh"

# TODO: better way might be:
carburator provisioner request ${action//"create/destroy/update..."} \
    ${resource//"project/vip/volume..."} \
    --provider $PROVIDER_NAME \
    --provisioner "$PROVISIONER_NAME/..or fixed name/empty for default" \

# that function would search for the script and populate environment variables.
# retrying could also be baked in, as carburator has access to provisioner.toml
# and it's retry configs.

# based on provisioner exit code we should save what we need later to service
# provider/.env
# provisioner has to save it's output in some understandable format as well.
# then the logic here goes:

# if [[ $PROVISIONER_NAME == "hetzner" ]]; then
    # now we know what it has saved and where.
    # key=$(carburator fn get env PROJECT_SSH_KEY_NAME --path $PROVISIONER_HOME/.env)
    # carburator fn put env SSH_NAME "$key" --path $PROVIDER_HOME/.env ......

# else if [[ ... ]]


# THATS ALL PROVIDER SHOULD DO!! BE THE MIDDLEMAN BETWEEN THE PROVISIONERS
# AND THE PROJECT



"$provisioner_sh" provisioner-register-project "$project" "$pr_id"

provider-response-valid "$project_json" || register-project "$@"


# TODO: this stuff should never leave from provider
# Save project ssh key name / id to environment.
ssh_name=$(jq -rc '.ssh_key.value.name' "$project_json")
put-env PROJECT_SSH_KEY_NAME "$ssh_name" "$PWD/.env"

ssh_id=$(jq -rc '.ssh_key.value.id' "$project_json")
put-env PROJECT_SSH_KEY_ID "$ssh_id" "$PWD/.env"

