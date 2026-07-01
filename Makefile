PLUGIN ?=
REGISTRY ?= ghcr.io
ORG ?= headlamp-k8s
VERSION ?= $(shell node -p "require('./$(PLUGIN)/package.json').version" 2>/dev/null)
IMAGE_NAME := headlamp-plugin-$(PLUGIN)
FULL_IMAGE := $(REGISTRY)/$(ORG)/$(IMAGE_NAME)

.PHONY: all format lint lint-fix tsc build test docker-build docker-push check-plugin

check-plugin:
	@if [ -z "$(PLUGIN)" ]; then \
	  echo "Error: PLUGIN is required, e.g. make build PLUGIN=flux"; exit 1; \
	fi
	@if [ ! -d "$(PLUGIN)" ]; then \
	  echo "Error: plugin directory '$(PLUGIN)' does not exist"; exit 1; \
	fi

all: format lint tsc build test

format: check-plugin
	cd $(PLUGIN) && npm run format

lint: check-plugin
	cd $(PLUGIN) && npm run lint

lint-fix: check-plugin
	cd $(PLUGIN) && npm run lint-fix

tsc: check-plugin
	cd $(PLUGIN) && npm run tsc

build: check-plugin
	cd $(PLUGIN) && npm run build

test: check-plugin
	cd $(PLUGIN) && npm run test

docker-build: check-plugin
	docker build \
	  --build-arg PLUGIN=$(PLUGIN) \
	  -t $(FULL_IMAGE):v$(VERSION) \
	  -t $(FULL_IMAGE):latest \
	  .

docker-push: docker-build
	docker push $(FULL_IMAGE):v$(VERSION)
	docker push $(FULL_IMAGE):latest
