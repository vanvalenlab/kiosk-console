#!/usr/bin/env bash

export BRAND="Caltech Van Valen Lab"

#dialog --print-maxsize

trap ctrl_c SIGINT

function ctrl_c() {
  killall dialog
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
  local w=${3:-60}
  local h=${4:-8}
  shift
  value=$(dialog --title "$title" \
            --inputbox "$label " $h $w \
            --backtitle "${BRAND}" \
            --output-fd 1)
  retval $?
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
  local completed_mesage=${2:-">>> Done!\n"}
  local tmpfile=$(mktemp /tmp/setup.XXXXXX)
  shift
  shift
  :> $tmpfile
  {
    $* 2>&1
    printf "${completed_message}"
    sleep 20
  } > $tmpfile &

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
  export AWS_ACCESS_KEY_ID=$(inputbox "Amazon Web Services" "Access Key ID")
  export AWS_SECRET_KEY=$(inputbox "Amazon Web Services" "AWS Secret Key")
  
  printenv | grep -e AWS_ACCESS_KEY_ID -e AWS_SECRET_KEY > env
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
