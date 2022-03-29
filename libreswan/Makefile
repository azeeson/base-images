IMAGE=libreswan
SWAN_VER=4.4

build:
	docker build --platform linux/amd64 --no-cache --build-arg SWAN_VER=$(SWAN_VER) \
		--tag ghcr.io/$(USER)/base-images/$(IMAGE):$(SWAN_VER) --tag ghcr.io/$(USER)/base-images/$(IMAGE):latest \
		--tag $(USER)/$(IMAGE):$(SWAN_VER) --tag $(USER)/$(IMAGE):latest .

buildx:
	docker buildx build --platform linux/amd64,linux/arm64 --build-arg SWAN_VER=$(SWAN_VER) \
		--tag ghcr.io/$(USER)/base-images/$(IMAGE):$(SWAN_VER) --tag ghcr.io/$(USER)/base-images/$(IMAGE):latest \
		--tag $(USER)/$(IMAGE):$(SWAN_VER) --tag $(USER)/$(IMAGE):latest .

.PHONY: build buildx
