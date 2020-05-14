#!/usr/bin/env bash

# Needs:
# CLUSTERID=lkc-a3cr1
# SERVICEACCTID=63541
CURRENTSECRETID=
SECRETSFOLDER=.ccloud

if [[ ! "$CLUSTERID" ]]; then echo "Cluster ID required."; exit 0; fi
if [[ ! "$SERVICEACCTID" ]]; then echo "Service Account ID required."; exit 0; fi

# Cleanup everything
ccloud api-key delete $SECRETID
rm $SECRETSFOLDER/$SECRETID-secret.json
ccloud kafka cluster delete $CLUSTERID
# Shouldn't have to do this step,
#ccloud kafka acl delete "skus" --cluster $CLUSTERID
#ccloud kafka topic delete "skus" --cluster $CLUSTERID
#ccloud kafka topic delete "vendors" --cluster $CLUSTERID


