echo "Destroying orphaned persistent disks..."
while IFS= read -r result
do
    VAR_NAME=$(echo $result | awk '{print $1}')
    VAR_REGION=$(echo $result | awk '{print $2}')
    gcloud compute disks delete $VAR_NAME --quiet --zone=$VAR_REGION
done < <(gcloud compute disks list | grep $CLUSTER_NAME)
