#!/bin/bash

# Vars
export myDate=`date +"%m.%d.%y"`
export myBranch=`git branch | awk '{printf $2}'`

# Repo specific items
export imgName="$USER/openvpn-ca.alpine.amd64:$USER-$myBranch-$myDate"
export dfile="avesha_openvpn_ca.dockerfile"

# Ensure working directory is the main checkout dir
if [ ! -f $dfile ]; then
   echo "Working Directory must be checkout dir"
   exit 1
fi

# Build the docker image
echo "Building Image..."
docker build -t "$imgName" -f "$dfile" .
