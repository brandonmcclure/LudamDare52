ifeq ($(OS),Windows_NT)
	SHELL := pwsh.exe
else
	SHELL := pwsh
endif

.SHELLFLAGS := -NoProfile -Command
ELIXIR_SOURCE_PATH := ld52/
CD_TO_ELIXIR_SOURCE_PATH := cd $(ELIXIR_SOURCE_PATH);

TF_SOURCE_PATH := tf.azure/
CD_TO_TF_SOURCE_PATH := cd $(TF_SOURCE_PATH);
GITHUB_TOKEN :=
.PHONY: all lint clean test act run plan

all: lint
run: elixir_run
test: elixir_test
# elixir/mix
elixir_clean:
	$(CD_TO_ELIXIR_SOURCE_PATH)mix ecto.drop
elixir_migrate:
	$(CD_TO_ELIXIR_SOURCE_PATH)mix ecto.migrate
elixir_deps:
	$(CD_TO_ELIXIR_SOURCE_PATH)mix deps.get
	$(CD_TO_ELIXIR_SOURCE_PATH)mix ecto.create
elixir_run: elixir_deps
	$(CD_TO_ELIXIR_SOURCE_PATH)mix phx.server
elixir_runi:
	Remove-Alias -Name iex -force; $(CD_TO_ELIXIR_SOURCE_PATH)iex -S mix phx.server
elixir_test: elixir_deps
	$(CD_TO_ELIXIR_SOURCE_PATH)mix test
elixir_lint:
	$(CD_TO_ELIXIR_SOURCE_PATH)mix format
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

# Terraform
plan: tf_plan
tf_plan_sp:
	$(CD_TO_TF_SOURCE_PATH)terraform plan
tf_plan:
	$(CD_TO_TF_SOURCE_PATH)terraform plan -out=tfplan
tf_apply:
	$(CD_TO_TF_SOURCE_PATH)terraform apply -auto-approve tfplan; Move-Item tfplan "$$($$(Get-Date).ToString('yyyyMMddhhmmss')).tfplan"
tf_destroy:
	$(CD_TO_TF_SOURCE_PATH)terraform destroy -auto-approve

tf_init:
	$(CD_TO_TF_SOURCE_PATH)terraform init
tf_init_upgrade:
	$(CD_TO_TF_SOURCE_PATH)terraform init -upgrade

#docker 
REGISTRY_NAME := 
REPOSITORY_NAME := bmcclure89/
IMAGE_NAME := ld52
TAG := :latest

# Run Options
RUN_PORTS := -p 5063:8080

getcommitid:
	$(eval COMMITID = $(shell git log -1 --pretty=format:'%H'))

getbranchname:
	$(eval BRANCH_NAME = $(shell (git branch --show-current ) -replace '/','.'))

docker_build: getcommitid getbranchname
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) ./ld52 

docker_run:
	docker run -d $(RUN_PORTS) $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

docker_run_it:
	docker run -it $(RUN_PORTS) $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

docker_package:
	$$PackageFileName = "$$("$(IMAGE_NAME)" -replace "/","_").tar"; docker save $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -o $$PackageFileName

docker_size:
	docker inspect -f "{{ .Size }}" $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)
	docker history $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

docker_publish:
	docker login; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG); docker logout