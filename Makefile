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
test: export CLOUDSDK_CONTAINER_CLUSTER = deepcell-test-$(shell bash -c 'echo $$RANDOM')
test:
	# Some debug info
	echo "TEST"
	printenv
	echo $(CLOUDSDK_CORE_PROJECT) && echo $(HOME)
	pwd
	ls
	make init
	# Installations of binaries
	## helmfile
	@wget https://github.com/roboll/helmfile/releases/download/v0.82.0/helmfile_linux_amd64
	@chmod 764 $(CONF_PATH_PREFIX)/helmfile_linux_amd64
	@mv helmfile_linux_amd64 helmfile
	helmfile --version
	## gomplate
	@wget https://github.com/hairyhenderson/gomplate/releases/download/v3.1.0/gomplate_linux-amd64-slim
	@chmod 764 $(CONF_PATH_PREFIX)/gomplate_linux-amd64-slim
	@mv gomplate_linux-amd64-slim gomplate
	gomplate --version
	## kubectl
	@sudo apt-get update && sudo sudo apt-get install -y apt-transport-https
	@curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	@echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
	@sudo apt-get update
	@sudo apt-get install -y kubectl
	kubectl version --client
	## kubens
	@wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens
	@chmod 764 $(CONF_PATH_PREFIX)/kubens
	## helm
	@wget https://get.helm.sh/helm-v2.16.3-linux-amd64.tar.gz
	@tar -xzvf helm-v2.16.3-linux-amd64.tar.gz
	@chmod 764 $(CONF_PATH_PREFIX)/linux-amd64/helm
	@chmod 764 $(CONF_PATH_PREFIX)/linux-amd64/helm
	helm version -c
	## gcloud
	@sudo apt-get install apt-transport-https ca-certificates gnupg
	@echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
	@curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
	@sudo apt-get update && sudo apt-get install google-cloud-sdk
	mkdir -p $(CONF_PATH_PREFIX)/.config/gcloud
	sudo chmod 777 $(CONF_PATH_PREFIX)/.config
	sudo chmod 777 $(CONF_PATH_PREFIX)/.config/gcloud
	gcloud version
	echo $(CLOUDSDK_CONFIG)
	# execute make targets 
	cd ./conf && make -f Makefile test/create
	cd ./conf && make -f Makefile test/destroy
	# celebrate
	echo "TESTED"
