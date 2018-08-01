export BRAND="Caltech Van Valen Lab"

#dialog --print-maxsize

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
  local message=$1
  dialog --title "$BRAND" --clear --msgbox "$message" 10 41
  retval $?
}

function inputbox() {
  local value
  local label=$1
  local w=${2:-60}
  local h=${3:-8}
  shift
  value=$(dialog --title "$BRAND" \
            --backtitle "Linux Shell Script Tutorial Example" \
            --inputbox "$label " $h $w \
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
  :> $tmpfile
  {
    $* 2>&1
    printf "${completed_message}"
  } > $tmpfile &

  dialog --clear \
         --begin 0 0 \
         --title "$title" \
         --begin 3 1 \
         --tailboxbg $tmpfile 20 80 \
         --and-widget \
         --begin 23 10 \
         --msgbox "Press OK " 5 30
  kill %1 
  wait >/dev/null 2>&1
  rm -f $tmpfile
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
                Setup "Setup AWS Credentials" \
                Create "Create Cluster" \
                Destroy "Destroy Cluster" \
                Shell "Drop to the shell" \
                Exit "Exit this kiosk" \
            --output-fd 1 \
          )
  retval $?
  echo $value
}

#msgbox "Welcome to the Deepcell Kiosk"

#AWS_ACCESS_KEY_ID=$(inputbox "AWS Access Key ID")
#AWS_SECRET_KEY=$(inputbox "AWS Secret Key")

#echo "[$AWS_ACCESS_KEY_ID]"
#echo "[$AWS_SECRET_KEY]"
ACTION=$(menu)
tailcmd "Directories" ls -l /
infobox "Good bye!"
