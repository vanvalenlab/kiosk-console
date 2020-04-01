#!/bin/bash

for filename in ${CONF_PATH_PREFIX}/conf/helmfile.d/*.yaml; do
  deployment_names=$(helmfile -f $filename build | \
                     yq r - -- releases[*].name | awk '{print $NF}')
  for name in $deployment_names; do
    # TODO: use retry command instead of for loop.
    retries=3
    for ((i=0; i<retries; i++)); do
      helmfile --selector name=${name} sync
      [[ $? -eq 0 ]] && break
      echo "Something went wrong while deploying ${name}. Retrying in 30 seconds."
      helm delete ${name} --purge
      sleep 30
    done
  done
