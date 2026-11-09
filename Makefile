SHELL := /bin/bash
.DEFAULT_GOAL := help

DART  ?= dart
JASPR ?= jaspr

.PHONY: help deps format format-check analyze test build gate serve clean

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

test: ## Unit tests
	@if [ -d test ]; then $(DART) test; else echo "No test/ folder yet."; fi

build: ## Compile the server and the client with Jaspr
	$(JASPR) build

gate: deps format-check analyze test build ## Every check that must pass before a commit

serve: ## Run the development server on http://localhost:8080
	$(JASPR) serve

clean: ## Remove build output
	rm -rf build .dart_tool/build
