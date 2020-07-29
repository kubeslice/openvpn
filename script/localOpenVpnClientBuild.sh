#!/bin/bash

# Vars
export myDate=`date +"%m.%d.%y"`
export myBranch=`git branch | awk '{printf $2}'`

# Validate param is amd64 or arm32v7
if [[ "$1" != "amd64" && "$1" != "arm32v7" ]]; then
    echo "Usage:  ./script/localOpenVpnCLientBuild.sh arch"
    echo "    arch - [ amd64 | arm32v7 ]"
    exit 1
fi

# Repo specific items
export imgName="$USER/openvpn-client.alpine.$1:$USER-$myBranch-$myDate"
export dfile="avesha_openvpn_client.dockerfile"

# Validate that either amd64 or arm32v7 are provided as a param.

# Ensure working directory is the main checkout dir
if [ ! -f $dfile ]; then
   echo "Working Directory must be checkout dir"
   exit 1
fi

# Build the docker image
echo "Building Image..."
docker build --build-arg PLATFORM=$1 -t "$imgName" -f "$dfile" .
