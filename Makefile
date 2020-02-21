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
test: export CLUSTER_NAME = deepcell-test-$(shell bash -c 'echo $$RANDOM')
test:
	echo "TEST"
	printenv
	echo $(CLOUDSDK_CORE_PROJECT) && echo $(HOME)
	pwd
	ls
	make init
	# Fix up env vars
	# Before we get into all the gcloud commands, we need to install the helmfile binary
	wget https://github.com/roboll/helmfile/releases/download/v0.82.0/helmfile_linux_amd64
	chmod 764 /home/runner/work/kiosk/kiosk/helmfile_linux_amd64
	/home/runner/work/kiosk/kiosk/helmfile_linux_amd64 --version
	# Also need to install gomplate
	wget https://github.com/hairyhenderson/gomplate/releases/download/v3.1.0/gomplate_linux-amd64-slim
	chmod 764 /home/runner/work/kiosk/kiosk/gomplate_linux-amd64-slim
	/home/runner/work/kiosk/kiosk/gomplate_linux-amd64-slim --version
	# And, finally, we need to install kubens
	wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens
	mv /home/runner/work/kiosk/kiosk/kubens /home/runner/work/kiosk/kiosk/conf/kubens.sh
	chmod 764 /home/runner/work/kiosk/kiosk/conf/kubens.sh
	# Checking everyone's versions
	helm version -c
	kubectl version --client
	gcloud version
	echo $(CLOUDSDK_CONFIG)
	# 
	cd ./conf && make -f Makefile.test test/create
	cd ./conf && make -f Makefile.test test/destroy
	# 
	echo "TESTED"
