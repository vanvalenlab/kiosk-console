#!/bin/bash

for filename in /conf/helmfile.d/*.yaml; do
    deployment_name=$(grep "\- name: " ${filename} | grep -m1 -v "\- name: \"stable\"" | awk '{print $3}' | sed 's/^\"\(.\+\)\"$/\1/')
    retries=4
    for ((i=0; i<retries; i++)); do
        helm delete ${deployment_name} --purge
        [[ $? -eq 0 ]] && break
        echo "Something went wrong while deleteing ${deployment_name}. Retrying in 30 seconds."
        sleep 30
    done
done
