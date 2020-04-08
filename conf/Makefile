export CLOUD_PROVIDER ?= gke
export TRANSLATE_COLON_NOTATION=false

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
	@echo "DeepCell Kiosk has been created successfully."

## Destroy cluster
destroy: \
  helmfile/destroy/all \
  $(CLOUD_PROVIDER)/destroy/all
	@echo "DeepCell Kiosk has been destroyed successfully."

# Unit tests
test/unit:
	@echo "Linting helm charts"
	@helm init --client-only
	@ls -1 -d /conf/charts/* | xargs helm lint
	@echo "Linting helmfiles"
	@helmfile -f /conf/ELK_helmfiles/ -q build 1>/dev/null
	@helmfile -f /conf/helmfile.d/ -q build 1>/dev/null
	@echo "Gomplating addons"
	@ls -1 -d /conf/addons/*.yaml | xargs -I % gomplate -f %
	@echo "All tests passed!"

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

# Unit tests
test/unit:
	@echo "Linting helm charts"
	@helm init --client-only
	@ls -1 -d ${CONF_PATH_PREFIX}/conf/charts/* | xargs helm lint
	@echo "Linting helmfiles"
	@helmfile -f ${CONF_PATH_PREFIX}/conf/ELK_helmfiles/ -q build 1>/dev/null
	@helmfile -f ${CONF_PATH_PREFIX}/conf/helmfile.d/ -q build 1>/dev/null
	@echo "Gomplating addons"
	@ls -1 -d ${CONF_PATH_PREFIX}/conf/addons/*.yaml | xargs -I % gomplate -f %
	@echo "All tests passed!"

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
