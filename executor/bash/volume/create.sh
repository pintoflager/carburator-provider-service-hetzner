#!/usr/bin/env bash

# local app="$1" vol_json="$PWD/$1/volume.json" provisioner_sh;
# local volinst_dir="$PWD/$app/volume_instances"

# if [[ ! -d $volinst_dir || ! $(ls -A "$volinst_dir") ]]; then return; fi

# # Execute provisioner logic of the selected program.
# provisioner_sh=$(get-resource-provisioner "$app")
# "$provisioner_sh" provisioner-volumes "$app"

# provider-response-valid "$vol_json" || provision-volume "$@"

