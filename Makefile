ifeq ($(OS),Windows_NT)
	SHELL := pwsh.exe
else
	SHELL := pwsh
endif

.SHELLFLAGS := -NoProfile -Command
ELIXIR_SOURCE_PATH := ld52/
GITHUB_TOKEN :=
.PHONY: all lint clean test act run

all: lint
run: elixir_run
test: elixir_test
# elixir/mix
elixir_clean:
	cd $(ELIXIR_SOURCE_PATH); mix ecto.drop
elixir_migrate:
	cd $(ELIXIR_SOURCE_PATH); mix ecto.migrate
elixir_deps:
	cd $(ELIXIR_SOURCE_PATH); mix deps.get
	cd $(ELIXIR_SOURCE_PATH); mix ecto.create
elixir_run: elixir_deps
	cd $(ELIXIR_SOURCE_PATH); mix phx.server
elixir_runi:
	Remove-Alias -Name iex -force; cd $(ELIXIR_SOURCE_PATH); iex -S mix phx.server
elixir_test: elixir_deps
	cd $(ELIXIR_SOURCE_PATH); mix test
elixir_lint:
	cd $(ELIXIR_SOURCE_PATH); mix format
# Act/github workflows
ACT_ARTIFACT_PATH := /workspace/.act 
act: act_lint act_lfs
act_lint:
	act -j lint --artifact-server-path $(ACT_ARTIFACT_PATH)
act_lfs:
	act -s GITHUB_TOKEN=$(GITHUB_TOKEN) -j lfsvalidate --artifact-server-path $(ACT_ARTIFACT_PATH)
act_elixir:
	act -j test --artifact-server-path $(ACT_ARTIFACT_PATH)
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
clean: elixir_clean