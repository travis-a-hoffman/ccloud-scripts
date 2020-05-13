#!/usr/bin/env bash

#List all clusters matching a pattern
printf "Clusters matching %s:\n" $1
ccloud kafka cluster list | grep "$1"

#Delete all clusters with names matching a pattern
printf "Preparing to delete clusters matching: %s\n" "$1"

CLUSTERLIST=$(ccloud kafka cluster list | grep "$1" | awk -F "|" '{ printf $1 }' | sed 's/ */ /')
DELETEPLAN=$(echo $CLUSTERLIST | sed 's/ */ /' | xargs -n 1 printf "ccloud kafka cluster delete %s\n" )
PLANCOUNT=$(echo $DELETEPLAN | wc -l | sed 's/ *//')
printf "Delete Plan:\n\n%s\n\n" "$DELETEPLAN"

read -p "Are you sure you want to delete $PLANCOUNT clusters? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # do dangerous stuff
    eval $DELETEPLAN
fi
