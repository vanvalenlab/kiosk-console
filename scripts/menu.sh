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

function radiobox_from_array() {
  local title=$1
  local default_value=$2
  local message=$3
  local arr=$4

  local base_box_height=9
  local selector_box_lines=$(echo "${arr}" | tr -cd '\n' | wc -c)
  local selector_box_lines=$(($selector_box_lines+1))
  local total_lines=$(($base_box_height + $selector_box_lines))

  local formatted_arr=$(echo "${arr}" | awk '{print NR " " $1 " OFF"}')
  local arr_with_default=${formatted_arr/$default_value OFF/$default_value ON}

  local fullmessage="\n${message}\n\nPress the spacebar to select and Enter to continue.\n"

  local selected_value=$(radiobox "${title}" "${fullmessage}" $total_lines \
                         60 $selector_box_lines "${arr_with_default}")

  # echo the value with the selected row number
  local result=$(echo "${arr}" | awk -v i=$selected_value 'NR==i {print $1}')
  echo "${result}"
}

function infobox() {
  local message="$1"
  local h=${2:-3}
  local w=${3:-20}
  dialog --backtitle "$BRAND" --infobox "$message" $h $w
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

function export_gpu_constants() {
  # create some derivative GPU-related variables for use in autoscaling
  if [ ! -z "${GPU_NODE_MAX_SIZE}" ]; then
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
  fi
}

function menu() {
  # Show different functions in the main menu depending on whether the
  # cluster has been created yet.
  local value
  local header_text=("\n Use the UP/DOWN arrow keys or the first\n"
                     "letter of the choice as a hot key to\n"
                     "select an option.\n"
                     "\n")

  local cloud="${CLOUD_PROVIDER^^}"
  declare -A cloud_providers
  cloud_providers[${CLOUD_PROVIDER:-none}]="(active)"

  if [ -z "${CLUSTER_ADDRESS}" ]; then
    value=$(dialog --clear --backtitle "${BRAND}" \
              --title "[ M A I N - M E N U ]" \
              --menu "${header_text[*]}" 15 50 4 \
                  "GKE"       "Configure GKE" \
                  "Create"    "Create ${cloud} Cluster" \
                  "Shell"     "Drop to the shell" \
                  "Exit"      "Exit this kiosk" \
              --output-fd 1 \
            )
  else
    value=$(dialog --clear --backtitle "${BRAND}" \
              --title "[ M A I N - M E N U ]" \
              --menu "${header_text[*]}" 17 50 5 \
                  "GKE"       "Configure GKE" \
                  "Destroy"   "Destroy ${cloud} Cluster" \
                  "View"      "View Cluster Address" \
                  "Shell"     "Drop to the shell" \
                  "Exit"      "Exit this kiosk" \
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

  export GPU_NODE_MIN_SIZE=$(inputbox "Amazon Web Services" "Minimum Number of GPU Instances" "${GPU_NODE_MIN_SIZE:-0}")
  if [ "$GPU_NODE_MIN_SIZE" = "" ]; then
    return 0
  fi
  export GPU_NODE_MAX_SIZE=$(inputbox "Amazon Web Services" "Maximum Number of GPU Instances" "${GPU_NODE_MAX_SIZE:-4}")
  if [ "$GPU_NODE_MAX_SIZE" = "" ]; then
    return 0
  fi

  export KOPS_CLUSTER_NAME=${NAMESPACE}.k8s.local
  export KOPS_DNS_ZONE=${NAMESPACE}.k8s.local
  export KOPS_STATE_STORE=s3://${NAMESPACE}
  export CLOUD_PROVIDER=aws

  printenv | grep  -e CLOUD_PROVIDER \
    -e GPU_NODE_MAX_SIZE \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_S3_BUCKET \
    -e NAMESPACE \
    -e GPU_NODE_MIN_SIZE \
    -e GPU_NODE_MAX_SIZE \
    -e GPU_MAX > ${GEODESIC_CONFIG_HOME}/preferences
}

function configure_gke() {
  # if logged in, confirm the user wants to continue with this account
  local current_account=$(gcloud config list --format 'value(core.account)')
  if [ ! "${current_account}" = "" ]; then
    dialog --backtitle "${BRAND}" \
           --yesno "Do you want to continue as: \n\n    ${current_account}" 8 60
    response=$?
    # No 0 case, as it just continues to the next screen.
    case $response in
      1) local current_account="";;
      255) return 0;;
    esac
  fi
  # authenticate with gcloud if necessary
  if [ "${current_account}" = "" ]; then
    if ! make gke/login; then
      export CLOUD_PROVIDER=""
      local error_text=("\nAuthorization failed. Unable to continue setup procedure."
                        "\n\nPlease verify your Google Cloud credentials and try again."
                        "\n")
      dialog --backtitle "$BRAND" --title "GKE Login Failed" --clear --msgbox \
         "${error_text[*]}" 9 65

      return 0
    fi
  fi

  # select a project with GPUs available
  infobox "Loading..."
  local projects=$(gcloud projects list | grep -v NAME | awk '{print $1}')
  local default_project=$(echo ${projects} | awk '{print $1}')
  local default_project=${CLOUDSDK_CORE_PROJECT:-$default_project}
  local message="Select a project with GPU quotas enabled:"
  export CLOUDSDK_CORE_PROJECT=$(radiobox_from_array "Google Cloud" \
                                 $default_project "${message}" "${projects}")
  if [ "$CLOUDSDK_CORE_PROJECT" = "" ]; then
    return 0
  fi

  # Get the cluster name from the user or the environment
  if [ -z ${CLOUDSDK_CONTAINER_CLUSTER} ]; then
    export CLOUDSDK_CONTAINER_CLUSTER="deepcell-$(shuf -n 1 /etc/wordlist.txt)-$((1 + RANDOM % 100))"
  fi
  export CLOUDSDK_CONTAINER_CLUSTER=$(inputbox "Deepcell" "Cluster Name" "${CLOUDSDK_CONTAINER_CLUSTER:-deepcell-cluster}")
  export CLOUDSDK_CONTAINER_CLUSTER=$(echo ${CLOUDSDK_CONTAINER_CLUSTER} | awk '{print tolower($0)}' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/(^-+|-+$)//')
  if [ "$CLOUDSDK_CONTAINER_CLUSTER" = "" ]; then
    return 0
  fi

  # Get the bucket name from the user or the environment
  local bucket_text=("Bucket Name"
                     "\n\nThe bucket should be a unique existing bucket on google cloud."
                     "It acts as a storage area for models, data, and more."
                     "Please do not use underscores (_) in your bucket name.")
  export CLOUDSDK_BUCKET=$(inputbox "Deepcell" "${bucket_text[*]}" "${CLOUDSDK_BUCKET:-$CLOUDSDK_CONTAINER_CLUSTER}" 13 60)
  if [ "$CLOUDSDK_BUCKET" = "" ]; then
    return 0
  fi

  # use default settings or use the advanced menu
  local setup_opt_value=$(dialog --clear --backtitle "${BRAND}" \
              --title "  Configuration Options  " \
              --menu "${header_text[*]}" 10 70 3 \
                  "Default"     "Use default options to setup cluster" \
                  "Advanced"    "Specify custom cluster creation options" \
              --output-fd 1 \
            )

  if [ -z "$setup_opt_value" ]; then
    return 0

  elif [ "$setup_opt_value" = "Default" ]; then
    # Default settings
    infobox "Loading default values..." 7 60
    export CLOUDSDK_COMPUTE_REGION=us-west1
    export GKE_MACHINE_TYPE=n1-standard-1
    export NODE_MIN_SIZE=1
    export NODE_MAX_SIZE=10
    export GCP_PREDICTION_GPU_TYPE=nvidia-tesla-t4
    export GCP_TRAINING_GPU_TYPE=nvidia-tesla-v100
    export GPU_NODE_MIN_SIZE=0
    export GPU_NODE_MAX_SIZE=1

  else
    # Advanced menu
    infobox "Loading..."
    local regions=$(gcloud compute regions list | grep "-" | awk '{print $1}')
    local default_region=${CLOUDSDK_COMPUTE_REGION:-us-west1}
    local message="Choose a region for hosting your cluster:"
    export CLOUDSDK_COMPUTE_REGION=$(radiobox_from_array "Google Cloud" \
                                     $default_region "${message}" "${regions}")
    if [ "$CLOUDSDK_COMPUTE_REGION" = "" ]; then
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
    local gpus_in_region=$(gcloud compute accelerator-types list | grep ${CLOUDSDK_COMPUTE_REGION} | awk '{print $1}' | sort -u)
    local default_prediction_gpu=${GCP_PREDICTION_GPU_TYPE:-nvidia-tesla-t4}
    # local message="Choose a GPU for prediction (not training) from the GPU types available in your region:"
    local message="Choose a GPU from the types available in your region:"
    export GCP_PREDICTION_GPU_TYPE=$(radiobox_from_array "Google Cloud" \
                                     $default_prediction_gpu "${message}" "${gpus_in_region}")

    # local default_training_gpu=${GCP_TRAINING_GPU_TYPE:-nvidia-tesla-v100}
    # local message="Choose a GPU for training (not prediction) from the GPU types available in your region"
    # export GCP_TRAINING_GPU_TYPE=$(radiobox_from_array "Google Cloud" \
    #                                $default_training_gpu "${message}" "${gpus_in_region}")

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

  # Find at least 2 zones to deploy the cluster.
  # If GPUs are not available in at least 2 zones, the user must restart.
  local available_zones=$(gcloud compute zones list | grep "UP" \
                          | grep "${CLOUDSDK_COMPUTE_REGION}" | awk '{print $1}')
  local region_zone_array=($available_zones)
  local zone_filter=$(IFS="|" ; echo "${region_zone_array[*]}")

  # locate the zones for all GPU node pools
  local prediction_gpu_zones=$(gcloud compute accelerator-types list \
                               | grep -e "${GCP_PREDICTION_GPU_TYPE}" \
                               | grep -E "${zone_filter}" |  awk '{print $2}')

  # local training_gpu_zones=$(gcloud compute accelerator-types list \
  #                            | grep -e "${GCP_TRAINING_GPU_TYPE}" \
  #                            | grep -E "${zone_filter}" |  awk '{print $2}')

  # For each zone, check if it is available for each node pool, it is valid.
  local valid_zones=()
  for i in $available_zones
  do
    if [[ $prediction_gpu_zones =~ (^|[[:space:]])$i($|[[:space:]]) ]]; then # && \
       # [[ $training_gpu_zones =~ (^|[[:space:]])$i($|[[:space:]]) ]]; then
      valid_zones+=(${i})
    fi
  done

  export REGION_ZONES_WITH_GPUS=$(IFS=','; echo "${valid_zones[*]}"; IFS=$' \t\n')

  if [ ${#valid_zones[@]} -lt 2 ]; then
    local message=("The following are zones in your region with the specified GPU type(s):"
                   "\n\n    $REGION_ZONES_WITH_GPUS"
                   "\n\nKubernetes needs at least 2 available zones."
                   "Please re-configure with a different region/GPU type combination.")
    msgbox "Error!" "${message[*]}"
    return 0
  fi

  msgbox "Configuration Complete!" "\nThe cluster is now available for creation." 7 55

  export CLOUD_PROVIDER=gke
  export GCP_SERVICE_ACCOUNT=${CLOUDSDK_CONTAINER_CLUSTER}@${CLOUDSDK_CORE_PROJECT}.iam.gserviceaccount.com

  # These 2 values are hard-coded for now, menu is commented out above.
  export GPU_MACHINE_TYPE=${GPU_MACHINE_TYPE:-n1-highmem-2}
  export GPU_PER_NODE=${GPU_PER_NODE:-1}

  # The type of node for the consumer node pools
  export CONSUMER_MACHINE_TYPE=${CONSUMER_MACHINE_TYPE:-n1-highmem-2}

  export_gpu_constants

  printenv | grep -e CLOUD_PROVIDER \
    -e CLOUDSDK \
    -e NODE_MIN_SIZE \
    -e NODE_MAX_SIZE \
    -e GKE_MACHINE_TYPE \
    -e CONSUMER_MACHINE_TYPE \
    -e GPU_MACHINE_TYPE \
    -e REGION_ZONES_WITH_GPUS \
    -e GCP_PREDICTION_GPU_TYPE \
    -e GCP_TRAINING_GPU_TYPE \
    -e GPU_PER_NODE \
    -e GPU_NODE_MIN_SIZE \
    -e GPU_NODE_MAX_SIZE \
    -e GPU_MAX > ${GEODESIC_CONFIG_HOME}/preferences
}

function shell() {
  clear
  echo "Type 'exit' to return to the menu."
  bash -l
}

function create() {
  #todo: check if status is active and if not echo that fact and request config
  if [ -z "${CLOUD_PROVIDER^^}" ]; then
    msgbox "Warning!" "Cluster configuration is required." 6 55
  else
    tailcmd "Create Cluster" "---COMPLETE---" make create
    export CLUSTER_ADDRESS=$(sed -E 's/^export CLUSTER_ADDRESS=(.+)$/\1/' ./cluster_address)
  fi
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

  dialog --backtitle "${BRAND}" --yesno "Are you sure?" 6 55
  response=$?
  case $response in
    0) return 0;;
    1) return 1;;
    255) return 1;;
  esac
}

