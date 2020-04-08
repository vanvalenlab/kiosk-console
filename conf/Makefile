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
	@echo "Cluster created"

## Destroy cluster
destroy: \
  helmfile/destroy/all \
  $(CLOUD_PROVIDER)/destroy/all
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

## Target for testing cluster deployment
test/integration/gke/deploy: export CLOUDSDK_CONTAINER_CLUSTER = deepcell-test-$(shell bash -c 'echo $$((1 + $$RANDOM % 1000))')
test/integration/gke/deploy:
	make test/create
	make test/destroy
	@echo "TESTED"

test/integration/gke/deploy/elk: export ELK_DEPLOYMENT_TOGGLE = ON
test/integration/gke/deploy/elk: \
	test/integration/gke/deploy
