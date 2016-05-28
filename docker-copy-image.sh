#!/bin/bash

IMAGE=$1
FROM_MACHINE=$2
TO_MACHINE=$3

# Assert that the proper parameters are set
if [ -z "$IMAGE" ] || [ -z "$FROM_MACHINE" ] || [ -z "$TO_MACHINE" ]; then
	echo "usage: $0 [IMAGE] [MACHINE FROM] [MACHINE TO]"
	echo ""
	exit 1
fi

# Assert docker machine hosts exist
docker-machine config $FROM_MACHINE >/dev/null 2>&1 || { echo "Failed to retrieve config for $FROM_MACHINE" ; exit 2; }
docker-machine config $TO_MACHINE >/dev/null 2>&1 || { echo "Failed to retrieve config for $TO_MACHINE" ; exit 3; }

# Pipe image from one machine to the other
docker $(docker-machine config $FROM_MACHINE) save $IMAGE | docker $(docker-machine config $TO_MACHINE) load