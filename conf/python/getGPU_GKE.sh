#!/bin/bash

#Takes in user chosen region
GKE_COMPUTE_REGION=$1

#Returns all the GPUs allowed from that region
function main(){
  gpus_in_region=$(gcloud compute accelerator-types list | grep ${GKE_COMPUTE_REGION} | awk '{print $1}' | sort -u | awk '{print $1 " _ OFF"}')
  gpus_with_default=${gpus_in_region/nvidia-tesla-v100 _ OFF/nvidia-tesla-v100 _ ON}
  echo $gpus_with_default
}

main
