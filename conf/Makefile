export CLOUD_PROVIDER ?= gke
export TRANSLATE_COLON_NOTATION=false

include /build-harness/templates/Makefile.build-harness

include tasks/Makefile.*

## Create cluster
create: \
  $(CLOUD_PROVIDER)/create/all \
  kubectl/create/prometheus-redis-exporter-script \
  helmfile/create/all \
  kubectl/display/ip
	@kubens deepcell
	@echo "DeepCell Kiosk has been created successfully."

## Destroy cluster
destroy: \
  helmfile/destroy/all \
  kubectl/destroy/pvc \
  $(CLOUD_PROVIDER)/destroy/all
	@echo "DeepCell Kiosk has been destroyed successfully."

# Unit tests
test/unit:
	@echo "Linting helm charts"
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
  kubectl/display/ip
	@kubens deepcell
	@echo "Cluster created"

## Destroy cluster
test/destroy: \
  helmfile/destroy/all \
  kubectl/destroy/pvc \
  $(CLOUD_PROVIDER)/test/destroy/all
	@echo "Cluster destroyed"

## Target for testing cluster deployment
test/integration/gke/deploy: export CLOUDSDK_CONTAINER_CLUSTER = deepcell-test-$(shell bash -c 'echo $$((1 + $$RANDOM % 1000))')
test/integration/gke/deploy: export CERTIFICATE_MANAGER_ENABLED = true
test/integration/gke/deploy:
	make test/create
	# TODO: add more testing workflows
	make test/destroy
	@echo "TESTED"

test/integration/gke/deploy/elk: export ELK_DEPLOYMENT_TOGGLE = ON
test/integration/gke/deploy/elk: \
	test/integration/gke/deploy
