#!/usr/bin/env bash

export BRAND="Caltech Van Valen Lab"

#dialog --print-maxsize

#trap ctrl_c SIGINT

function ctrl_c() {
  killall dialog
  trap - SIGINT
}

function retval() {
  case $1 in
  ${DIALOG_OK-0}) return 0;;
  ${DIALOG_CANCEL-1}) echo "Cancel pressed."; exit 1;;
  ${DIALOG_ESC-255}) echo "Esc pressed."; exit 2;;
  ${DIALOG_ERROR-255}) echo "Dialog error"; exit 3;;
  *) echo "Unknown error $retval"; exit 4
  esac
}

function msgbox() {
  local title=$1
  local message=$2
  dialog --backtitle "$BRAND" --title "$title" --clear --msgbox "$message" 12 60
  retval $?
}

function inputbox() {
  local value
  local title=$1
  local label=$2
  local default=$3
  local h=${4:-8}
  local w=${5:-60}
  shift
  value=$(dialog --title "$title" \
            --backtitle "${BRAND}" \
            --output-fd 1 \
            --inputbox "$label" "$h" "$w" "$default")
  echo $value
}

function radiobox() {
  local value
  local title=$1
  local label=$2
  local h=${3:-8}
  local w=${4:-60}
  local menu_h=${5:-3}
  local text_fields=$6
  IFS=$'\n' read -r -a radio_array <<< "$text_fields"
  shift
  value=$(dialog --title "$title" \
            --backtitle "${BRAND}" \
            --output-fd 1 \
            --radiolist "$label" "$h" "$w" "$menu_h" $text_fields)
  echo $value
}

function infobox() {
  local message="$1"
  local h=${2:-3}
  local w=${3:-20}
  dialog --infobox "$message" $h $w
}

function tailcmd() {
  local title=$1
  local completed_message=${2:-">>> Done!\n"}
  local tmpfile=$(mktemp /tmp/setup.XXXXXX)
  shift
  shift
  :> $tmpfile
  (
    $* 2>&1
    echo
    echo "${completed_message}"
  ) > $tmpfile &

  dialog --clear \
         --begin 0 0 \
         --title "$title" \
         --backtitle "${BRAND}" \
         --begin 3 1 \
         --tailbox "${tmpfile}" $((LINES-5)) $((COLUMNS-3))
}

# Show different functions in the main menu depending on whether the
# cluster has been created yet.
function menu() {
  local value
  local header_text=(" Use the UP/DOWN arrow keys or the first\n"
                     "letter of the choice as a hot key to\n"
                     "select an option.\n"
                     "Choose a task.")

  declare -A cloud_providers
  cloud_providers[${CLOUD_PROVIDER:-none}]="(active)"
  if [ -z "${CLUSTER_ADDRESS}" ]; then
    value=$(dialog --clear  --help-button --backtitle "${BRAND}" \
              --title "[ M A I N - M E N U ]" \
              --menu "${header_text[*]}" 15 50 5 \
                  "Setup"   "Configure Google ${cloud_providers[gke]}" \
                  "Create"  "Create ${CLOUD_PROVIDER^^} Cluster" \
                  "Shell"   "Drop to the shell" \
                  "Exit"    "Exit this kiosk" \
              --output-fd 1 \
            )
  else
    value=$(dialog --clear  --help-button --backtitle "${BRAND}" \
              --title "[ M A I N - M E N U ]" \
              --menu "${header_text[*]}" 17 50 6 \
                  "Setup"   "Configure Google ${cloud_providers[gke]}" \
                  "Destroy" "Destroy ${CLOUD_PROVIDER^^} Cluster" \
                  "View"    "View Cluster Address" \
                  "Shell"   "Drop to the shell" \
                  "Exit"    "Exit this kiosk" \
              --output-fd 1 \
            )
  fi
  retval $?
  echo $value
}

