#!/bin/sh

mkdir $HOME/secrets
output_file=$HOME/secrets/gke_service_account_key.json
echo "$GKE_KEY_BASE64" > "$output_file"
