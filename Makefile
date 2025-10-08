SHELL := /bin/zsh
export TERM := xterm-256color
export MAKE_TERMOUT := 1

# -------------------------------
# alle Variablen aus der nvim/.env exportieren
# -------------------------------
TF_ENV_FILE := /Users/oli/.config/nvim/.env
export $(shell sed 's/=.*//' $(TF_ENV_FILE))

BLUE := \\033[1;34m
RESET := \\033[0m

# -------------------------------
# Load environment variables from .env if present
# -------------------------------
ifneq (,$(wildcard .env))
    include .env
    export
endif

.PHONY: tfinit tfapply tfdestroy startdocker stopdocker runstructurizr stopstructurizr dockerbuildapi dockerdeploy restartAWA dockerinfo testapi provisionapi dockerrunapi dockerstopapi dockerapirerun testcli runcli startnpmdev stopnpmdev cleandocs generatepuml generatedocs generate_svg generate_drawio generate_py generate_md

# ========== Configuration ==========

#General
ECOPATH := /Users/oli/home/Ecosystem/
DOCPATH := documentation/
PICPATH := $(DOCPATH)pictures/
CLIPATH := cliclient/src/
APIPATH := restapi/
SPAPATH := spa/
APIPATH := restapi/
PYTHONPATH=cliclient/src python cliclient/src/Eco/ecosystem.py 

# restapi setup
IMAGE_NAME := fastapi
IMAGE_TAG := latest
APICONTAINER_NAME := eco-fastapi-container
APIPORT := 8000
# These now come from the .env file via make
ACR_NAME ?= fastapiacr12345
RESOURCE_GROUP ?= rg-fastapi-app
WEBAPP_NAME ?= fastapi-webapp-12345
ACR_LOGIN_SERVER := $(ACR_NAME).azurecr.io
IMAGE := $(ACR_LOGIN_SERVER)/$(IMAGE_NAME):$(IMAGE_TAG)

# Draw.io setup
DRAWIOS := $(wildcard $(DOCPATH)*.drawio)
PNGS := $(DRAWIOS:.drawio=.png)

# strucurizr setup
DSL := $(DOCPATH)workspace.dsl
PUMLS := $(wildcard $(PICPATH)*.puml)
SVGS := $(PUMLS:.puml=.svg)
STRUCTURIZRCONTAINER_NAME := structurizr-container
STRUCTURIZRPORT := 8080

# Pyreverse setup
NAME := Ecosystem
PYFILES := $(wildcard $(CLIPATH)Eco/*.py)
CLASSES_IMG := $(DOCPATH)classes_$(NAME).png
PACKAGES_IMG := $(DOCPATH)packages_$(NAME).png

# pandoc setup
MDS := $(wildcard $(DOCPATH)*.md)
PDFS := $(MDS:.md=.pdf)

# Terraform targets

tfinit:
	@echo "Initializing Terraform..."
	terraform init

tfapply:
	@echo "Applying Terraform..."
	terraform apply -auto-approve

tfdestroy:
	@echo "Destroying Terraform..."
	terraform destroy -auto-approve

# ========== High-Level Targets ==========

# start colima for docker 
startdocker:
	@printf "$(BLUE)*** start docker with colima$(RESET)\\n"
	colima start

# stop docker
stopdocker:
	@printf "$(BLUE)*** stop docker with colima$(RESET)\\n"
	colima stop

# run structurizr container
runstructurizr:
	@printf "$(BLUE)*** run structurizr as docker container$(RESET)\\n"
	docker run -dit --rm \
		--name $(STRUCTURIZRCONTAINER_NAME) \
		-p $(STRUCTURIZRPORT):$(STRUCTURIZRPORT) \
		-v $(ECOPATH)documentation:/usr/local/structurizr \
		structurizr/lite

# stop strcuturizr container
stopstructurizr:
	@printf "$(BLUE)*** stop structurizr container $(RESET)\\n"
	docker stop $(STRUCTURIZRCONTAINER_NAME) || true

# build Ecosystem API container
dockerbuildapi:
	@printf "$(BLUE)*** build fastapi container: $(IMAGE_NAME):$(IMAGE_TAG) $(RESET)\\n"
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f $(APIPATH)Dockerfile $(APIPATH)

# docker tag, acr login + docker push
dockerdeploy:
	# tag image for ACR
	@echo "🏷️  Tagging image for ACR..."
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE)
	# Login to ACR
	@echo "🔑 Logging in to Azure Container Registry: $(ACR_NAME)"
	az acr login --name $(ACR_NAME)
	## Push image to ACR
	@echo "🚀 Pushing image to $(IMAGE)"
	docker push $(IMAGE)

## restart app service to force pull of latest image
restartAWA:
	@echo "♻️  Restarting Azure Web App: $(WEBAPP_NAME)"
	az webapp restart --name $(WEBAPP_NAME) --resource-group $(RESOURCE_GROUP)

dockerinfo:
	@echo "☁️  RESOURCE RG:  $(RESOURCE_GROUP)"
	@echo "📦  IMAGE:        $(IMAGE)"
	@echo "🏷️  TAG:          $(IMAGE_TAG)"
	@echo "🏢  ACR:          $(ACR_NAME)"
	@echo "🌐  WEB APP:      $(WEBAPP_NAME)"

# local test Ecosystem API
testapi:
	@printf "$(BLUE)*** test fastapi container on port $(APIPORT)$(RESET)\\n"
	cd $(APIPATH) && hurl --test test.hurl

# local provision api with initial data for testing
provisionapi:
	cd $(APIPATH) && hurl -v provision.hurl

# local run Ecosystem API
dockerrunapi:
	@printf "$(BLUE)*** run fastapi container on port $(APIPORT)$(RESET)\\n"
	docker run -dit --rm --name $(APICONTAINER_NAME) -p $(APIPORT):$(APIPORT) $(IMAGE_NAME)

# local stop restapi container
dockerstopapi:
	@printf "$(BLUE)*** stop fastapi container $(RESET)\\n"
	docker stop $(APICONTAINER_NAME) || true

# local stop api docker container, run api docker container

dockerapirerun: dockerstopapi dockerrunapi

# test CLI client
testcli:
	@printf "$(BLUE)*** pytest execution$(RESET)\\n"
	PYTHONPATH=$(CLIPATH) pytest -v

# execute CLI client
runcli:
	@printf "$(BLUE)*** python ecosystem execution$(RESET)\\n"
	PYTHONPATH=$(CLIPATH) python $(CLIPATH)Eco/ecosystem.py 

# start npm dev server
startnpmdev:
	cd $(SPAPATH) && npm run dev # default: http://localhost:5173 

# stop npm dev server
stopnpmdev:

# ===== clean all docs artifacts
cleandocs:
	@printf "$(BLUE)*** Removing generated files...$(RESET)\\n"
	rm -f $(PNGS) $(PUMLS) $(SVGS) $(CLASSES_IMG) $(PACKAGES_IMG) $(PDFS)

# intermediate step: generate all puml files from c4 .dsl file
generatepuml:
	@printf "$(BLUE)*** generate .puml files from $(DSL)$(RESET)\\n"
	structurizr.sh export -workspace $(DSL) -format plantuml -output $(PICPATH)

# ===== generate diagrams from drawio and Python = pdf from markdown -> assume generatepuml has been run
generatedocs: generate_drawio generate_svg generate_py generate_md

# Only build drawio PNGs when drawio files changed
generate_drawio: $(PNGS)

# Only build svg from dsl via puml when c4 model file changed
generate_svg: $(SVGS)

# Build Python class diagrams from .py files if changed
generate_py: $(CLASSES_IMG) $(PACKAGES_IMG)

# Only build md to pdf when md files changed
generate_md: $(PDFS)

# ========== Pattern Targets ==========

# Pattern rule: convert .drawio → .png
%.png: %.drawio
	@printf "$(BLUE)*** Converting $< → $@$(RESET)\\n"
	/Applications/draw.io.app/Contents/MacOS/draw.io -x -f png -o $@ $<

# pattern rule: convert .puml to .svg
$(PICPATH)%.svg: $(PICPATH)%.puml
	@printf "$(BLUE)*** Converting $< → $@$(RESET)\\n"
	plantuml -tsvg $<

# Pattern rule: If any .py file changes, regenerate the .png diagrams
$(CLASSES_IMG) $(PACKAGES_IMG): $(PYFILES)
	@printf "$(BLUE)*** Generating class diagrams with pyreverse...$(RESET)\\n"
	pyreverse -ASmy -o png -d $(DOCPATH) -p $(NAME) $(CLIPATH)Eco/

# Pattern rule: convert .md → .pdf
%.pdf: %.md
	@printf "$(BLUE)*** Converting $< → $@$(RESET)\\n"
	pandoc --resource-path=$(DOCPATH) $< -o $@




