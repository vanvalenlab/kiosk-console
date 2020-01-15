#!/bin/bash

echo "Deleting all custom node pools..."
while IFS= read -r result
do
  retries=3
  for ((i=0; i<retries; i++)); do
    VAR_NAME=$(echo $result | awk '{print $1}')
    gcloud container node-pools delete $VAR_NAME --quiet --region=${GKE_COMPUTE_REGION} --cluster ${CLUSTER_NAME}
    [[ $? -eq 0 ]] && break
    echo "Something went wrong while deleting node-pool ${VAR_NAME}. Retrying in 30 seconds."
    sleep 30
  done
  echo "Successfully deleted node-pool ${VAR_NAME}"
done < <(gcloud container node-pools list --cluster ${CLUSTER_NAME} --region ${GKE_COMPUTE_REGION} --filter "NOT default-pool" | grep -v NAME)
