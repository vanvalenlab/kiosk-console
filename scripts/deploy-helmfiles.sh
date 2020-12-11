#!/bin/bash

failures=()
((base_time = 30))
retries=3

for filename in /conf/helmfile.d/*.yaml; do
  deployment_names=$(helmfile -f $filename build | \
                     yq r - -- releases[*].name | awk '{print $NF}')
  for name in $deployment_names; do
    for ((i=0; i<retries; i++)); do
      # Try to deploy and break out of retry loop if successful
      helmfile --selector name=${name} sync
      [[ $? -eq 0 ]] && break

      # If we still have retries, sleep for a bit and retry
      # Otherwise, add deployment to list of failures
      if [[ $j+1 -lt $retries ]]; then
        ((time = $base_time * ($i + 1)))
        echo "Something went wrong while deploying ${name}. Retrying in ${time} seconds."
        sleep $time
      else
        failures+=($name)
      fi

    done
  done
done

# Log all the failed deployments
if [[ ${#failures[@]} -gt 0 ]]; then
  echo ""
  echo "Not all deployments successfully deployed!"
  echo "Please run the following commands to re-deploy failures:"
  echo ""
  for failure in ${failures[@]}; do
    echo "    helmfile -l name=${failure} sync"
  done
  echo ""
fi
