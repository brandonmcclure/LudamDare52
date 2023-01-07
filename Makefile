ifeq ($(OS),Windows_NT)
	SHELL := pwsh.exe
else
	SHELL := pwsh
endif

.SHELLFLAGS := -NoProfile -Command
ELIXIR_SOURCE_PATH := ld52/
.PHONY: all lint clean test act run

all: lint
run: elixir_run
test: elixir_test
# elixir/mix
elixir_deps:
	cd $(ELIXIR_SOURCE_PATH); mix deps.get
	cd $(ELIXIR_SOURCE_PATH); mix tailwind.install
	cd $(ELIXIR_SOURCE_PATH); mix ecto.create
elixir_run:
	cd $(ELIXIR_SOURCE_PATH); mix phx.server
elixir_runi:
	cd $(ELIXIR_SOURCE_PATH); iex -S mix phx.server
elixir_test: elixir_deps
	cd $(ELIXIR_SOURCE_PATH); mix test
# Act/github workflows
ACT_ARTIFACT_PATH := /workspace/.act 
act: lint
act_lint:
	act --artifact-server-path $(ACT_ARTIFACT_PATH)

# Linting
lint: lint_mega

lint_mega:
	docker run -v $${PWD}:/tmp/lint oxsecurity/megalinter:v6
lint_goodcheck:
	docker run -t --rm -v $${PWD}:/work sider/goodcheck check
lint_goodcheck_test:
	docker run -t --rm -v $${PWD}:/work sider/goodcheck test
lint_makefile:
	docker run -v $${PWD}:/tmp/lint -e ENABLE_LINTERS=MAKEFILE_CHECKMAKE oxsecurity/megalinter-ci_light:v6.10.0
clean:
	'Not implemented'