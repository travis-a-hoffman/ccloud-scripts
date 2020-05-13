#!/usr/bin/env bash

# Create a cluster, printing output as json (not currently supported by ccloud)

# Usage: ccloud-kafka-cluster-create-o-json.sh <ccloud-options>

# Create the cluster
NEWCLUSTERJSON=$(printf "{\n"; (ccloud kafka cluster create $@ | grep "^|" | awk -F "|" '{print $2, $3}' | awk -F " " '{printf "  \"%s\": \"%s\",\n", $1, $2}' | sed '$ s/.$//'); printf "}\n")
printf "$NEWCLUSTERJSON\n"
