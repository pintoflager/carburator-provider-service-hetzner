#!/usr/bin/env bash

# Provisioner defined with a parent command flag
provisioner="$PROVISIONER_NAME"

# ...Or take the first package provider has in it's packages list.
# with service / dns provider we know packages are provisioners.
if [[ -z $provisioner ]]; then
    provisioner="$PROVIDER_PACKAGES_0_NAME"
fi

###
# Service provider has information about the nodes we have to pass along to the
# provisioner.
#
provisioner_node="$PROJECT_PATH/provisioners/$provisioner/providers/$PROVIDER_NAME/node"
provider_node="$PROVIDER_PATH/node"

# We could process the nodes array here to the format the provisioner is expecting
# but better keep provider layer thin and let the provisioner do what it needs
# with the original data
if [[ -e $provider_node/.exec.env ]]; then
    carburator print terminal fyi \
        "Copying $PROVIDER_NAME .exec.env to $provisioner as .provider.exec.env..."
    cp -f "$provider_node/.exec.env" "$provisioner_node/.provider.exec.env"
fi

if [[ -e $provider_node/.exec.json ]]; then
    carburator print terminal fyi \
        "Copying $PROVIDER_NAME .exec.json to $provisioner as .provider.exec.json..."
    cp -f "$provider_node/.exec.json" "$provisioner_node/.provider.exec.json"
fi

if [[ -e $provider_node/.exec.yaml ]]; then
    carburator print terminal fyi \
        "Copying $PROVIDER_NAME .exec.yaml to $provisioner as .provider.exec.yaml..."
    cp -f "$provider_node/.exec.yaml" "$provisioner_node/.provider.exec.yaml"
fi

if [[ -e $provider_node/.exec.toml ]]; then
    carburator print terminal fyi \
        "Copying $PROVIDER_NAME .exec.toml to $provisioner as .provider.exec.toml..."
    cp -f "$provider_node/.exec.toml" "$provisioner_node/.provider.exec.toml"
fi

###
# Private networking
#
provisioner_net="$PROJECT_PATH/provisioners/$provisioner/providers/$PROVIDER_NAME/network"

# How many nodes are we dealing with
len=$(carburator get json nodes array --path "$provider_node/.exec.json" | wc -l)

# Hetzner has 3 network zones, europe and yankie east/west
declare -a eu_nodes; declare -a us_east_nodes; declare -a us_west_nodes;

for (( i=0; i<len; i++ )); do
    # Get boolean returns exit code for false.
    if ! carburator get json "nodes.$i.connectivity.private_net" boolean \
        --path "$provider_node/.exec.json" &> /dev/null
    then
        continue;
    fi

    name=$(carburator get json "nodes.$i.hostname" string \
        --path "$provider_node/.exec.json")

    location=$(carburator get json "nodes.$i.location.name" string \
        --path "$provider_node/.exec.json")

    if [[ $location == "ash" ]]; then us_east_nodes+=("$name")
    elif [[ $location == "hil" ]]; then us_west_nodes+=("$name")
    else eu_nodes+=("$name"); fi
done

# Network name is the same as the node group name
net_name=$(carburator get env NODE_GROUP_NAME --path "$provider_node/.exec.env")
range="10.10.0.0/24"

# Each net zone should be called individually and only if they hold nodes.
if [[ ${#eu_nodes[@]} -gt 0 ]]; then
    carburator put json network "{\
    name: \"$net_name-eu\",\
    range: \"$range\",\
    zone: eu-central,\
    type: cloud}" --path "$provisioner_net/.eu.nodes.json"

    IFS=\, eval 'node_csv="${eu_nodes[*]}"'
    
    # shellcheck disable=SC2154
    carburator put json nodes "[$node_csv]" \
        --path "$provisioner_net/.eu.nodes.json"

# Make sure files from previous iterations are not present.
else
    rm -f "$provisioner_net/.eu.nodes.json"
fi

if [[ ${#us_east_nodes[@]} -gt 0 ]]; then
    carburator put json network "{\
    name: \"$net_name-us\",\
    range: \"$range\",\
    zone: us-east,\
    type: cloud}" --path "$provisioner_net/.us.east.nodes.json"

    IFS=\, eval 'node_csv="${us_east_nodes[*]}"'
    carburator put json nodes "[$node_csv]" \
        --path "$provisioner_net/.us.east.nodes.json"
else
    rm -f "$provisioner_net/.us.east.nodes.json"
fi

if [[ ${#us_west_nodes[@]} -gt 0 ]]; then
    carburator put json network "{\
    name: \"$net_name-us\",\
    range: \"$range\",\
    zone: us-west,\
    type: cloud}" --path "$provisioner_net/.us.west.nodes.json"

    IFS=\, eval 'node_csv="${us_west_nodes[*]}"'
    carburator put json nodes "[$node_csv]" \
        --path "$provisioner_net/.us.west.nodes.json"
else
    rm -f "$provisioner_net/.us.west.nodes.json"
fi

# Invoke the provisioner
carburator-rule provisioner request \
    service-provider \
    destroy \
    network \
    --provider "$PROVIDER_NAME" \
    --provisioner "$provisioner" || exit 120

carburator-rule provisioner request \
    service-provider \
    destroy \
    node \
    --provider "$PROVIDER_NAME" \
    --provisioner "$provisioner" || exit 120

carburator print terminal success "Hetzner network(s) and node(s) destroyed."