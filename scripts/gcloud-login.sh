#!/usr/bin/env bash

clear

# Print text to explain this confusing screen to the user.
echo "Deploying a cluster on Google Cloud requires authorization."
echo ""

# Print crazy link to screen and prompt user to paste confirmation code received from browser.
# NB: --verbosity "critical": That is to suppress ERRORs when the authenticated account
#     doesn't have a default project. (See below.) This is for purposes of UI aesthetics.
gcloud auth login --no-launch-browser --verbosity "critical"

# Now, evaluate whether the script succeeded or failed.
if [ $? -eq 0 ]; then
  echo "Success!"
else
  # Check to see whether the command authenticated, but failed due to an unset default project.
  # If so, just ignore the error.
  # NB: Ideally, we'd grab this info directly from the gcloud auth login command,
  # but the command is written in such a way that that's very difficult.
  project_failure=$( \
	  cat $(gcloud info --format "value(logs.last_log)") | \
	  grep "ERROR    root            (gcloud.auth.login) The project property is set to the empty string, which is invalid.")
  if [[ -z "${project_failure}" ]]; then
    echo "Login failed!"
    exit 1
  else
    echo "Success!"
  fi
fi
