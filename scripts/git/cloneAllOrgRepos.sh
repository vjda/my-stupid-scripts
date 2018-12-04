#!/bin/bash

function help() {
    cat <<EOF
Usage: $(basename $0)

Clone all remote repositories from a GitHub's organization
EOF
    exit 0
}

function errorAndExist() {
    echo $1 >&2
    exit 1
}

function echoInBlue() {
    echo -en "\e[33m$1\e[33m\e[0m"
}

[ $# -ne 0 ] && help

read -p "GitHub user: " user
read -s -p "GitHub pass / api secret: " passOrToken

CURL_CMD="curl -s --user \"$user:$passOrToken\" -X GET"

# List user organizations
echoInBlue "\n\nOrganizations for user $user:\n"
eval $CURL_CMD "https://api.github.com/user/orgs" | jq '.[].login' | tr -d '"' || errorAndExist "Could not get the organizations for the user $user"
echo 

read -p "Type the GitHub's organization name: " org

echoInBlue "\nList of repositories in $org:\n"
eval $CURL_CMD "https://api.github.com/orgs/$org/repos" | jq '.[].name' | tr -d '"' | sort
echo

choice=''

while [[ $(echo "$choice" | egrep -c "[yY](es|)|[Nn](o|)") -ne 1 ]]; do
    read -p "Do you want to clone all of them in $(pwd)? [y/n]: " choice
done

if [[ $(echo "$choice" | egrep -c "[Yy](es|)") -eq 1 ]]; then
    
    for url in $(eval $CURL_CMD "https://api.github.com/orgs/$org/repos" | jq '.[].ssh_url' | tr -d '"'); do
        echo -e "\n\e[1;4m* \e[39mCloning git repository \e[33m$url\e[33m\e[0m\n"
        git clone "$url"
    done
    
    echoInBlue "\nALL DONE! :)\n"
fi

exit 0