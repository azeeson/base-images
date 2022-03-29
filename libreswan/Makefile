IMAGE=libreswan
SWAN_VER=4.4

GITHUB_IMAGE=ghcr.io/$(REPOSITORY)/$(IMAGE)
DOCKER_HUB_IMAGE=$(USER)/$(IMAGE)

build:
	docker build --platform linux/amd64 --no-cache --build-arg SWAN_VER=$(SWAN_VER) \
		--tag $(GITHUB_IMAGE):$(SWAN_VER) --tag $(GITHUB_IMAGE):latest \
		--tag $(DOCKER_HUB_IMAGE):$(SWAN_VER) --tag $(DOCKER_HUB_IMAGE):latest .

buildx:
	docker buildx build --platform linux/amd64 --build-arg SWAN_VER=$(SWAN_VER) \
		--tag $(GITHUB_IMAGE):$(SWAN_VER) --tag $(GITHUB_IMAGE):latest \
		--tag $(DOCKER_HUB_IMAGE):$(SWAN_VER) --tag $(DOCKER_HUB_IMAGE):latest .

.PHONY: build buildx
