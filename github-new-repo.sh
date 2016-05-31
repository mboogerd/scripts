#!/bin/bash

# Method definitions
function usage() {
    echo "Usage: $0 -n [name] | -h"
	echo "Additionally: requires the environment variable 'GITHUB_PUBLIC_REPO_TOKEN' to be set to a valid token with at least public_repo privileges"
}

function createGitHubRepo() {
	RESULT=`curl -sL -w "%{http_code}\\n" -H "Authorization: token $GITHUB_PUBLIC_REPO_TOKEN" https://api.github.com/user/repos -d "{\"name\":\"$NAME\"}"`
	RESULTCODE=$(echo "$RESULT" | tail -n 1)
	BODY=$(echo "$RESULT" | sed \$d)
	if [ "$RESULTCODE" -lt "400" ];then
		REPONAME=$(echo "$RESULT" | grep full_name | sed 's/.*: "\(.*\)",/\1/')
		echo "[SUCCESS] Github repository created successfully with name: $REPONAME"
	else
		echo "[FAILURE] Github repo creation failed with error code: $RESULTCODE; and response body:"
		echo "$BODY"
		exit 100
	fi
}

# Preconditions for running the script
if [ "$#" -lt 1 ]; then
    echo "Illegal number of parameters."
    usage
	exit 1
fi

[ -z "$GITHUB_PUBLIC_REPO_TOKEN" ] && echo "Need to set GITHUB_PUBLIC_REPO_TOKEN environment variable in order to create a github repo" && exit 2;

# TODO: Addtional checks:
# - Check whether repository exists already (be idempotent)

# Acquire supplied arguments
while [ "$1" != "" ]; do
    case $1 in
	-n | --name )
        shift
	    NAME=$1
        shift
	    ;;
	-h | --help )
	    shift
        usage
	    exit
	    ;;
    *)
        OTHER_PARAMS="$OTHER_PARAMS $1"
        shift
        ;;
    esac
done

if [ "x$NAME" = "x" ]; then
	usage
	exit 10
fi

# Execute github repo creation
createGitHubRepo