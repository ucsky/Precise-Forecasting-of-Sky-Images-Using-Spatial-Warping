SHELL := /bin/bash -i # Bourne-Again SHell command-line interpreter on Linux.
SCRIPT := $(PWD)/script
### 

# Hack for displaying help message in Makefile
help: 
	@grep -E '(^[0-9a-zA-Z_-]+:.*?##.*$$)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

###

data-download: ## Download data.
data-download: SkyNet_Data
SkyNet_Data:
	-(\
	test -n "$${HOST_DATA_SKYNET}" \
	&& test -n "$${PATH_DATA_SKYNET}" \
	&& scp -r $${HOST_DATA_SKYNET}:$${PATH_DATA_SKYNET} SkyNet_Data \
	)

docker-build: ## Build docker images.
docker-build: Dockerfile
	-( \
	docker build \
	--progress=plain \
	--build-arg UID_WORKER=$$UID \
	--build-arg GID_WORKER=`id -g` \
	-t skynet:dev . \
	)

docker-run-i: ## Run docker container interactively
docker-run-i:
	-(\
	docker run \
	-it \
	--rm \
	--gpus all \
	skynet:dev 'bash' \
	)

docker-run-train: ## Run docker container interactively
docker-run-train:
	-(\
	docker run \
	-it \
	--gpus all \
	-v $(PWD)/SkyNet_Data:/home/worker/SkyNet_Data \
	-v $(PWD)/train.py:/home/worker/train.py \
	skynet:dev ./entrypoints/train.bash \
	)
#	
