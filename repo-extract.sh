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
    echo "Isolates a subdirectory from a repository and creates a new repository with a subdirectory content, with its history preserved."
    echo " "
    echo "  usage: repo-extract.sh <original-git-remote> <dir-to-isolate> <new-repo-name> [<new-remote-origin-location>]"
    echo " "
    echo "   if <new-remote-origin-location> is not specified, uses a temporary origin - this is a safe, non-destructive option for testing"
    echo " "
    echo "  note: provide an absolute path (or URL) for <original-git-remote> and <new-remote-origin-location> parameters"
    echo " "
else

    INITIAL_DIR=$PWD

    ORIG_GIT_REMOTE=$1
    DIR_TO_ISOLATE=$2
    NEW_REPO_NAME=$3


    echo "-- initialize temporary dir: $INITIAL_DIR/temp"
        TMP_DIR_NAME=$INITIAL_DIR/temp
        TMP_DIR_REPO=$TMP_DIR_NAME/orig-repo
        rm -r -f $TMP_DIR_NAME
    #avoid continuation if an error occurs during the deletion
    if [ -d $TMP_DIR_NAME ]; then
        return -1
    fi
    mkdir $TMP_DIR_NAME


    echo "-- clone original remote: $ORIG_GIT_REMOTE to temp"
    git clone $ORIG_GIT_REMOTE $TMP_DIR_REPO


    echo "-- isolate git dir: $DIR_TO_ISOLATE"
    cd $TMP_DIR_REPO
    #re-create the working copy
    git reset HEAD --hard
    git filter-branch --subdirectory-filter $DIR_TO_ISOLATE -- --all
    #clean
    git gc


    if [ -z "$4" ]; then
        NEW_REMOTE_ORIGIN=$TMP_DIR_NAME/origin
        git init --bare $NEW_REMOTE_ORIGIN
        echo "---- No remote origin specified. Using a temporary remote origin: $NEW_REMOTE_ORIGIN"
    else
        NEW_REMOTE_ORIGIN=$4
    fi

    echo "-- set to a new remote: $NEW_REMOTE_ORIGIN"
    cd $TMP_DIR_REPO
    git remote remove origin
    git remote add origin $NEW_REMOTE_ORIGIN
    git push origin --all


    cd $INITIAL_DIR

    echo "-- test clone from: $NEW_REMOTE_ORIGIN"
    NEW_REPO_CLONED=$TMP_DIR_NAME/$NEW_REPO_NAME
    git clone $NEW_REMOTE_ORIGIN $NEW_REPO_CLONED

    echo "-- New cloned repo is at: $NEW_REPO_CLONED"

fi
