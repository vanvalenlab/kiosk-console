#!/bin/bash

code=$1

echo "$code" | gcloud auth login --no-launch-browser --quiet >/dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "Worked"
else
  echo "Failed"
fi
