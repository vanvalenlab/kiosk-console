FROM cloudposse/build-harness:0.39.0 as build-harness

FROM cloudposse/geodesic:0.135.0

RUN apk add --update dialog libqrencode

ENV DOCKER_IMAGE="vanvalenlab/kiosk-console"
ENV DOCKER_TAG="latest"

# Geodesic banner
ENV BANNER="deepcell"
ENV BANNER_FONT="Larry 3D 2.flf"

# Disable cloudposse motd
ENV MOTD_URL=""

# Silence make
ENV MAKE="make -s"

# AWS Region
ENV AWS_REGION="us-west-2"

# kops config
ENV KOPS_CLUSTER_NAME="cluster.k8s.local"
ENV KOPS_DNS_ZONE=${KOPS_CLUSTER_NAME}
ENV KOPS_STATE_STORE="s3://undefined"
ENV KOPS_STATE_STORE_REGION="us-west-2"
ENV KOPS_AVAILABILITY_ZONES="us-west-2a,us-west-2b,us-west-2c"
ENV KOPS_BASTION_PUBLIC_NAME="bastion"
ENV BASTION_MACHINE_TYPE="t2.medium"
ENV MASTER_MACHINE_TYPE="t2.medium"
ENV NODE_MACHINE_TYPE="t2.medium"
ENV NODE_MAX_SIZE="10"
ENV NODE_MIN_SIZE="1"

# GPU config
ENV GPU_NODE_MAX_SIZE="1"
ENV GPU_NODE_MIN_SIZE="0"
ENV GPU_PER_NODE="1"

# gcloud config
ENV KUBERNETES_VERSION="1.22"
ENV CLOUDSDK_CORE_PROJECT=""
ENV CLOUDSDK_CONTAINER_CLUSTER=""
ENV CLOUDSDK_BUCKET=""
ENV CLOUDSDK_COMPUTE_REGION=""
ENV GCP_SERVICE_ACCOUNT=${CLOUDSDK_CONTAINER_CLUSTER}@${CLOUDSDK_CORE_PROJECT}.iam.gserviceaccount.com
ENV GCP_PREDICTION_GPU_TYPE="nvidia-tesla-t4"
ENV GCP_TRAINING_GPU_TYPE="nvidia-tesla-v100"
ENV GKE_MACHINE_TYPE="n1-standard-1"
ENV GPU_MACHINE_TYPE="n1-highmem-2"
ENV CONSUMER_MACHINE_TYPE="n1-standard-2"

# Deployment config
ENV CLOUD_PROVIDER=""
ENV ELK_DEPLOYMENT_TOGGLE=""
ENV CERTIFICATE_MANAGER_ENABLED="true"
ENV CERTIFICATE_MANAGER_CLUSTER_ISSUER="letsencrypt-prod"

# Filesystem entry for tfstate
RUN s3 fstab '${KOPS_STATE_STORE}' '/' '/s3'

# We do not need to access private git repos, so we can disable agent.
RUN rm -f /etc/profile.d/ssh-agent.sh /etc/profile.d/aws-vault.sh

# Copy from build-harness
COPY --from=build-harness /build-harness/ /build-harness/

# Place configurations in 'conf/' directory
COPY conf/ /conf/

# Add scripts to /usr/local/bin
COPY scripts/ /usr/local/bin/

# Copy rootfs overrides
COPY rootfs/ /

# Enable the menu
RUN ln -s /usr/local/bin/menu.sh /etc/profile.d/ΩΩ.menu.sh

WORKDIR /conf/
