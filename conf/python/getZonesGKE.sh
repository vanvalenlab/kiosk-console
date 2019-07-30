#!/bin/bash

#Takes in user chosen prediction GPU
PREDICTION_GPU_TYPE=$1

#Takes in user chosen training GPU
TRAINING_GPU_TYPE=$2

#Takes in user chosen region
GKE_COMPUTE_REGION=$3

#goal is to get all regions within the large region that has those GPUs
function main(){
  local zones=$(gcloud compute zones list | grep "${GKE_COMPUTE_REGION}" | grep "UP" | awk '{print $1 " _ OFF"}')
  local all_region_zones=$(echo $zones | grep -o '\b\w\+-\w\+-\w\+\b')
  local region_zone_array=($all_region_zones)
  local zones_with_prediction_gpus=$(gcloud compute accelerator-types list | grep "${PREDICTION_GPU_TYPE}" | awk '{print $2}')
  local region_zones_gpu=()
  for i in "${region_zone_array[@]}"
  do
      if [[ $zones_with_prediction_gpus == *${i}* ]]; then
          region_zones_gpu+=(${i})
      fi
  done
  local zones_with_training_gpus=$(gcloud compute accelerator-types list | grep "${TRAINING_GPU_TYPE}" | awk '{print $2}')
  local region_zones_all_gpus=()
  for i in "${region_zones_gpu[@]}"
  do
      if [[ $zones_with_prediction_gpus == *${i}* ]]; then
          region_zones_all_gpus+=(${i})
      fi
  done
  REGION_ZONES_WITH_GPUS=$(IFS=','; echo "${region_zones_all_gpus[*]}"; IFS=$' \t\n')
  echo $REGION_ZONES_WITH_GPUS
}

main
