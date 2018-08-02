include /build-harness/templates/Makefile.build-harness

include Makefile.*

create: \
	terraform/create/all \
	kops/create/all
	@echo "Cluster created"

destroy: \
  kops/destroy/all \
  terraform/destroy/all
	@echo "Cluster destroyed"
