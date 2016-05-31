#!/bin/bash

# Responsibilities:
# 1) Initialize a local git repo, if one does not already exist
# 2) Create a remote git repo, using the name of the current folder as default
# 3) Link the remote git repo to the local, if successful
function usage() {
    echo "Usage: $0 (-n [name]) | -h"
	echo "Name is optional and will default to the name of the current folder"
	echo "Additionally: requires the environment variable 'GITHUB_PUBLIC_REPO_TOKEN' to be set to a valid token with at least public_repo privileges"
}

function createGitHubRepo() {
	# Invoke github-new-repo and capture the sanitized repository name
	CREATION_RESULT=$(bash github-new-repo.sh -n $NAME)
	REPONAME=$(echo "$CREATION_RESULT" | grep "[SUCCESS]" | sed 's/.*: \(.*\)/\1/')
}

# Retrieve program parameters
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
	NAME=${PWD##*/}
fi

git init

echo "Initializing github repository $NAME"
createGitHubRepo

echo "Linking local repository to github $REPONAME"
git remote add github git@github.com:$REPONAME.git