function confirm_cluster_launch() {

  local notice_text=("\nYou are about to launch a cluster with the name: "
                     "\n${CLOUDSDK_CORE_PROJECT}"
                     "\n\nPlease note that this process will take several minutes."
                     "If the cluster does not create successfully, it may be necessary to delete resources from the cloud console."
                     "\n\nWould you like to continue?")

  dialog --backtitle "${BRAND}" --title "Please Confirm" --yesno "${notice_text[*]}" 12 58
  response=$?
  case $response in
    0) return 0;;
    1) return 1;;
    255) return 1;;
  esac
}

function main() {
  export MENU=true

  local welcome_text=("\nWelcome to the Deepcell Kiosk!"
                      "\n\nThis Kiosk was developed by the Van Valen Lab at"
                      "the California Institute of Technology."
                      "\n\nhttps://vanvalenlab.caltech.edu")

  dialog --backtitle "$BRAND" --title "Welcome!" --clear --msgbox \
         "${welcome_text[*]}" 12 58

  while true; do
    ACTION=$(menu)
    if [ $? -ne 0 ]; then
      break
    fi

    case $ACTION in
      "Shell") shell ;;
      # "AWS") configure_aws ;;
      "GKE") configure_gke ;;
      "Create"*)
        confirm_cluster_launch
        if [ $? = 0 ]; then
          create
        fi;;
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
