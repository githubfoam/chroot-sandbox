IMAGE := alpine/fio
APP:="scripts/usernetes-containerd.sh"

deploy-modsecurity:
	bash scripts/deploy-modsecurity.sh

deploy-packer:
	bash scripts/deploy-packer.sh

deploy-terraform:
	bash scripts/deploy-terraform.sh

push-image:
	docker push $(IMAGE)

.PHONY: deploy-libvirt deploy-vagrant deploy-packer deploy-terraform push-image
