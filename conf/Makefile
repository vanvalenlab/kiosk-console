export CLOUD_PROVIDER ?= aws

include /build-harness/templates/Makefile.build-harness

include tasks/Makefile.*

## Create cluster
create: \
  $(CLOUD_PROVIDER)/create/all \
  helm/create/all \
  helmfile/create/all
	@echo "Cluster created"

## Destroy cluster
destroy: \
  kops/destroy/all \
  $(CLOUD_PROVIDER)/destroy/all
	@echo "Cluster destroyed"
