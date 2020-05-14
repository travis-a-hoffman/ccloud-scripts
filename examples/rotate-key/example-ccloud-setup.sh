#!/usr/bin/env bash

SECRETSFOLDER=.ccloud

if [[ ! "$CLUSTERID" ]]; then echo "Cluster ID required."; exit 0; fi
if [[ ! "$SERVICEACCTID" ]]; then echo "Service Account ID required."; exit 0; fi

# Create an example cluster
CLUSTERNAME=lululemon-key-rotation-example
if [[ "$1" ]]; then CLUSTERNAME=$1; fi
CLUSTERJSON=$(printf "{\n"; (ccloud kafka cluster create $CLUSTERNAME --cloud aws --region us-west-2 | grep "^|" | awk -F "|" '{print $2, $3}' | awk -F " " '{printf "  \"%s\": \"%s\",\n", $1, $2}' | sed '$ s/.$//'); printf "}\n")
printf "CLUSTERJSON:\n%s\n" "$CLUSTERJSON"
CLUSTERID=$(echo $CLUSTERJSON | jq '.Id' )

if [[ ! "$CLUSTERID" ]]; then echo "Cluster ID not found."; exit 0; fi

#printf "$CLUSTERJSON\n"
printf "CLUSTERID=$CLUSTERID\n"
printf "CLUSTERNAME=$CLUSTERNAME\n"

# Create a test topic (resource)

ccloud kafka topic create "skus" --cluster $CLUSTERID
ccloud kafka topic create "vendors" --cluster $CLUSTERID
ccloud kafka --cluster $CLUSTERID topic list -o json

# Create a service account
SERVICEACCTJSON=$(ccloud service-account create "Rolling-Key-Test-Account-1" --description "rolling key example test account" -o json)
#ccloud service-account create "Rolling-Key-Test-Account-2" --description "rolling key example test account"
#ccloud service-account create "Rolling-Key-Test-Account-3" --description "rolling key example test account"

# Use a sort function to get the same one every time.
SERVICEACCTID=$(echo $SERVICEACCTJSON | jq 'sort_by(.id) | .[0].id | tonumber')

ccloud service-account list -o json
ccloud kafka acl create --allow --operation READ --topic 'skus' --service-account 69189 --cluster lkc-xrp5q
# Create an ACL granting read access to the resource

# Add ACLs
ccloud kafka acl create --allow --service-account $SERVICEACCTID --operation READ --topic 'skus' --cluster $CLUSTERID
ccloud kafka acl create --allow --service-account $SERVICEACCTID --operation READ --topic 'vendors' --cluster $CLUSTERID

#ccloud kafka acl list --cluster lkc-xrp5q
ccloud kafka acl list --cluster $CLUSTERID -o json

# Create an (initial) API Key for the user
SECRETJSON=$(ccloud api-key create --service-account $SERVICEACCTID --resource $CLUSTERID --description "API Key Rotation Example – Key #1" -o json)
SECRETID=$(echo $SECRETJSON | jq '.key | tonumber')
echo "$SECRETJSON" > .$SECRETID-secret.json
ccloud api-key list -o json
