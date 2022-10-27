#!/bin/bash

# TODO: provider starts and prepares the environment for provisioner call and translates the response to
# format understandable by the carburator project.

local project="$1"; local pr_id="$2";
local project_json="$PWD/$pr_id/$project.json"

# Execute provisioner logic of the selected program.
local provisioner_sh; provisioner_sh=$(get-resource-provisioner)
"$provisioner_sh" provisioner-destroy-project "$project" "$pr_id"

