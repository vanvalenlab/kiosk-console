#!/bin/bash

#
# This script is by Jonas Brunsgaard <jonas.brunsgaard@gmail.com> and is licensed under MIT
# Original script: https://raw.githubusercontent.com/brunsgaard/kops-nvidia-docker-installer/master/nvidia-docker-installer.sh
#

set -o errexit
set -o pipefail
set -u

export NVIDIA_DRIVER_VERSION="${NVIDIA_DRIVER_VERSION:-384.125}"
export NVIDIA_DRIVER_DOWNLOAD_URL_DEFAULT="https://us.download.nvidia.com/tesla/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run"
export NVIDIA_DRIVER_DOWNLOAD_URL="${NVIDIA_DRIVER_DOWNLOAD_URL:-$NVIDIA_DRIVER_DOWNLOAD_URL_DEFAULT}"
export NVIDIA_INSTALLER_RUNFILE="$(basename "${NVIDIA_DRIVER_DOWNLOAD_URL}")"
export NVIDIA_INSTALL_DIR="${NVIDIA_INSTALL_DIR:-/tmp}"
export DEBIAN_FRONTEND="noninteractive"
export INSTALL_FLAG="/.nvidia-docker-installer"

RETCODE_SUCCESS=0
RETCODE_ERROR=1
RETRY_COUNT=5

check_install_flag() {
  if [ -f "${INSTALL_FLAG}" ]; then
    echo "System already configured for nvidia-docker"
    exit 0
  fi
}

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
  rm -rf /var/lib/docker/overlay
  apt-get install -y software-properties-common python-software-properties
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

  curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
  distribution=$(. /etc/os-release;echo ${ID}${VERSION_ID})
  curl -s -L https://nvidia.github.io/nvidia-docker/${distribution}/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list
  apt-get update
  # apt list -a nvidia-container-runtime
  # apt list -a nvidia-docker2
  docker_version="17.06.2"
  apt-get install -y nvidia-docker2=2.0.3+docker${docker_version}-1 nvidia-container-runtime=2.0.0+docker${docker_version}-1 docker-ce=${docker_version}~ce-0~debian
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

disable_docker() {
  # Prevent process monitors from reactivating the service (`docker-healthcheck`)
  systemctl mask docker
}

stop_docker() {
  # Stop docker process
  systemctl stop docker
}

enable_docker() {
  # Re-enable docker service
  systemctl unmask docker
}

start_docker() {
  # Start docker process
  systemctl start docker
}

enable_install_flag() {
  touch "${INSTALL_FLAG}"
}

main() {
  # Check if we've already installed nvidia drivers
  check_install_flag

  # Disable docker during this process
  disable_docker

  # Stop it if it's running (shouldn't be since we run before docker, but `docker-healthcheck` may start it)
  stop_docker

  # Start installation
  download_kernel_src
  download_nvidia_installer
  run_nvidia_installer
  configure_gpu
  verify_nvidia_installation
  install_nvidia_docker2
  set_nvidia_container_runtime

  # Mark that we've set everything up
  enable_install_flag

  # Unmask docker so it can be started
  enable_docker

  # do not start docker, that's the job of systemd
  #start_docker
}

main "$@"
