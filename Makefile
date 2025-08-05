SHELL := /bin/zsh
export TERM := xterm-256color
export MAKE_TERMOUT := 1

BLUE := \\033[1;34m
RESET := \\033[0m

.PHONY: startdocker stopdocker runstructurizr stopstructurizr buildapi testapi runapi stopapi testcli runcli testspa cleandocs generatepuml generatedocs generate_svg generate_drawio generate_py generate_md

# ========== Configuration ==========

#General
ECOPATH := /Users/oli/home/Ecosystem/
DOCPATH := documentation/
PICPATH := $(DOCPATH)pictures/
CLIPATH := cliclient/src/
APIPATH := restapi/
PYTHONPATH=cliclient/src python cliclient/src/Eco/ecosystem.py 

# restapi setup
IMAGE_NAME := eco-fastapi-app
APICONTAINER_NAME := eco-fastapi-container
APIPORT := 8040

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
buildapi:
	@printf "$(BLUE)*** build fastapi container $(RESET)\\n"
	docker build -t $(IMAGE_NAME) -f $(APIPATH)Dockerfile $(APIPATH)

# test Ecosystem API
testapi:
	@printf "$(BLUE)*** test fastapi container on port $(APIPORT)$(RESET)\\n"
	hurl $(APIPATH)app/ecoapi.hurl

# run Ecosystem API
runapi:
	@printf "$(BLUE)*** run fastapi container on port $(APIPORT)$(RESET)\\n"
	docker run -dit --rm --name $(APICONTAINER_NAME) -p $(APIPORT):$(APIPORT) $(IMAGE_NAME)

# stop restapi container
stopapi:
	@printf "$(BLUE)*** stop fastapi container $(RESET)\\n"
	docker stop $(APICONTAINER_NAME) || true

# test CLI client
testcli:
	@printf "$(BLUE)*** pytest execution$(RESET)\\n"
	PYTHONPATH=$(CLIPATH) pytest -v

# execute CLI client
runcli:
	@printf "$(BLUE)*** python ecosystem execution$(RESET)\\n"
	PYTHONPATH=$(CLIPATH) python $(CLIPATH)Eco/ecosystem.py 

# test SPA client
testspa:

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




