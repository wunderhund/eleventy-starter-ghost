
INTERACTIVE := $(shell [ -t 0 ] && echo -it)

DOCKER_TAG := ggjam-eleventy
DOCKER_NETWORK := ggjam-backend_ggjam
DOCKER_ARGS := -v $(shell pwd):/app $(INTERACTIVE) \
							 --network $(DOCKER_NETWORK) \
							 --rm --init
BASH := docker run $(DOCKER_ARGS) $(DOCKER_TAG) /bin/bash

.PHONY: init
init: create-network
	docker build -t $(DOCKER_TAG) .
	$(BASH) -c 'yarn'

.PHONY: dev
dev: 
	docker run $(DOCKER_ARGS) -p 8080:8080 -p 3001:3001 -t $(DOCKER_TAG) /bin/bash -c 'yarn start'

.PHONY: package
package: create-network clean
	$(BASH) -c 'gatsby build'
	$(BASH) -c 'tar -cvf frontend.tar public'

.PHONY: build
build: 
	docker run $(DOCKER_ARGS) -p 8080:8080 -p 3001:3001 -t $(DOCKER_TAG) /bin/bash -c 'yarn build'

.PHONY: serve
serve: package
	docker run $(DOCKER_ARGS) -p 9000:9000 --init -t $(DOCKER_TAG) /bin/bash -c 'gatsby serve -H "0.0.0.0"'

.PHONY: clean
clean: create-network
	$(BASH) -c 'gatsby clean'
	$(BASH) -c 'rm -f frontend.tar'

.PHONY: shell
shell: create-network
	$(BASH)

.PHONY: create-network
create-network:
	@docker network inspect $(DOCKER_NETWORK) 1>/dev/null || docker network create --driver bridge $(DOCKER_NETWORK)
