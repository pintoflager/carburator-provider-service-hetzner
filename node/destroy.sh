#!/usr/bin/env bash


local app="$1" servers="$2" provisioner_sh;
local servinst_dir="$PWD/$app/server_instances"

if [[ ! -d $servinst_dir || ! $(ls -A "$servinst_dir") ]]; then return; fi

# Execute provisioner logic of the selected program.
provisioner_sh=$(get-resource-provisioner "$app")
"$provisioner_sh" provisioner-destroy-servers "$app" "$servers"

