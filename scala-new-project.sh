#!/bin/bash

# Preconditions
if [ "$#" -lt 1 ]; then
    echo "Illegal number of parameters."
    usage
fi

# Constants
REMOTE="git@github.com:mboogerd/sbt-template.git"

# Functions
function usage() {
    echo "usage: $0 -p [projectName] [-b branchName] | -h | -l"
}

function listBranches() {
	echo "Retrieving branches"
	git ls-remote $REMOTE
}


# Retrieve program parameters
while [ "$1" != "" ]; do
    case $1 in
	-p | --project-name )
        shift
	    PROJECT=$1
        shift
	    ;;
	-b | --branch-name )
        shift
	    BRANCH=$1
        shift
	    ;;
	-g | --create-github-repo )
        shift
	    CREATE_GITHUB_REPO=true
	    ;;
	-h | --help )
	    shift
        usage
	    exit
	    ;;
	-l | --list-branches )
	    shift
        listBranches
	    exit
	    ;;
    *)
        OTHER_PARAMS="$OTHER_PARAMS $1"
        shift
        ;;
    esac
done

if [ "x$BRANCH" = "x" ]; then
	BRANCH="master"
fi

if [ "x$PROJECT" = "x" ]; then
	usage
	exit 1
fi

# Clone the template and give it the project name (but only if the project name is not a used directory)
if [ -d "$PROJECT" ] && [ "$(ls -A $PROJECT)" ]; then
	echo "Cannot create project, directory is already in use"
else
	echo "Cloning the template into the current folder"
	git clone -b $BRANCH $REMOTE $PROJECT

	# re-create the git repo
	cd $PROJECT
	# First clear out the git data of the sbt-template repository
	rm -rf .git
	
	if [ "$CREATE_GITHUB_REPO" = true ]; then
		bash github-init.sh -n $PROJECT
	else
		echo "Creating new local git repository"
		git init
	fi
	
	echo "Creating your initial commit"
	printf "# $PROJECT\nWrite me!" > README.md
	git add .
	git commit -am "Initial commit of project template"
	
	echo "Checking whether any of your dependencies can be updated"
	sbt dependencyUpdates
fi
