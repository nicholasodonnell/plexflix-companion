include .env

SHELL := /bin/bash
PLEXFLIX_COMPANION_DOCKER_COMPOSE_COMMON_FILE := docker-compose.common.yml
PLEXFLIX_COMPANION_DOCKER_COMPOSE_HELPERS_FILE := docker-compose.helpers.yml
PLEXFLIX_COMPANION_DOCKER_COMPOSE_NZBGET_FILE := ./nzbget/docker-compose.nzbget.yml
PLEXFLIX_COMPANION_DOCKER_COMPOSE_RADARR_FILE := ./radarr/docker-compose.radarr.yml
PLEXFLIX_COMPANION_DOCKER_COMPOSE_RCLONE_FILE := ./rclone/docker-compose.rclone.yml
PLEXFLIX_COMPANION_DOCKER_COMPOSE_SONARR_FILE := ./sonarr/docker-compose.sonarr.yml
PLEXFLIX_COMPANION_DOCKER_COMPOSE_TAUTULLI_FILE := ./tautulli/docker-compose.tautulli.yml
PLEXFLIX_COMPANION_PROJECT_DIRECTORY := $(shell pwd)
PLEXFLIX_COMPANION_PROJECT_NAME := $(if $(PLEXFLIX_COMPANION_PROJECT_NAME),$(PLEXFLIX_COMPANION_PROJECT_NAME),plexflix-companion)

define PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS
	--file ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_COMMON_FILE} \
	--file ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_HELPERS_FILE} \
	--file ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_NZBGET_FILE} \
	--file ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_RADARR_FILE} \
	--file ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_RCLONE_FILE} \
	--file ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_SONARR_FILE} \
	--file ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_TAUTULLI_FILE} \
	--log-level ERROR \
	--project-directory $(PLEXFLIX_COMPANION_PROJECT_DIRECTORY) \
	--project-name $(PLEXFLIX_COMPANION_PROJECT_NAME)
endef

get_service_health = $$(docker inspect --format {{.State.Health.Status}} $(PLEXFLIX_COMPANION_PROJECT_NAME)-$(1))

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

build: ## build plexflix companion images
ifndef service
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		build \
			--force-rm \
			--pull;
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		pull \
			--ignore-pull-failures;
else
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		build \
			--force-rm \
			$(service)
endif

clean: ## remove plexflix companion images & containers
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		down \
			--remove-orphans \
			--rmi all \
			--volumes

down: ## bring plexflix companion down
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		down \
			--remove-orphans \
			--volumes

exec: ## run a command against a running service
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		exec \
			$(service) \
				$(cmd)

fuse-shared-mount: ## make shared fuse mount
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		run \
			-e MOUNT_DIR=$(dir) \
			fuse-shared-mount

logs: ## view the logs of one or more running services
ifndef file
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		logs \
			--follow \
			$(service)
else
	@echo "logging output to $(file)";
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		logs \
			--follow \
			$(service) > $(file)
endif

mount-health: ## check mount health
	@echo "rclone: $(call get_service_health,rclone)"

	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		run \
			list

restart: ## restart a service
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
	restart \
		$(service)

rclone-setup: ## create rclone configuration files
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		run \
			--entrypoint "rclone --config=\"/config/.rclone.conf\" config" \
			--publish 53682:53682 \
			rclone

stop: ## stop a service
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
	stop \
		$(service)

up: ## bring plexflix companion up
ifndef service
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		up \
			--detach \
			--remove-orphans \
			rclone

	@$(call wait_until_service_healthy,rclone)

	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		up \
			--detach \
			--remove-orphans \
			nzbget \
			radarr \
			sonarr \
			tautulli
else
	@docker-compose ${PLEXFLIX_COMPANION_DOCKER_COMPOSE_ARGS} \
		up \
			--detach \
			--remove-orphans \
			$(service)
endif

.PHONY: \
	help \
	build \
	clean \
	down \
	exec \
	fuse-shared-mount \
	logs \
	mount-health \
	restart \
	rclone-setup \
	stop \
	up
