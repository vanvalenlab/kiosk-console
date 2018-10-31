export CLOUD_PROVIDER ?= aws

include /build-harness/templates/Makefile.build-harness

include tasks/Makefile.*

## Create cluster
create: \
  $(CLOUD_PROVIDER)/create/all \
  helmfile/create/all \
  kubectl/display/ip
	@echo "Cluster created"

## Destroy cluster
destroy: \
  $(CLOUD_PROVIDER)/destroy/all
	@echo "Cluster destroyed"
