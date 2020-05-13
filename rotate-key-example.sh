#!/usr/bin/env bash

# Create an example cluster
CLUSTERNAME=lululemon-key-rotation-test
if [[ "$1" ]]; then CLUSTERNAME=$1; fi
CLUSTERJSON=$(printf "{\n"; (ccloud kafka cluster create $CLUSTERNAME --cloud aws --region us-west-2 | grep "^|" | awk -F "|" '{print $2, $3}' | awk -F " " '{printf "  \"%s\": \"%s\",\n", $1, $2}' | sed '$ s/.$//'); printf "}\n")
CLUSTERID=$(echo $CLUSTERJSON | jq .Id)

#printf "$CLUSTERJSON\n"
printf "CLUSTERID=$CLUSTERID\n"
printf "CLUSTERNAME=$CLUSTERNAME\n"

# Create a test topic (resource)

ccloud kafka topic create "skus" --cluster $CLUSTERID
ccloud kafka topic create "vendors" --cluster $CLUSTERID
ccloud kafka --cluster $CLUSTERID topic list -o json

# Create a service account
ccloud service-account create "Rolling-Key-Test-Account-1" --description "rolling key example test account"
#ccloud service-account create "Rolling-Key-Test-Account-2" --description "rolling key example test account"
#ccloud service-account create "Rolling-Key-Test-Account-3" --description "rolling key example test account"

# Use a sort function to get the same one every time.
SERVICEACCTID=$(ccloud service-account list -o json | jq 'sort_by(.id) | .[0].id | tonumber')

ccloud service-account list -o json
ccloud kafka acl create --allow --operation READ --topic 'skus' --service-account 69189 --cluster lkc-xrp5q
# Create an ACL granting read access to the resource

# SERVICEACCTID=69189
# CLUSTERID=lkc-xrp5q
ccloud kafka acl create --allow --service-account $SERVICEACCTID --operation READ --topic 'skus' --cluster $CLUSTERID
ccloud kafka acl create --allow --service-account $SERVICEACCTID --operation READ --topic 'vendors' --cluster $CLUSTERID

#ccloud kafka acl list --cluster lkc-xrp5q
ccloud kafka acl list --cluster $CLUSTERID -o json

# Create an (initial) API Key for the user
SECRETJSON=$(ccloud api-key create --service-account $SERVICEACCTID --resource $CLUSTERID --description "API Key Rotation Example – Key #1" -o json)
SECRETID=$(echo $SECRETJSON | jq '.key | tonumber')
echo "$SECRETJSON" > .$SECRETID-secret.json
ccloud api-key list -o json

# SETUP COMPLETE! We've created an account, topics, and a service account with access limited to read-only access to two topics.
# All of the above steps can be skipped for existing setups.

#
# Rotation
#
# Save the old key info:
OLDSECRETJSON=$SECRETJSON
OLDSECRETID=$SECRETID

# Create new API Key
SECRETJSON=$(ccloud api-key create --service-account $SERVICEACCTID --resource $CLUSTERID --description "API Key Rotation Example – Key #2" -o json)
SECRETID=$(echo $SECRETJSON | jq '.key | tonumber')

echo "$SECRETJSON" > .$SECRETID-secret.json
ccloud api-key list -o json

cat .$OLDSECRETID-secret.json
cat .$SECRETID-secret.json

# New API Key is now deployed and active.
# (Out-Of-Band) Distribute New API Keys to team
# (Out-Of-Band) Deploy New API in application(s)
echo "Now, go distribute the new key to the application teams. They should deploy the new key and delete the old key from their applications".

# Remove old API Key
ccloud api-key delete $OLDSECRETID
rm ./$OLDSECRETID-secret.json
ccloud api-key list -o json

# Now, we have rotated out the key.