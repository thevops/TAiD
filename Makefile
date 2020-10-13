.RECIPEPREFIX +=
.ONESHELL:
SHELL:=/bin/bash
.SHELLFLAGS := -eu -o pipefail -c # exit if error in pipe

# optionally load env vars from .env
#include .env

args=$(filter-out $@,$(MAKECMDGOALS))

##
## ----------------------------------------------------------------------------
##   Test Ansible in Docker
## ----------------------------------------------------------------------------
##

DOCKER_IMAGE=ansible-docker-env
DOCKER_NETWORK_NAME=ansible-docker-net
DOCKER_NETWORK_SUBNET=172.20.0.0
DOCKER_CONTAINERS_PREFIX=ade_

#------------------------------------------#
##          Docker
#------------------------------------------#

docker-build:: ## Build Docker image
    [ -f docker/files/key ] && ssh-keygen -b 2048 -t rsa -q -N "" -C ansible-docker@env -f docker/files/key <<<y 2>&1 >/dev/null # non-interactive ssh without pass
    docker build -t $(DOCKER_IMAGE) -f docker/Dockerfile .

docker-start-env: ## Start Docker environment
    export DOCKER_IMAGE=$(DOCKER_IMAGE)
    export DOCKER_NETWORK_NAME=$(DOCKER_NETWORK_NAME)
    export DOCKER_NETWORK_SUBNET=$(DOCKER_NETWORK_SUBNET)
    export DOCKER_CONTAINERS_PREFIX=$(DOCKER_CONTAINERS_PREFIX)
    bash scripts/start-env.sh

docker-stop-env: ## Stop Docker environment
    docker stop -t1 $$(docker ps -a -q --filter="name=$(DOCKER_CONTAINERS_PREFIX)") # stop all containers

docker-clean: ## Clean Docker stuff
    docker image rm -f $(DOCKER_IMAGE)
    docker network rm $(DOCKER_NETWORK_NAME) || true

#------------------------------------------#
##
##          Ansible
#------------------------------------------#

test-connection: ## Test connection to hosts
    ansible-playbook -i ansible/inventory ansible/test.yml $(args)


#------------------------------------------#
##
##          Containers access
#------------------------------------------#

ssh-access: ## [host] Get into container over SSH
    @container_ip=$$(grep $(args) ansible/inventory | grep -Po 'ansible_host=\K[^ ]*')
    ssh -i docker/files/key root@$$container_ip

# -----------------------------   DO NOT CHANGE   -----------------------------
help:
    @grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) \
        | sed -e 's/^.*Makefile://g' \
        | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' \
        | sed -e 's/\[32m##/[33m/'
    @echo
    @echo -e '\033[01;31mFormat: make <TASK> -- "ARGS"\033[00m\n'

    @echo -e 'Optional args for Ansible:
    \t --check                      only check without changing files, etc.
    \t --diff                       show differences between source and remote
    \t --syntax-check               only check syntax of files
    \t --step                       one-step-at-a-time - confirm each task before running
    \t --extra-vars host=ONE_HOST   run task only for specific host
    '  


%:      # do not change
    @:    # do not change

.DEFAULT_GOAL := help
