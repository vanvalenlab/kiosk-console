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
  dialog --backtitle "$BRAND" --title "$title" --clear --msgbox "$message" 10 41
  retval $?
}

function inputbox() {
  local value
  local title=$1
  local label=$2
  local default=$3
  local w=${4:-60}
  local h=${5:-8}
  shift
  value=$(dialog --title "$title" \
            --inputbox "$label " "$h" "$w" "$default" \
            --backtitle "${BRAND}" \
            --output-fd 1)
  echo $value
}

function infobox() {
  local message="$1"
  local w=${2:-20}
  local h=${3:-3}
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

function menu() {
  local value
  local help=("You can use the UP/DOWN arrow keys, the first\n"
              "letter of the choice as a hot key, or the\n"
              "number keys 1-9 to choose an option.\n"
              "Choose a task.")
  value=$(dialog --clear  --help-button --backtitle "${BRAND}" \
            --title "[ M A I N - M E N U ]" \
            --menu "${help[*]}" 15 50 5 \
                Setup "Configure AWS Credentials" \
                Create "Create Cluster" \
                Destroy "Destroy Cluster" \
                Shell "Drop to the shell" \
                Exit "Exit this kiosk" \
            --output-fd 1 \
          )
  retval $?
  echo $value
}


function setup() {
  if [ -z "${NAMESPACE}" ]; then
    # Generate a friendly human readable name
    export NAMESPACE="$(shuf -n 1 /etc/wordlist.txt)-$((1 + RANDOM % 100))"
  fi

  export AWS_ACCESS_KEY_ID=$(inputbox "Amazon Web Services" "Access Key ID" "${AWS_ACCESS_KEY_ID}")
  export AWS_SECRET_ACCESS_KEY=$(inputbox "Amazon Web Services" "AWS Secret Key" "${AWS_SECRET_ACCESS_KEY}")
  export AWS_S3_BUCKET=$(inputbox "Amazon Web Services" "AWS S3 Bucket Name" "${AWS_S3_BUCKET}")
  export NAMESPACE=$(inputbox "Deepcell" "Cluster Name" "${NAMESPACE}")

  export KOPS_CLUSTER_NAME=${NAMESPACE}.k8s.local
  export KOPS_DNS_ZONE=${NAMESPACE}.k8s.local
  export KOPS_STATE_STORE=s3://${NAMESPACE}
  
  printenv | grep -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_S3_BUCKET -e NAMESPACE -e KOPS_CLUSTER_NAME -e KOPS_DNS_ZONE -e KOPS_STATE_STORE > ${CACHE_PATH}/env
}

function shell() {
  clear
  echo "Type 'exit' to return to the menu."
  bash -l
}

function create() {
  tailcmd "Create Cluster" "---COMPLETE---" make create
}

function destroy() {
  tailcmd "Destroy Cluster" "---COMPLETE--" make destroy
}

function main() {
  export MENU=true
  msgbox "Welcome!" "Welcome to the Deepcell Kiosk"

  while true; do
    ACTION=$(menu)
    if [ $? -ne 0 ]; then
      break
    fi

    case $ACTION in
      "Shell") shell ;;
      "Setup") setup ;;
      "Create") create ;;
      "Destroy") destroy;;
      "Exit") break ;;
    esac
  done

  infobox "Good bye!"
  sleep 0.5
  clear

  exit 0
}

[ -n "$MENU" ] || main
