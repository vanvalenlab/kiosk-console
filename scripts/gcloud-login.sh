#!/usr/bin/env bash

# fetch a login URL 
long_url=$(gcloud auth login --no-launch-browser </dev/null 2>&1 | grep https:// | tr -d ' ')
short_url=$(curl -sS "http://tinyurl.com/api-create.php?url=$long_url")
clear 
qrencode -t utf8 "$long_url"
echo "Please go here: $long_url"

echo -n "Enter code: "
read code

echo "$code" | gcloud auth login --no-launch-browser --quiet >/dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "Success!"
else
  echo "Login failed!"
  exit 1
fi
