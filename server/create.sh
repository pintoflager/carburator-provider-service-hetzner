#!/bin/bash

local app="$1" servers_json="$PWD/$1/server.json";
local servinst_dir="$PWD/$app/server_instances"

if [[ ! -d $servinst_dir || ! $(ls -A "$servinst_dir") ]]; then return; fi

# Execute provisioner logic of the selected program.
local provisioner_sh; provisioner_sh=$(get-resource-provisioner "$app")
"$provisioner_sh" provisioner-servers "$app" "$domain"

provider-response-valid "$servers_json" || provision-server "$@"

