#!/bin/bash

# Do you have several projects in one Git repository?
# Do you want to isolate that project to separate repo, with their history preserved?
#
# This script creates a new Git repository from a subfolder of an original repository.
# A history of that new Git repository is preserved.
# The new Git repository is then pushed to the new origin, and a test-repository is cloned from that origin.
#
# Script uses a "./temp" temporary folder, can be deleted after the work.

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    #also update README.md
    echo " "
    echo "<<< repo-extract - Git project isolation tool >>>"
    echo "Extract a directory from git repository to a new repository, with directory history preserved."
    echo "  In detail: Isolates a subdirectory from a repository cloned from a remote, using filter-branch git command."
    echo "Creates a new repository with that subdirectory content at the root."
    echo "That new repository is then pushed to the destination remote."
    echo " "
    echo "  usage: repo-extract.sh <source-remote> <dir-to-isolate> <new-repo-name> [<destination-remote>]"
    echo " "
    echo "    if <destination-remote> is not specified, uses a local, temporary remote as a destination. This is a safe, non-destructive option for testing purposes."
    echo " "
    echo "  At the end, clones a temporary repository from the updated destination-remote, to see the fresh result."
    echo " "
    echo "  note: provide an absolute path (or URL) for <source-remote> and <destination-remote> parameters"
    echo "  note: if <destination-remote> is specified, that destination-remote must already exists"
    echo " "
    echo " "
    echo "  example: repo-extract.sh \"https://github.com/user/all-project\" project1 project-1 \"https://github.com/user/project-1\""
    echo " "
else

    INITIAL_DIR=$PWD

    SOURCE_REMOTE=$1
    DIR_TO_ISOLATE=$2
    NEW_REPO_NAME=$3


    TMP_DIR_NAME=$INITIAL_DIR/temp
    echo "-- initialize temporary dir: $TMP_DIR_NAME"
    rm -r -f $TMP_DIR_NAME
    #avoid continuation if an error occurs during the deletion
    if [ -d $TMP_DIR_NAME ]; then
        return -1
    fi
    mkdir $TMP_DIR_NAME

    TMP_DIR_REPO=$TMP_DIR_NAME/source-repo-copy
    echo "-- clone source remote: $SOURCE_REMOTE to $TMP_DIR_REPO"
    git clone $SOURCE_REMOTE $TMP_DIR_REPO


    cd $TMP_DIR_REPO
    #re-create the working copy
    git reset HEAD --hard
    if [ $DIR_TO_ISOLATE != "." ]; then
        echo "-- isolate a directory: $DIR_TO_ISOLATE from $TMP_DIR_REPO"
        git filter-branch --subdirectory-filter $DIR_TO_ISOLATE -- --all
    else
        echo "-- reset: $TMP_DIR_REPO"
    fi
    #clean
    git gc


    if [ -z "$4" ]; then
        DESTINATION_REMOTE=$TMP_DIR_NAME/destination-remote
        echo "---- No destination remote specified. Using a temporary destination remote: $DESTINATION_REMOTE"
        git init --bare $DESTINATION_REMOTE
    else
        DESTINATION_REMOTE=$4
    fi

    echo "-- set a new remote: $DESTINATION_REMOTE on $TMP_DIR_REPO"
    cd $TMP_DIR_REPO
    git remote remove origin
    git remote add origin $DESTINATION_REMOTE
    git push origin --all


    cd $INITIAL_DIR

    echo "-- clone from: $DESTINATION_REMOTE"
    NEW_REPO_CLONED=$TMP_DIR_NAME/$NEW_REPO_NAME
    git clone $DESTINATION_REMOTE $NEW_REPO_CLONED
    echo "-- newly cloned repo for preview is at: $NEW_REPO_CLONED"

fi
