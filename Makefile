include .env

SHELL := /bin/bash
PROJECT_DIRECTORY := $(shell pwd)
PROJECT_NAME := plexflix-companion

define DOCKER_COMPOSE_ARGS
	--log-level ERROR \
	--project-directory $(PROJECT_DIRECTORY) \
	--project-name $(PROJECT_NAME)
endef

get_service_health = $$(docker inspect --format {{.State.Health.Status}} $(1))

wait_until_service_healthy = { \
	echo "Waiting for $(1) to be healthy"; \
	until [[ $(call get_service_health,$(1)) != starting ]]; \
		do sleep 1; \
	done; \
	if [[ $(call get_service_health,$(1)) != healthy ]]; \
		then echo "$(1) failed health check"; \
		exit 1; \
	fi; \
}

help: ## usage
	@cat Makefile | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## build docker images
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		build \
			--force-rm \
			--parallel \
			--pull

clean: ## remove images & containers
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		down \
			--remove-orphans \
			--rmi all \
			--volumes

down: ## stop collection
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		down \
			--remove-orphans \
			--volumes

fuse-shared-mount: ## make shared fuse mount
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		run \
			-e MOUNT_DIR=$(dir) \
			fuse-shared-mount

logs: ## view the logs of one or more running services
ifndef file
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		logs \
			--follow \
			$(service)
else
	@echo "logging output to $(file)";
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		logs \
			--follow \
			$(service) > $(file)
endif

mount-health: ## check mount health
	@echo "rclone: $(call get_service_health,rclone)"

rclone-setup: ## create rclone configuration files
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		run \
			--entrypoint "rclone --config=\"/config/.rclone.conf\" config" \
			--publish 53682:53682 \
			rclone

up: ## start collection
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		up \
			--detach \
			--remove-orphans \
			rclone

	@$(call wait_until_service_healthy,rclone)

	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		up \
			--detach \
			--remove-orphans \
			nzbget \
			radarr \
			sonarr \
			tautulli

.PHONY: \
	help \
	build \
	clean \
	down \
	fuse-shared-mount \
	logs \
	mount-health \
	rclone-setup \
	up
