#!/usr/bin/env bash

clear

echo "Deploying a cluster on Google Cloud requires authorization."
echo ""

gcloud auth login --no-launch-browser --verbosity "error"

if [ $? -eq 0 ]; then
  echo "Success!"
else
  echo "Login failed!"
  exit 1
fi
