FROM cloudposse/terraform-root-modules:0.5.0 as terraform-root-modules

FROM cloudposse/build-harness:0.6.14 as build-harness

FROM cloudposse/geodesic:0.12.4

RUN apk add --update dialog

ENV DOCKER_IMAGE="vanvalenlab/kiosk"
ENV DOCKER_TAG="latest"

# Geodesic banner
ENV BANNER="deepcell"

# Disable cloudposse motd
ENV MOTD_URL=""

# Silence make
ENV MAKE="make -s"

# AWS Region
ENV AWS_REGION="us-west-2"

# Terraform vars
ENV TF_VAR_region="${AWS_REGION}"
ENV TF_VAR_namespace="ctvv"
ENV TF_VAR_stage="kiosk"
ENV TF_VAR_domain_enabled="false"
ENV TF_VAR_ssh_public_key_path="/localhost/.geodesic"

# Terraform State Bucket
ENV TF_BUCKET_REGION="${AWS_REGION}"
ENV TF_BUCKET="${TF_VAR_namespace}-${TF_VAR_stage}-terraform-state"
ENV TF_DYNAMODB_TABLE="${TF_VAR_namespace}-${TF_VAR_stage}-terraform-state-lock"

# Default AWS Profile name
ENV AWS_DEFAULT_PROFILE="${TF_VAR_namespace}-${TF_VAR_stage}-admin"

# kops config
ENV KOPS_CLUSTER_NAME="cluster.k8s.local"
ENV KOPS_DNS_ZONE=${KOPS_CLUSTER_NAME}
ENV KOPS_STATE_STORE="s3://${TF_VAR_namespace}-${TF_VAR_stage}-kops-state"
ENV KOPS_STATE_STORE_REGION="us-west-2"
ENV KOPS_AVAILABILITY_ZONES="us-west-2a,us-west-2b,us-west-2c"
ENV KOPS_BASTION_PUBLIC_NAME="bastion"
ENV BASTION_MACHINE_TYPE="t2.medium"
ENV MASTER_MACHINE_TYPE="t2.medium"
ENV NODE_MACHINE_TYPE="t2.medium"
ENV NODE_MAX_SIZE="2"
ENV NODE_MIN_SIZE="2"

# Filesystem entry for tfstate
RUN s3 fstab '${TF_BUCKET}' '/' '/secrets/tf'

# We do not need to access private git repos, so we can disable agent
RUN rm -f /etc/profile.d/ssh-agent.sh

# Copy from build-harness
COPY --from=build-harness /build-harness/ /build-harness/

# Copy root modules
COPY --from=terraform-root-modules /aws/tfstate-backend/ /conf/tfstate-backend/
COPY --from=terraform-root-modules /aws/kops/ /conf/kops/

# Place configurations in 'conf/' directory
COPY conf/ /conf/

# Add scripts to /usr/local/bin
COPY scripts/ /usr/local/bin/

# Copy rootfs overrides
COPY rootfs/ /

WORKDIR /conf/
