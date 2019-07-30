#!/usr/bin/env bash

# fetch a login URL
long_url=$(gcloud auth login --no-launch-browser </dev/null 2>&1 | grep https:// | tr -d ' ')
short_url=$(curl -sS "http://tinyurl.com/api-create.php?url=$long_url")
clear
echo "$long_url"
