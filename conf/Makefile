include /build-harness/templates/Makefile.build-harness

include tasks/Makefile.*

create: \
  terraform/create/all \
  kops/create/all \
  kops/wait \
  helm/create/all \
  helmfile/create/all
	@echo "Cluster created"

destroy: \
  kops/destroy/all \
  terraform/destroy/all
	@echo "Cluster destroyed"
