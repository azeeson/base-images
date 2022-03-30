IMAGE=hugo
HUGO_VERSION=0.95.0

GITHUB_IMAGE=ghcr.io/$(REPOSITORY)/$(IMAGE)
DOCKER_HUB_IMAGE=$(USER)/$(IMAGE)

build:
	docker build --platform linux/amd64 --no-cache --build-arg HUGO_VERSION=$(HUGO_VERSION) \
		--tag $(GITHUB_IMAGE):$(HUGO_VERSION) --tag $(GITHUB_IMAGE):latest \
		--tag $(DOCKER_HUB_IMAGE):$(HUGO_VERSION) --tag $(DOCKER_HUB_IMAGE):latest .

push:
	docker push --all-tags $(GITHUB_IMAGE)
	docker push --all-tags $(DOCKER_HUB_IMAGE)

buildx:
	docker buildx build --push --platform linux/amd64,linux/arm64 --build-arg HUGO_VERSION=$(HUGO_VERSION) \
		--tag $(GITHUB_IMAGE):$(HUGO_VERSION) --tag $(GITHUB_IMAGE):latest \
		--tag $(DOCKER_HUB_IMAGE):$(HUGO_VERSION) --tag $(DOCKER_HUB_IMAGE):latest .

.PHONY: build push buildx
