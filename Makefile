export CLUSTER ?= kiosk
export DOCKER_ORG ?= vanvalenlab
export DOCKER_IMAGE ?= $(DOCKER_ORG)/$(CLUSTER)
export DOCKER_TAG ?= latest
export DOCKER_IMAGE_NAME ?= $(DOCKER_IMAGE):$(DOCKER_TAG)
export DOCKER_BUILD_FLAGS = 
export README_DEPS ?= docs/targets.md
export INSTALL_PATH ?= /usr/local/bin

-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)

## Initialize build-harness, install deps, build docker container, install wrapper script and run shell
all: init deps build install run
	@exit 0

## Install dependencies (if any)
deps:
	@exit 0

## Build docker image
build:
	@make --no-print-directory docker/build

## Push docker image to registry
push:
	docker push $(DOCKER_IMAGE)

## Install wrapper script from geodesic container
install:
	@docker run --rm $(DOCKER_IMAGE_NAME) | sudo -E bash -s $(DOCKER_TAG)

## Start the geodesic shell by calling wrapper script
run:
	$(CLUSTER)

## Target for testing cluster deployment
test:
	echo "TEST"
	echo $(PROJECT) && echo $(HOME)
	pwd
	ls
	make init
	#gcloud config set project $(PROJECT) && \
	#gcloud config set account $(GKE_NODE_SERVICE_ACCOUNT_EMAIL) &&
	# Before we get into all the gcloud commands, we need to install the helmfile binary
	wget https://github.com/roboll/helmfile/releases/download/v0.100.0/helmfile_linux_amd64
	chmod 764 /home/runner/work/kiosk/kiosk/helmfile_linux_amd64
	# Install version 1.14 of kubectl
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
	echo "deb http://apt.kubernetes.io/ kubernetes-yakkety main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
	sudo apt-get update && \
	sudo apt-get install -y kubeadm=1.14
	gcloud auth activate-service-account $(GKE_NODE_SERVICE_ACCOUNT_EMAIL) --key-file=$(HOME)/secrets/gke_service_account_key.json && \
	gcloud auth list
	gcloud config set account continuous-integration-test@deepcell-209717.iam.gserviceaccount.com
	#gcloud auth list
	gcloud projects get-iam-policy deepcell-209717
	gcloud version
	#gcloud projects add-iam-policy-binding deepcell-209717 --member serviceAccount:continuous-integration-test@deepcell-209717.iam.gserviceaccount.com --role roles/owner
	cd ./conf/tasks && make -f Makefile.gke gke/create/cluster
	echo $(CLOUDSDK_CONFIG)
	cd ./conf/tasks && make -f Makefile.gke gke/create/node-pools
	cd ./conf/tasks && make -f Makefile.gke gke/create/bucket
	cd ./conf/tasks && make -f Makefile.gke gke/deploy/helm
	cd ./conf/tasks && make -f Makefile.gke gke/deploy/nvidia
	kubectl version --client
	cd ./conf/tasks && make -f Makefile.helmfile helmfile/create/all && make -f Makefile.kubectl kubectl/display/ip && make -f Makefile.kubectl kubectl/implement/autoscaling
	echo "TESTED"
	#gcloud config set project $(PROJECT) && \
	#gcloud iam service-accounts create $(CLUSTER_NAME) --display-name "Deepcell" && \
	#gcloud projects add-iam-policy-binding $(CLOUDSDK_CORE_PROJECT) --member serviceAccount:$(GKE_NODE_SERVICE_ACCOUNT_EMAIL) --role roles/storage.admin &&
	#cd ./conf/tasks && make -f Makefile.gke gke/create/service-account
