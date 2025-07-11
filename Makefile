SHELL := /bin/zsh
export TERM := xterm-256color
export MAKE_TERMOUT := 1

BLUE := \\033[1;34m
RESET := \\033[0m

.PHONY: startdocker stopdocker runstructurizr run run_cli run_api test test_cli test_api cleandocs generate_puml generatedocs generate_svg generate_drawio generate_py generate_md

# ========== Configuration ==========

#General
DOCPATH := documentation/
PICPATH := $(DOCPATH)pictures/
SRCPATH := cliclient/src/Eco/

# Draw.io setup
DRAWIOS := $(wildcard $(DOCPATH)*.drawio)
PNGS := $(DRAWIOS:.drawio=.png)

# strucurizr setup
DSL := $(DOCPATH)workspace.dsl
PUMLS := $(wildcard $(PICPATH)*.puml)
SVGS := $(PUMLS:.puml=.svg)

# Pyreverse setup
NAME := Ecosystem
PYFILES := $(wildcard $(SRCPATH)*.py)
CLASSES_IMG := $(DOCPATH)classes_$(NAME).png
PACKAGES_IMG := $(DOCPATH)packages_$(NAME).png

# pandoc setup
MDS := $(wildcard $(DOCPATH)*.md)
PDFS := $(MDS:.md=.pdf)

# ========== High-Level Targets ==========

# start colima for docker 
startdocker:
	@printf "$(BLUE)*** start docker with colima\\n"
	colima start

# stop docker
stopdocker:
	@printf "$(BLUE)*** stop docker with colima\\n"
	colima stop

# run structurizr container
runstructurizr:
	@printf "$(BLUE)*** run structurizr as docker container\\n"
	docker run -dit --rm start\
		-p 8080:8080 \
		-v /Users/oli/home/Ecosystem/documentation:/usr/local/structurizr \
		structurizr/lite

# ===== run api and cli
run: runapi runcli

# execute python Ecosystem API
run_api:

# execute python CLI client
run_cli:
	@printf "$(BLUE)*** python ecosystem execution\\n"
	PYTHONPATH=src python $(SRCPATH)ecosystem.py 

# ===== test api and cli
test: testapi testcli

# test Ecosystem API
test_api:

# test CLI client
test_cli:
	@printf "$(BLUE)*** pytest execution\\n"
	PYTHONPATH=src pytest -v

# ===== clean all docs artifacts
cleandocs:
	@printf "$(BLUE)*** Removing generated files...$(RESET)\\n"
	rm -f $(PNGS) $(PUMLS) $(SVGS) $(CLASSES_IMG) $(PACKAGES_IMG) $(PDFS)

# intermediate step: generate all puml files from c4 .dsl file
generate_puml:
	@printf "$(BLUE)*** generate .puml files from $(DSL)$(RESET)\\n"
	structurizr.sh export -workspace $(DSL) -format plantuml -output $(PICPATH)

# ===== generate diagrams from drawio and Python = pdf from markdown -> assume generate_puml has been run
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
	pyreverse -ASmy -o png -d $(DOCPATH) -p $(NAME) $(SRCPATH)

# Pattern rule: convert .md → .pdf
%.pdf: %.md
	@printf "$(BLUE)*** Converting $< → $@$(RESET)\\n"
	pandoc --resource-path=$(DOCPATH) $< -o $@




