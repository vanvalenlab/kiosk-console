for filename in /home/runner/work/kiosk/kiosk/conf/helmfile.d/*.yaml; do
    echo ${filename}
    #echo 'grep "\- name: " ${filename} | grep -m1 -v "\- name: \"stable\"" | awk {print \$3} | sed s/^\"\(.\+\)\"$/\1/'
    deployment_name=$(grep "\- name: " ${filename} | grep -m1 -v "\- name: \"stable\"" | awk '{print $3}' | sed 's/^\"\(.\+\)\"$/\1/')
    echo ${deployment_name}
    until /home/runner/work/kiosk/kiosk/helmfile_linux_amd64 --selector name=${deployment_name} sync; do
        helm delete ${deployment_name} --purge
        sleep 30
    done
done
