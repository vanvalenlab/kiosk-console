export CLOUD_PROVIDER ?= aws

include /build-harness/templates/Makefile.build-harness

include tasks/Makefile.*

## Create cluster
create: \
  $(CLOUD_PROVIDER)/create/all \
  helmfile/create/all \
  kubectl/display/ip \
  kubectl/implement/autoscaling
	@echo "Cluster created"

## Destroy cluster
destroy: \
  helmfile/destroy/all \
  $(CLOUD_PROVIDER)/destroy/all
	@echo "Cluster destroyed"