function configure_aws() {
  if [ -z "${NAMESPACE}" ]; then
    # Generate a friendly human readable name
    export NAMESPACE="$(shuf -n 1 /etc/wordlist.txt)-$((1 + RANDOM % 100))"
  fi

  export AWS_ACCESS_KEY_ID=$(inputbox "Amazon Web Services" "Access Key ID" "${AWS_ACCESS_KEY_ID:-invalid_default}")
  if [ "$AWS_ACCESS_KEY_ID" = "" ]; then
    return 0
  fi
  export AWS_SECRET_ACCESS_KEY=$(inputbox "Amazon Web Services" "AWS Secret Key" "${AWS_SECRET_ACCESS_KEY:-invalid_default}")
  if [ "$AWS_SECRET_ACCESS_KEY" = "" ]; then
    return 0
  fi
  export AWS_S3_BUCKET=$(inputbox "Amazon Web Services" "AWS S3 Bucket Name" "${AWS_S3_BUCKET:-$RANDOM_DEFAULT}")
  if [ "$AWS_S3_BUCKET" = "" ]; then
    return 0
  fi
  export NAMESPACE=$(inputbox "Deepcell" "Cluster Name" "${NAMESPACE:-deepcell-aws-cluster}")
  export NAMESPACE=$(echo ${NAMESPACE} | awk '{print tolower($0)}' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/(^-+|-+$)//')
  if [ "$NAMESPACE" = "" ]; then
    return 0
  fi
  export MASTER_MACHINE_TYPE=$(inputbox "Amazon Web Services" "Master Node Machine Type" "${MASTER_MACHINE_TYPE:-m4.large}")
  if [ "$MASTER_MACHINE_TYPE" = "" ]; then
    return 0
  fi
  export NODE_MACHINE_TYPE=$(inputbox "Amazon Web Services" "Worker Nodes Machine Type" "${NODE_MACHINE_TYPE:-m4.large}")
  if [ "$NODE_MACHINE_TYPE" = "" ]; then
    return 0
  fi

  # let's just hardcode the menu, since all instance types are apparently available in all regions
  # and there's no built-in way to list type in the aws-cli
  local gpu_types="g3.xlarge 1GPU OFF
    g3.4xlarge 1GPU OFF
    g3.8xlarge 2GPUs OFF
    g3.16xlarge 4GPUs OFF
    p2.xlarge 1GPU ON
    p2.8xlarge 8GPUs OFF
    p2.16xlarge 16GPUs OFF
    p3.2xlarge 1GPU OFF
    p3.8xlarge 4GPUs OFF
    p3.16xlarge 8GPUs OFF"
  export AWS_GPU_MACHINE_TYPE=$(radiobox "Amazon Web Services" \
    "Choose your GPU Instance Type:" 15 60 7 "$gpu_types")

  export AWS_MIN_GPU_NODES=$(inputbox "Amazon Web Services" "Minimum Number of GPU Instances" "${AWS_MIN_GPU_NODES:-0}")
  if [ "$AWS_MIN_GPU_NODES" = "" ]; then
    return 0
  fi
  export AWS_MAX_GPU_NODES=$(inputbox "Amazon Web Services" "Maximum Number of GPU Instances" "${AWS_MAX_GPU_NODES:-4}")
  if [ "$AWS_MAX_GPU_NODES" = "" ]; then
    return 0
  fi

  # create some derivative GPU-related variables for use in autoscaling
  export GPU_MAX_TIMES_TWO=$(($AWS_MAX_GPU_NODES*2))
  export GPU_MAX_TIMES_THREE=$(($AWS_MAX_GPU_NODES*3))
  export GPU_MAX_TIMES_FOUR=$(($AWS_MAX_GPU_NODES*4))
  export GPU_MAX_TIMES_FIVE=$(($AWS_MAX_GPU_NODES*5))
  export GPU_MAX_TIMES_TEN=$(($AWS_MAX_GPU_NODES*10))
  export GPU_MAX_TIMES_TWENTY=$(($AWS_MAX_GPU_NODES*20))
  export GPU_MAX_TIMES_THIRTY=$(($AWS_MAX_GPU_NODES*30))
  export GPU_MAX_TIMES_FOURTY=$(($AWS_MAX_GPU_NODES*40))
  export GPU_MAX_TIMES_FIFTY=$(($AWS_MAX_GPU_NODES*50))
  export GPU_MAX_TIMES_SEVENTY_FIVE=$(($AWS_MAX_GPU_NODES*75))
  export GPU_MAX_TIMES_ONE_HUNDRED=$(($AWS_MAX_GPU_NODES*100))
  export GPU_MAX_TIMES_TWO_HUNDRED=$(($AWS_MAX_GPU_NODES*200))
  export GPU_MAX_DIVIDED_BY_TWO=$(($AWS_MAX_GPU_NODES/2))
  export GPU_MAX_DIVIDED_BY_THREE=$(($AWS_MAX_GPU_NODES/3))
  export GPU_MAX_DIVIDED_BY_FOUR=$(($AWS_MAX_GPU_NODES/4))
  export GPU_NODE_MAX_SIZE=${AWS_MAX_GPU_NODES}

  export KOPS_CLUSTER_NAME=${NAMESPACE}.k8s.local
  export KOPS_DNS_ZONE=${NAMESPACE}.k8s.local
  export KOPS_STATE_STORE=s3://${NAMESPACE}
  export CLOUD_PROVIDER=aws

  make create_cache_path
  printenv | grep -e CLOUD_PROVIDER > ${CACHE_PATH}/env
  printenv | grep -E GPU_NODE_MAX_SIZE \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_S3_BUCKET \
    -e NAMESPACE \
    -e AWS_MIN_GPU_NODES \
    -e AWS_MAX_GPU_NODES \
    -e GPU_MAX_TIMES_TWO \
    -e GPU_MAX_TIMES_THREE \
    -e GPU_MAX_TIMES_FOUR \
    -e GPU_MAX_TIMES_FIVE \
    -e GPU_MAX_TIMES_TEN \
    -e GPU_MAX_TIMES_TWENTY \
    -e GPU_MAX_TIMES_THIRTY \
    -e GPU_MAX_TIMES_FOURTY \
    -e GPU_MAX_TIMES_FIFTY \
    -e GPU_MAX_TIMES_SEVENTY_FIVE \
    -e GPU_MAX_TIMES_ONE_HUNDRED \
    -e GPU_MAX_TIMES_TWO_HUNDRED \
    -e GPU_MAX_DIVIDED_BY_TWO \
    -e GPU_MAX_DIVIDED_BY_THREE \
    -e GPU_MAX_DIVIDED_BY_FOUR \
    -E GPU_NODE_MAX_SIZE > ${CACHE_PATH}/env.aws
}

function configure_gke() {

  local NEW_PROJECT=$(inputbox "Google Cloud" "Existing Project ID" "${PROJECT:-invalid_default}")
  if [ -z $NEW_PROJECT ]; then
    return 0
  fi
  export PROJECT="${NEW_PROJECT}"

  make gke/login
  gcloud config set project ${PROJECT} --quiet

  if [ -z ${CLUSTER_NAME} ]; then
    export CLUSTER_NAME="deepcell-$(shuf -n 1 /etc/wordlist.txt)-$((1 + RANDOM % 100))"
  fi

  export CLUSTER_NAME=$(inputbox "Deepcell" "Cluster Name" "${CLUSTER_NAME:-deepcell-cluster}")
  export CLUSTER_NAME=$(echo ${CLUSTER_NAME} | awk '{print tolower($0)}' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/(^-+|-+$)//')
  if [ "$CLUSTER_NAME" = "" ]; then
    return 0
  fi
  local bucket_text=("Bucket Name"
                     "\n\nThe bucket should be a unique existing bucket on google cloud."
                     "It acts as a storage area for models, data, and more."
                     "Please do not use underscores (_) in your bucket name.")
  export GKE_BUCKET=$(inputbox "Deepcell" "${bucket_text[*]}" "${GKE_BUCKET:-$CLUSTER_NAME}" 13 60)

  if [ "$GKE_BUCKET" = "" ]; then
    return 0
  fi

  local setup_opt_value=$(dialog --clear  --help-button --backtitle "${BRAND}" \
              --title "  Configuration Options  " \
              --menu "${header_text[*]}" 10 70 3 \
                  "Default"     "Use default options to setup cluster" \
                  "Advanced"    "Specify custom cluster creation options" \
              --output-fd 1 \
            )

  if [ "$setup_opt_value" = "Default" ]; then
    # Default

    infobox "Loading default values..." 7 60

    export GCLOUD_REGION=us-west1
    export GKE_MACHINE_TYPE=n1-standard-1
    export NODE_MIN_SIZE=1
    export NODE_MAX_SIZE=10
    export PREDICTION_GPU_TYPE=nvidia-tesla-t4
    export TRAINING_GPU_TYPE=nvidia-tesla-v100

    export GPU_NODE_MIN_SIZE=0
    export GPU_NODE_MAX_SIZE=1

  else
    # Advanced
    infobox "Loading..."
    local regions=$(gcloud compute regions list | grep "-" | awk '{print $1 " _ OFF"}')
    local regions_with_default=${regions/us-west1 _ OFF/us-west1 _ ON}
    local base_box_height=7
    local selector_box_lines=$(echo "${regions}" | tr -cd '\n' | wc -c)
    local total_lines=$(($base_box_height + $selector_box_lines))
    export GCLOUD_REGION=$(radiobox "Google Cloud" \
        "Choose a region for hosting your cluster: \nPress the spacebar to select and Enter to continue." \
      $total_lines 60 $selector_box_lines "$regions_with_default")
    if [ "$GCLOUD_REGION" = "" ]; then
      return 0
    fi

    export GKE_MACHINE_TYPE=$(inputbox "Google Cloud" "Node (non-GPU) Type" "${GKE_MACHINE_TYPE:-n1-standard-1}")
    if [ "$GKE_MACHINE_TYPE" = "" ]; then
      return 0
    fi
    export NODE_MIN_SIZE=$(inputbox "Google Cloud" "Minimum Number of Compute (non-GPU) Nodes" "${NODE_MIN_SIZE:-1}")
    if [ "$NODE_MIN_SIZE" = "" ]; then
      return 0
    fi
    export NODE_MAX_SIZE=$(inputbox "Google Cloud" "Maximum Number of Compute (non-GPU) Nodes" "${NODE_MAX_SIZE:-11}")
    if [ "$NODE_MAX_SIZE" = "" ]; then
      return 0
    fi

    infobox "Loading..."
    local gpus_in_region=$(gcloud compute accelerator-types list | grep ${GCLOUD_REGION} | awk '{print $1}' | sort -u | awk '{print $1 " _ OFF"}')
    local gpus_with_default=${gpus_in_region/nvidia-tesla-t4 _ OFF/nvidia-tesla-t4 _ ON}
    local base_box_height=7
    local selector_box_lines=$(($(echo "${gpus_in_region}" | tr -cd '\n' | wc -c) + 1))
    local total_lines=$(($base_box_height + $selector_box_lines))
    export PREDICTION_GPU_TYPE=$(radiobox "Google Cloud" \
        "Choose a GPU for prediction (not training) from the GPU types available in your region: \nPress the spacebar to select and Enter to continue." \
      $total_lines 60 $selector_box_lines "$gpus_with_default")

    local gpus_with_default=${gpus_in_region/nvidia-tesla-v100 _ OFF/nvidia-tesla-v100 _ ON}
    export TRAINING_GPU_TYPE=$(radiobox "Google Cloud" \
        "Choose a GPU for training (not prediction) from the GPU types available in your region: \nPress the spacebar to select and Enter to continue." \
      $total_lines 60 $selector_box_lines "$gpus_with_default")

    ## Maybe include these in an advanced menu?
    # export GPU_PER_NODE=$(inputbox "Google Cloud" "GPUs per GPU Node" "${GPU_PER_NODE:-1}")
    # if [ "$GPU_PER_NODE" = "" ]; then
    #     return 0
    # fi
    # export GPU_MACHINE_TYPE=$(inputbox "Google Cloud" "GPU Node Type" "${GPU_MACHINE_TYPE:-n1-highmem-2}")
    # if [ "$GPU_MACHINE_TYPE" = "" ]; then
    #     return 0
    # fi
    export GPU_NODE_MIN_SIZE=$(inputbox "Google Cloud" "Minimum Number of GPU Nodes" "${GPU_NODE_MIN_SIZE:-0}")
    if [ "$GPU_NODE_MIN_SIZE" = "" ]; then
      return 0
    fi
    export GPU_NODE_MAX_SIZE=$(inputbox "Google Cloud" "Maximum Number of GPU Nodes" "${GPU_NODE_MAX_SIZE:-4}")
    if [ "$GPU_NODE_MAX_SIZE" = "" ]; then
      return 0
    fi
    infobox "Loading..."

  fi

  local zones=$(gcloud compute zones list | grep "${GCLOUD_REGION}" | grep "UP" | awk '{print $1 " _ OFF"}')
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
  export REGION_ZONES_WITH_GPUS=$(IFS=','; echo "${region_zones_all_gpus[*]}"; IFS=$' \t\n')

  local message=("The following are zones in your region with the specified GPU type(s):"
                 "\n\n    $REGION_ZONES_WITH_GPUS"
                 "\n\nIf you see either 0 or 1 zones listed above,"
                 "please reconfigure the cluster before deploying."
                 "Different choices of GPU(s) and/or region will be necessary.")
  msgbox "Caution!" "${message[*]}"

  local success_text=("Configuration Complete!"
                      "\n\nThe cluster is now available for creation.")
  dialog --msgbox "${success_text[*]}" 12 60

  export CLOUD_PROVIDER=gke

  # create some derivative GPU-related variables for use in autoscaling
  export GPU_MAX_TIMES_TWO=$(($GPU_NODE_MAX_SIZE*2))
  export GPU_MAX_TIMES_THREE=$(($GPU_NODE_MAX_SIZE*3))
  export GPU_MAX_TIMES_FOUR=$(($GPU_NODE_MAX_SIZE*4))
  export GPU_MAX_TIMES_FIVE=$(($GPU_NODE_MAX_SIZE*5))
  export GPU_MAX_TIMES_TEN=$(($GPU_NODE_MAX_SIZE*10))
  export GPU_MAX_TIMES_TWENTY=$(($GPU_NODE_MAX_SIZE*20))
  export GPU_MAX_TIMES_THIRTY=$(($GPU_NODE_MAX_SIZE*30))
  export GPU_MAX_TIMES_FOURTY=$(($GPU_NODE_MAX_SIZE*40))
  export GPU_MAX_TIMES_FIFTY=$(($GPU_NODE_MAX_SIZE*50))
  export GPU_MAX_TIMES_SEVENTY_FIVE=$(($GPU_NODE_MAX_SIZE*75))
  export GPU_MAX_TIMES_ONE_HUNDRED=$(($GPU_NODE_MAX_SIZE*100))
  export GPU_MAX_TIMES_ONE_HUNDRED_FIFTY=$(($GPU_NODE_MAX_SIZE*150))
  export GPU_MAX_TIMES_TWO_HUNDRED=$(($GPU_NODE_MAX_SIZE*200))
  export GPU_MAX_DIVIDED_BY_TWO=$(($GPU_NODE_MAX_SIZE/2))
  export GPU_MAX_DIVIDED_BY_THREE=$(($GPU_NODE_MAX_SIZE/3))
  export GPU_MAX_DIVIDED_BY_FOUR=$(($GPU_NODE_MAX_SIZE/4))

  make create_cache_path
  printenv | grep -e CLOUD_PROVIDER > ${CACHE_PATH}/env
  printenv | grep -e PROJECT \
    -e CLUSTER_NAME \
    -e GKE_BUCKET \
    -e NODE_MIN_SIZE \
    -e NODE_MAX_SIZE \
    -e GCLOUD_REGION \
    -e GKE_MACHINE_TYPE \
    -e PREDICTION_GPU_TYPE \
    -e TRAINING_GPU_TYPE \
    -e GPU_PER_NODE \
    -e GPU_MACHINE_TYPE \
    -e GPU_NODE_MIN_SIZE \
    -e GPU_NODE_MAX_SIZE \
    -e GPU_MAX_TIMES_TWO \
    -e GPU_MAX_TIMES_THREE \
    -e GPU_MAX_TIMES_FOUR \
    -e GPU_MAX_TIMES_FIVE \
    -e GPU_MAX_TIMES_TEN \
    -e GPU_MAX_TIMES_TWENTY \
    -e GPU_MAX_TIMES_THIRTY \
    -e GPU_MAX_TIMES_FOURTY \
    -e GPU_MAX_TIMES_FIFTY \
    -e GPU_MAX_TIMES_SEVENTY_FIVE \
    -e GPU_MAX_TIMES_ONE_HUNDRED \
    -e GPU_MAX_TIMES_TWO_HUNDRED \
    -e GPU_MAX_DIVIDED_BY_TWO \
    -e GPU_MAX_DIVIDED_BY_THREE \
    -e GPU_MAX_DIVIDED_BY_FOUR > ${CACHE_PATH}/env.gke
}

function shell() {
  clear
  echo "Type 'exit' to return to the menu."
  bash -l
}

function create() {
  #todo: check if status is active and if not echo that fact and request config
  tailcmd "Create Cluster" "---COMPLETE---" make create
  export CLUSTER_ADDRESS=$(sed -E 's/^export CLUSTER_ADDRESS=(.+)$/\1/' ./cluster_address)
}

function destroy() {
  tailcmd "Destroy Cluster" "---COMPLETE--" make destroy
  export CLUSTER_ADDRESS=""
}

function view() {
  local title="Deepcell Cluster Address"
  if [ -f ./cluster_address ]; then
    local cluster_address=$(cat ./cluster_address | sed 's/export CLUSTER_ADDRESS=\([[:graph:]]\+\)/\1/')
  else
    local cluster_address="No current address -- no cluster has been started yet."
  fi
  clear
  echo "The cluster's address is: " ${cluster_address}
  read -p "Press enter to return to main menu"
}

function confirm() {

  dialog --yesno "Are you sure?" 7 60
  response=$?
  case $response in
    0) return 0;;
    1) return 1;;
    255) return 1;;
  esac
}

function main() {
  export MENU=true
  # The following line is a workaround for a bug where the first dialog call
  # after startup fails before user input is possible.
  dialog --sleep 1 --msgbox "Loading..." 12 60
  #infobox "Loading..."

  local welcome_text=("Welcome to the Deepcell Kiosk!"
                      "\n\nThis Kiosk was developed by the Van Valen Lab at"
                      "the California Institute of Technology."
                      "\n\nhttps://vanvalenlab.caltech.edu")
  msgbox "Welcome!" "${welcome_text[*]}"

  while true; do
    ACTION=$(menu)
    if [ $? -ne 0 ]; then
      break
    fi

    case $ACTION in
      "Shell") shell ;;
      # "AWS") configure_aws ;;
      "Setup") configure_gke ;;
      "Create") create ;;
      "Destroy"*)
        confirm
        if [ $? = 0 ]; then
          destroy
        fi;;
      "View") view ;;
      "Exit"*)
        confirm
        if [ $? = 0 ]; then
          break
        fi;;
    esac
  done

  infobox "Good bye!"
  sleep 0.5
  clear

  exit 0
}

[ -n "$MENU" ] || main
