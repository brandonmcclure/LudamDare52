ifeq ($(OS),Windows_NT)
	SHELL := pwsh.exe
else
	SHELL := pwsh
endif

.SHELLFLAGS := -NoProfile -Command
.PHONY: all lint clean test act

all: lint

ACT_ARTIFACT_PATH := /workspace/.act 
act: lint
act_lint:
	act --artifact-server-path $(ACT_ARTIFACT_PATH)
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
test:
	'Not implemented'