#!/bin/bash

function help() {
    cat <<EOF
Usage: $(basename $0) GIT_REPOS_PARENT_DIR

Pull remote changes in every git repository found in the directory GIT_REPOS_PARENT_DIR
EOF
    exit 0
}

function pullChanges() {
    repoDir=$(realpath $1)
    cd "$repoDir"

    echo -e "\n\e[33m\e[1;4m* \e[39mPulling remote changes in git repository \e[33m$repoDir\e[0m\n"
    
    # see https://code.i-harness.com/es/q/14fd614
    # this subshell is a scope of try
    # try
    (
        set -e
        for remote in $(git branch -r | grep -v '\->'); do 
            git branch --track "${remote#origin/}" "$remote"
        done
        git fetch --all
        git pull --all
    )
    
    # and here we catch errors
    # catch
    [ $? -ne 0 ] && echo -e "\n\e[31mSomething went wrong :(\e[0m" >&2
    
    # finally
    cd - &>/dev/null
}

[ $# -ne 1 -o "$1" == '-h' ] && help

dir=$1

if [ ! -d "$dir" ]; then
    echo "$dir not found"
    exit -1

elif [ ! -r "$dir" ]; then
    echo "$dir has no read permissions"
    exit -1
fi

for d in $(find . -path "./*/.git"); do
    pullChanges "$d/.."
done

exit 0
