SHELL := /bin/zsh
export TERM := xterm-256color
export MAKE_TERMOUT := 1

BLUE := \\033[1;34m
RESET := \\033[0m

.PHONY: clean run test docs generate_drawio generate_py generate_md

# ========== Configuration ==========

# Draw.io setup
DOCPATH := documentation/
DRAWIOS := $(wildcard $(DOCPATH)*.drawio)
PNGS := $(DRAWIOS:.drawio=.png)

# Pyreverse setup
NAME := Ecosystem
SRCPATH := src/Eco/
PYFILES := $(wildcard $(SRCPATH)*.py)
CLASSES_IMG := $(DOCPATH)classes_$(NAME).png
PACKAGES_IMG := $(DOCPATH)packages_$(NAME).png

# pandoc setup
MDS := $(wildcard $(DOCPATH)*.md)
PDFS := $(MDS:.md=.pdf)

# ========== High-Level Targets ==========

# clean all docs artifacts
clean:
	@printf "$(BLUE)*** Removing generated files...$(RESET)\\n"
	rm -f $(PNGS) $(CLASSES_IMG) $(PACKAGES_IMG) $(PDFS)

# execute python 
run:
	@printf "$(BLUE)*** python ecosystem execution\\n"
	PYTHONPATH=src python src/Eco/ecosystem.py 

# execute pytest in current folders
test:
	@printf "$(BLUE)*** pytest execution\\n"
	PYTHONPATH=src pytest -v

# generate diagrams from drawio and Python = pdf from markdown
docs: generate_drawio generate_py generate_md

# Only build drawio PNGs when drawio files changed
generate_drawio: $(PNGS)

# Build Python class diagrams from .py files if changed
generate_py: $(CLASSES_IMG) $(PACKAGES_IMG)

# Only build md to pdf when pdf files changed
generate_md: $(PDFS)

# ========== Draw.io Rules ==========

# Pattern rule: convert .drawio → .png
%.png: %.drawio
	@printf "$(BLUE)*** Converting $< → $@$(RESET)\\n"
	/Applications/draw.io.app/Contents/MacOS/draw.io -x -f png -o $@ $<

# ========== Pyreverse Rules ==========

# Rule: If any .py file changes, regenerate the .png diagrams
$(CLASSES_IMG) $(PACKAGES_IMG): $(PYFILES)
	@printf "$(BLUE)*** Generating class diagrams with pyreverse...$(RESET)\\n"
	pyreverse -ASmy -o png -d $(DOCPATH) -p $(NAME) $(SRCPATH)

# ========== Md Rules ==========

# Pattern rule: convert .md → .pdf
%.pdf: %.md
	@printf "$(BLUE)*** Converting $< → $@$(RESET)\\n"
	pandoc --resource-path=$(DOCPATH) $< -o $@




# Target 1: Start Colima (Docker backend for macOS)
start:
	colima start

	docker run -dit --rm \
		-p 8080:8080 \
		-v /Users/oli/home/Ecosystem/documentation:/usr/local/structurizr \
		structurizr/lite

# Target 2: Export PlantUML from Structurizr DSL
dsl2puml:
	./structurizr.sh export \
		-workspace workspace.dsl \
		-format plantuml \
		-output pictures/

# Target 3: Generate SVGs from PUML files
puml2svg:
	plantuml -tsvg pictures/*.puml

# Target 4: Convert Markdown to PDF
generate-pdf:
	pandoc systemcontext.md --resource-path=documentation -o systemcontext.pdf

# Target 5: Convert Markdown to PDF
stop:
	colima stop


# Combined target to run everything in sequence
all: start dsl2puml puml2svg generate-pdf
