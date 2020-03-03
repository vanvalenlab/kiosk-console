#/bin/bash

# define env vars
export CHARTS_PATH=/home/travis/build/vanvalenlab/kiosk/conf/charts
export CLOUD_PROVIDER=gke 
export CLOUDSDK_BUCKET=deepcell-output-benchmarking
export CLOUDSDK_COMPUTE_REGION=us-west1
export CLOUDSDK_CONFIG=/home/travis/build/vanvalenlab/kiosk/.config/gcloud/
export CLOUDSDK_CORE_PROJECT=deepcell-209717
export CLOUDSDK_CORE_VERBOSITY=debug
export CONF_PATH_PREFIX=/home/travis/build/vanvalenlab/kiosk
export CONSUMER_MACHINE_TYPE=n1-highmem-2
export GCP_PREDICTION_GPU_TYPE=nvidia-tesla-t4
export GCP_TRAINING_GPU_TYPE=nvidia-tesla-v100
export GKE_MACHINE_TYPE=n1-standard-1
export GCP_SERVICE_ACCOUNT=continuous-integration-test@deepcell-209717.iam.gserviceaccount.com
export GPU_MACHINE_TYPE=n1-highmem-2
export GPU_MAX_DIVIDED_BY_FOUR=1
export GPU_MAX_DIVIDED_BY_THREE=1
export GPU_MAX_DIVIDED_BY_TWO=2
export GPU_MAX_TIMES_FIFTY=200 
export GPU_MAX_TIMES_FIVE=20
export GPU_MAX_TIMES_FOUR=16
export GPU_MAX_TIMES_FOURTY=160 
export GPU_MAX_TIMES_ONE_HUNDRED=400 
export GPU_MAX_TIMES_ONE_HUNDRED_FIFTY=600 
export GPU_MAX_TIMES_SEVENTY_FIVE=300 
export GPU_MAX_TIMES_TEN=40
export GPU_MAX_TIMES_THIRTY=120 
export GPU_MAX_TIMES_THREE=12
export GPU_MAX_TIMES_TWENTY=80
export GPU_MAX_TIMES_TWO=8
export GPU_MAX_TIMES_TWO_HUNDRED=800 
export GPU_NODE_MIN_SIZE=0
export GPU_NODE_MAX_SIZE=4
export GPU_PER_NODE=1
export KUBERNETES_VERSION=latest
export NODE_MIN_SIZE=1
export NODE_MAX_SIZE=60
export REGION_ZONES_WITH_GPUS=us-west1-a,us-west1-b

# Install helmfile
wget https://github.com/roboll/helmfile/releases/download/v0.82.0/helmfile_linux_amd64
chmod 764 $CONF_PATH_PREFIX/helmfile_linux_amd64
mv helmfile_linux_amd64 helmfile
helmfile --version
# Install gomplate
wget https://github.com/hairyhenderson/gomplate/releases/download/v3.1.0/gomplate_linux-amd64-slim
chmod 764 $CONF_PATH_PREFIX/gomplate_linux-amd64-slim
mv gomplate_linux-amd64-slim gomplate
gomplate --version
# Install kubectl
sudo apt-get update && sudo sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
kubectl version --client
# Install kubens
wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens
chmod 764 $CONF_PATH_PREFIX/kubens
# Install helm
wget https://get.helm.sh/helm-v2.16.3-linux-amd64.tar.gz
tar -xzvf helm-v2.16.3-linux-amd64.tar.gz
chmod 764 $CONF_PATH_PREFIX/linux-amd64/helm
mv $CONF_PATH_PREFIX/linux-amd64/helm $CONF_PATH_PREFIX/
helm version -c
# Install gcloud
sudo apt-get install apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk
gcloud version
