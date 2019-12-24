echo "Destroying orphaned persistent disks..."
while IFS= read -r result
do
    gcloud compute disks delete $result --quiet --zone=${GPU_COMPUTE_REGION}
done < <(gcloud compute disks list | grep ${cluster_name} | awk '{print $1}')
