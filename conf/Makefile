export CLOUD_PROVIDER ?= gke

include /build-harness/templates/Makefile.build-harness

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
