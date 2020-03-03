#/bin/bash

# Install helmfile
wget https://github.com/roboll/helmfile/releases/download/v0.82.0/helmfile_linux_amd64
chmod 764 $CONF_PATH_PREFIX/helmfile_linux_amd64
mv helmfile_linux_amd64 helmfile
# Install gomplate
wget https://github.com/hairyhenderson/gomplate/releases/download/v3.1.0/gomplate_linux-amd64-slim
chmod 764 $CONF_PATH_PREFIX/gomplate_linux-amd64-slim
mv gomplate_linux-amd64-slim gomplate
# Install kubectl
sudo apt-get update && sudo sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
# Install kubens
wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens
chmod 764 $CONF_PATH_PREFIX/kubens
# Install helm
wget https://get.helm.sh/helm-v2.16.3-linux-amd64.tar.gz
tar -xzvf helm-v2.16.3-linux-amd64.tar.gz
chmod 764 $CONF_PATH_PREFIX/linux-amd64/helm
mv $CONF_PATH_PREFIX/linux-amd64/helm $CONF_PATH_PREFIX/
# Install gcloud
sudo apt-get install apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk
## prep directory structure for gcloud	
mkdir -p $CONF_PATH_PREFIX/.config/gcloud
sudo chmod 777 $CONF_PATH_PREFIX/.config
sudo chmod 777 $CONF_PATH_PREFIX/.config/gcloud
