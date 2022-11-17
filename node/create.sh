#!/usr/bin/env bash

# TODO: also possible to loop project/nodes dir files instead of fucking around
# with ENV_VARS

# TODO: produce a list of all nodes in a format that the selected provisioner
# knows how to read.

# TODO: filter and take whats needed from provisioner response and return success

local app="$1" servers_json="$PWD/$1/server.json";
local servinst_dir="$PWD/$app/server_instances"

if [[ ! -d $servinst_dir || ! $(ls -A "$servinst_dir") ]]; then return; fi

# Execute provisioner logic of the selected program.
local provisioner_sh; provisioner_sh=$(get-resource-provisioner "$app")
"$provisioner_sh" provisioner-servers "$app" "$domain"

provider-response-valid "$servers_json" || provision-server "$@"

