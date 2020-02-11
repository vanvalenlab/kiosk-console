#!/bin/bash

while IFS= read -r result
do
  retries=3
  for ((i=0; i<retries; i++)); do
    VAR_NAME=$(echo $result | awk '{print $1}')
    VAR_REGION=$(echo $result | awk '{print $2}')
    gcloud compute disks delete $VAR_NAME --quiet --zone=$VAR_REGION
    [[ $? -eq 0 ]] && break
    echo "Something went wrong while deleting persistent disk ${VAR_NAME}. Retrying in 30 seconds."
    sleep 30
  done
  echo "Successfully deleted persistent disk ${VAR_NAME}."
done < <(gcloud compute disks list | grep $CLOUDSDK_CONTAINER_CLUSTER)
