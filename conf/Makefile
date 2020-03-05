export CLOUD_PROVIDER ?= gke

# The if statement is meant to keep this line from executing during testing.
ifeq ($(CONF_PATH_PREFIX), )
	include /build-harness/templates/Makefile.build-harness
endif

include tasks/Makefile.*

## Create cluster
create: \
  $(CLOUD_PROVIDER)/create/all \
  kubectl/create/prometheus-redis-exporter-script \
  helmfile/create/all \
  kubectl/display/ip \
  kubectl/implement/autoscaling
	@echo "Cluster created"

## Destroy cluster
destroy: \
  helmfile/destroy/all \
  $(CLOUD_PROVIDER)/destroy/all
	@echo "Cluster destroyed"

## Create test cluster
test/create: \
  $(CLOUD_PROVIDER)/test/create/all \
  kubectl/create/prometheus-redis-exporter-script \
  helmfile/create/all \
  kubectl/display/ip \
  kubectl/implement/autoscaling
	@echo "Cluster created"

## Destroy cluster
test/destroy: \
  helmfile/destroy/all \
  $(CLOUD_PROVIDER)/test/destroy/all
	@echo "Cluster destroyed"
