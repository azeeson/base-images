IMAGE=libreswan
SWAN_VER=4.4

GITHUB_IMAGE=ghcr.io/$(REPOSITORY)/$(IMAGE)
DOCKER_HUB_IMAGE=$(USER)/$(IMAGE)

build:
	docker build --platform linux/amd64 --no-cache --build-arg SWAN_VER=$(SWAN_VER) \
		--tag $(GITHUB_IMAGE):$(SWAN_VER) --tag $(GITHUB_IMAGE):latest \
		--tag $(DOCKER_HUB_IMAGE):$(SWAN_VER) --tag $(DOCKER_HUB_IMAGE):latest .

push:
	docker push --all-tags $(GITHUB_IMAGE)
	docker push --all-tags $(DOCKER_HUB_IMAGE)

buildx:
	docker buildx build --push --platform linux/amd64 --build-arg SWAN_VER=$(SWAN_VER) \
		--tag $(GITHUB_IMAGE):$(SWAN_VER) --tag $(GITHUB_IMAGE):latest \
		--tag $(DOCKER_HUB_IMAGE):$(SWAN_VER) --tag $(DOCKER_HUB_IMAGE):latest .

.PHONY: build push buildx
