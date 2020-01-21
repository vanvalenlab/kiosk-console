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

## Create $GEODESIC_CONFIG_HOME directory, if it doesn't already exist
create_cache_path:
	@if [ ! -z "$(GEODESIC_CONFIG_HOME)" ] && [ ! -d "$(GEODESIC_CONFIG_HOME)" ]; \
	then \
	  mkdir $(GEODESIC_CONFIG_HOME); \
	fi
