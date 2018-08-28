#!/bin/bash

#
# This script is by Jonas Brunsgaard <jonas.brunsgaard@gmail.com> and is licensed under MIT
# Original script: https://raw.githubusercontent.com/brunsgaard/kops-nvidia-docker-installer/master/nvidia-docker-installer.sh
#


set -o errexit
set -o pipefail
set -u

set -x
NVIDIA_DRIVER_VERSION="${NVIDIA_DRIVER_VERSION:-384.125}"
NVIDIA_DRIVER_DOWNLOAD_URL_DEFAULT="https://us.download.nvidia.com/tesla/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run"
NVIDIA_DRIVER_DOWNLOAD_URL="${NVIDIA_DRIVER_DOWNLOAD_URL:-$NVIDIA_DRIVER_DOWNLOAD_URL_DEFAULT}"
NVIDIA_INSTALLER_RUNFILE="$(basename "${NVIDIA_DRIVER_DOWNLOAD_URL}")"
NVIDIA_INSTALL_DIR="${NVIDIA_INSTALL_DIR:-/tmp}"
set -x


RETCODE_SUCCESS=0
RETCODE_ERROR=1
RETRY_COUNT=5


download_kernel_src() {
  echo "Downloading kernel sources..."
  apt-get update
  apt-get install -y linux-headers-$(uname -r)
  apt-get install -y gcc libc-dev
  echo "Downloading kernel sources... DONE."
}

download_nvidia_installer() {
  echo "Downloading Nvidia installer..."
  pushd "${NVIDIA_INSTALL_DIR}"
  curl -L -S -f "${NVIDIA_DRIVER_DOWNLOAD_URL}" -o "${NVIDIA_INSTALLER_RUNFILE}"
  popd
  echo "Downloading Nvidia installer... DONE."
}

run_nvidia_installer() {
  echo "Running Nvidia installer..."
  pushd "${NVIDIA_INSTALL_DIR}"
  sh "${NVIDIA_INSTALLER_RUNFILE}" \
    --no-install-compat32-libs \
    --log-file-name="${NVIDIA_INSTALL_DIR}/nvidia-installer.log" \
    --no-drm \
    --silent \
    --accept-license
  popd
  echo "Running Nvidia installer... DONE."
}

configure_gpu() {
  nvidia-smi -pm 1
  nvidia-smi -acp 0
  nvidia-smi --auto-boost-default=0
  nvidia-smi --auto-boost-permission=0
  nvidia-smi -ac 2505,875
}

verify_nvidia_installation() {
  echo "Verifying Nvidia installation..."
  nvidia-smi
  nvidia-modprobe -c0 -u
  echo "Verifying Nvidia installation... DONE."
}

install_nvidia_docker2() {
  curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
  curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list
  apt-get update
  apt-get install -y nvidia-docker2=2.0.3+docker17.03.2-1 nvidia-container-runtime=2.0.0+docker17.03.2-1
}

set_nvidia_container_runtime() {
  cat > /etc/docker/daemon.json <<EOL
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOL
}

main() {
  download_kernel_src
  download_nvidia_installer
  run_nvidia_installer
  configure_gpu
  verify_nvidia_installation
  install_nvidia_docker2
  set_nvidia_container_runtime
}

main "$@"
