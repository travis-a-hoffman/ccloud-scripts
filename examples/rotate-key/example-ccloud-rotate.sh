#!/usr/bin/env bash

# Needs:
# CLUSTERID=lkc-a3cr1
# SERVICEACCTID=63541

SECRETSFOLDER=.ccloud
CURRENTSECRETID=
NEXTSECRETID=

if [[ ! "$CLUSTERID" ]]; then echo "Cluster ID required."; exit 0; fi
if [[ ! "$SERVICEACCTID" ]]; then echo "Service Account ID required."; exit 0; fi

# Create new API Key
NEXTSECRETJSON=$(ccloud api-key create --service-account $SERVICEACCTID --resource $CLUSTERID --description "API Key Rotation Example – Key #2" -o json)
NEXTSECRETID=$(echo $NEXTSECRETJSON | jq '.key | tonumber')

echo "$NEXTSECRETJSON" > .$NEXTSECRETID-secret.json
#cat .$OLDSECRETID-secret.json
#cat .$NEWSECRETID-secret.json

# New API Key is now deployed and active.
# (Out-Of-Band) Distribute New API Keys to your team(s)
#echo "Distribute key to your teams. Best practice is to use a Secrets Manager. See:"
#echo "* https://aws.amazon.com/secrets-manager/"
#echo "* https://cloud.google.com/secret-manager"
#echo "* https://azure.microsoft.com/en-us/services/key-vault/"

# (Out-Of-Band) Deploy New API in application(s)
#echo "Now, go distribute the new key to the application teams. They should deploy the new key and delete the old key from the key manager".
# TODO Create examples of distributing to AWS, Azure, and GCP

# Remove old API Key
ccloud api-key delete $OLDSECRETID
rm $SECRETSFOLDER/$OLDSECRETID-secret.json
#ccloud api-key list -o json

echo "Old key $OLDSECRETID has been deleted."
# Now, we have rotated out the key.


