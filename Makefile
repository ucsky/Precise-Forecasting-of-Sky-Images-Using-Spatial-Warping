SHELL := /bin/bash -i # Bourne-Again SHell command-line interpreter on Linux.
SCRIPT := $(PWD)/script
### 

# Hack for displaying help message in Makefile
help: 
	@grep -E '(^[0-9a-zA-Z_-]+:.*?##.*$$)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

###


docker-build: ## Build docker images.
docker-build: Dockerfile
	-( \
	docker build \
	--progress=plain \
	--build-arg UID_WORKER=$$UID \
	--build-arg GID_WORKER=$$GID \
	-t skynet:dev . \
	)

docker-run-i: ## Run docker container interactively
docker-run-i:
	-(\
	docker run -it --rm --gpus all skynet:dev bash \
	)
