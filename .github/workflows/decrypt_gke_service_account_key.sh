#!/bin/sh

# Decrypt the file
mkdir $HOME/secrets
# --batch to prevent interactive command --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$GKE_KEY_PASSPHRASE" \
--output $HOME/secrets/gke_service_account_key_base64.json ./.github/workflows/gke_service_account_key_base64.json.gpg
