export CLUSTER ?= kiosk-console
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
test/integration/gke/deploy: export CLOUDSDK_CONTAINER_CLUSTER = deepcell-test-$(shell bash -c 'echo $$((1 + $$RANDOM % 1000))')
test/integration/gke/deploy:
	# check environment variables
	printenv
	# check that necessary binaries are installed
	helmfile --version
	gomplate --version
	kubectl version --client
	helm version -c
	gcloud version
	# execute make targets
	# make init
	cd ./conf && make test/create
	cd ./conf && make test/destroy
	# celebrate
	echo "TESTED"

test/integration/gke/deploy/elk: export ELK_DEPLOYMENT_TOGGLE = ON
test/integration/gke/deploy/elk: \
	test/integration/gke/deploy
