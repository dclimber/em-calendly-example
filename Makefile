SHELL := /bin/bash
.DEFAULT_GOAL := help

DART     ?= dart
JASPR    ?= jaspr
SUPABASE ?= supabase
MODEL    := docs/internal-meeting-scheduler.em.hcl

# emhcl v0.17.0 or newer reads Event Modeling HCL v0.8.0. It is built into .tools/ on first use.
EMHCL_VERSION := v0.17.0
EMHCL         := .tools/emhcl-$(EMHCL_VERSION)

# Supabase runs on Docker. Without a Docker daemon, use the rootless podman socket when it exists.
ifeq ($(wildcard /var/run/docker.sock),)
PODMAN_SOCKET := /run/user/$(shell id -u)/podman/podman.sock
ifneq ($(wildcard $(PODMAN_SOCKET)),)
export DOCKER_HOST ?= unix://$(PODMAN_SOCKET)
endif
endif

.PHONY: help deps format format-check analyze test test-db model-check build gate serve db-up db-down db-reset clean

help: ## List the targets
	@grep -hE '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-14s %s\n", $$1, $$2}'

deps: ## Resolve the Dart dependencies
	$(DART) pub get

format: ## Format all Dart code
	$(DART) format .

format-check: ## Fail when a Dart file is not formatted
	$(DART) format --output=none --set-exit-if-changed .

analyze: ## Static analysis, including jaspr_lints; infos fail the build
	$(DART) analyze --fatal-infos

test: ## Unit and in-memory application tests
	$(DART) test --exclude-tags db

test-db: db-up ## Tests against the local Supabase Postgres (fstore-sql)
	$(DART) test --tags db

$(EMHCL):
	@mkdir -p .tools
	GOBIN=$(CURDIR)/.tools go install github.com/event-modeling-hcl/eventmodeling-hcl/cmd/emhcl@$(EMHCL_VERSION)
	mv .tools/emhcl $(EMHCL)

model-check: $(EMHCL) ## Validate the event model
	$(EMHCL) validate $(MODEL)

build: ## Compile the server and the client with Jaspr
	$(JASPR) build

gate: deps format-check analyze model-check test test-db build ## Every check that must pass before a commit

serve: db-up ## Run the development server on http://localhost:8080
	$(JASPR) serve

db-up: ## Start the local Supabase stack and apply the migrations
	@$(SUPABASE) status >/dev/null 2>&1 || $(SUPABASE) start
	$(SUPABASE) migration up

db-down: ## Stop the local Supabase stack
	$(SUPABASE) stop

db-reset: ## Recreate the local database from the migrations (deletes all events)
	$(SUPABASE) db reset

clean: ## Remove build output
	rm -rf build .dart_tool/build
