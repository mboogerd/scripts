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
    exit 0
}

function listBranches() {
	echo "Retrieving branches"
	git ls-remote $REMOTE
}

function createGitHubRepo() {
	RESULT=`curl -sL -w "%{http_code}\\n" -H "Authorization: token $GITHUB_PUBLIC_REPO_TOKEN" https://api.github.com/user/repos -d "{\"name\":\"$PROJECT\"}" -o /dev/null`
	if [ "$RESULT" -lt "400" ];then
		echo "Github repo created successfully"
	else
		echo "Github repo creation failed with error code: $RESULT!"
		exit 3
	fi
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

# preconditions for github repo creation
if [ "$CREATE_GITHUB_REPO" = true ]; then
	[ -z "$GITHUB_PUBLIC_REPO_TOKEN" ] && echo "Need to set GITHUB_PUBLIC_REPO_TOKEN environment variable in order to create a github repo" && exit 1;
	[ -z "$GITHUB_USERNAME" ] && echo "Need to set GITHUB_USERNAME environment variable in order to create a github repo" && exit 1;
	# TODO: Addtional checks:
	# - Check whether repository exists already, and if so:
	# - Check whether repository has size 0
fi

# Clone the template and give it the project name (but only if the project name is not a used directory)
if [ -d "$PROJECT" ] && [ "$(ls -A $PROJECT)" ]; then
	echo "Cannot create project, directory is already in use"
else
	echo "Cloning the template into the current folder"
	git clone -b $BRANCH $REMOTE $PROJECT

	# re-create the git repo
	cd $PROJECT
	echo "Creating new git repository"
	rm -rf .git
	git init
	
	echo "Creating your initial commit"
	printf "# $PROJECT\nWrite me!" > README.md
	git add .
	git commit -am "Initial commit of project template"
	
	if [ "$CREATE_GITHUB_REPO" = true ]; then
		echo "Creating github repository"
		createGitHubRepo
		git remote add github git@github.com:$GITHUB_USERNAME/$PROJECT.git
		# git branch --set-upstream-to=github/master
	fi
	
	sbt dependencyUpdates
fi
