# NOTE: I've used as guidelines for Makefile following pages:
# * https://dev.to/flpslv/using-makefiles-to-build-and-publish-docker-containers-7c8
# * https://jmkhael.io/makefiles-for-your-dockerfiles/

#Import environment
env = default
include make_env-$(env)

#Dockerfile vars
target    ?= vivado
version   ?= 2020.1
suffix    ?= $(env)
base      ?= ubuntu
base_ver  ?= 18.04
base_libs ?= "libx11-6"
add_apps  ?= "git"
distr_data?= Distribs/Xilinx_Unified_2020.1_0602_1208
workspace = $(target)-$(version)-$(suffix)
user_id   = $(shell id -u)

#Make vars
IMAGENAME =  $(target)
REPO      =  godhart

DISTRFULLNAME=$(REPO)/$(IMAGENAME)-distr-$(base)-$(base_ver):$(version)
CONFFULLNAME=$(REPO)/$(IMAGENAME)-$(suffix)-conf:$(version)
INSTALLFULLNAME=$(REPO)/$(IMAGENAME)-$(suffix)-install:$(version)
IMAGEFULLNAME=$(REPO)/$(IMAGENAME)-$(suffix):$(version)

DISTR_DATA=  $(distr_data)
WORKSPACE =  $(workspace)

IMPORT_PATH = $(WORKSPACE)/$(WORKSPACE).tar 

.PHONY: debug help distr conf install image all tar import prune clean clean_all version test_sim test_synth simulate bitstream gui check_conf

.DEFAULT_GOAL := image

all: distr conf image

debug:
	@echo "env             = $(env)"
	@echo "  -- Docker vars --"
	@echo "target          = $(target)"
	@echo "version         = $(version)"
	@echo "suffix          = $(suffix)"
	@echo "base            = $(base)"
	@echo "base_ver        = $(base_ver)"
	@echo "base_libs       = $(base_libs)"
	@echo "add_apps        = $(add_apps)"
	@echo "distr_data      = $(distr_data)"
	@echo "workspace       = $(workspace)"
	@echo "user_id         = $(user_id)"
	@echo "  -- Make vars --"
	@echo "IMAGENAME       = $(IMAGENAME)"
	@echo "REPO            = $(REPO)"
	@echo "DISTRFULLNAME   = $(DISTRFULLNAME)"
	@echo "CONFFULLNAME    = $(CONFFULLNAME)"
	@echo "INSTALLFULLNAME = $(INSTALLFULLNAME)"
	@echo "IMAGEFULLNAME   = $(IMAGEFULLNAME)"
	@echo "DISTR_DATA      = $(DISTR_DATA)"
	@echo "WORKSPACE       = $(WORKSPACE)"
	@echo "PWD             = $(PWD)"

help:
	@echo "Makefile arguments:"
	@echo ""
	@echo "env          - Make Environment Suffix Name"
	@echo "-e target    - Override Target Software Name"
	@echo "-e version   - Override Target Software Version"
	@echo "-e suffix    - Override Image Suffix Name"
	@echo "-e base      - Override Base Image"
	@echo "-e base_ver  - Override Base Image Version"
	@echo "-e base_libs - Override Required libs list before installation"
	@echo "-e add_apps  - Override Additional apps list after installation"
	@echo ""
	@echo "Makefile commands:"
	@echo "debug"       - Debug make - print variables
	@echo "distr        - Prepare distr image with distributive data"
	@echo " -- NOTE: conf,install,image,tar depends on distr image but won't make it"
	@echo "conf         - Prepare configuration file for installation"
	@echo "install      - Make installation image"
	@echo "image        - Make final image with all additional apps and user setup"
	@echo "all          - Make distr and then final image"
	@echo "tar          - Export final image into tar to share with others"
	@echo "import       - Imports tar as final image"
	@echo "prune        - Remove all docker images"
	@echo "clean        - prune + remove build artifacts"
	@echo "clean_all    - clean + remove exported image"
	@echo " -- NOTE: all below depends on final image but won't make it"
	@echo "version      - Print installed software version"
	@echo "test_sim     - Test simulation"
	@echo "test_synth   - Test synthesis"
	@echo "test_clean   - Clean tests data"
	@echo "simulate     - Do simulation"
	@echo "bitstream    - Make bitstream"

# TODO: download distr data

distr: Dockerfile.$(target)-distr $(DISTR_DATA)
	@echo "*" > .dockerignore
	@echo "!$(DISTR_DATA)" >> .dockerignore
	@echo "!$(DISTR_DATA)/**/*" >> .dockerignore

	docker build -t "$(DISTRFULLNAME)" -f Dockerfile.$(target)-distr \
	--build-arg BASE="$(base):$(base_ver)" \
	--build-arg BASE_LIBS=$(base_libs) \
	--build-arg DISTR_DATA=$(distr_data) \
	.

conf: Dockerfile.$(target)-conf config.sh

	mkdir -p $(WORKSPACE)
	rm -f $(WORKSPACE)/install_config.txt

	@echo "*" > .dockerignore
	@echo "!config.sh" >> .dockerignore

	docker build -t $(CONFFULLNAME) -f Dockerfile.$(target)-conf \
	--build-arg BASE=$(DISTRFULLNAME) \
	--build-arg USER_ID=$(user_id) \
	.
	
	docker run --rm -i -t -v "$(PWD)/$(WORKSPACE)":/home/$(target)/workspace "$(CONFFULLNAME)" /bin/bash /tmp/config.sh

$(WORKSPACE)/install_config.txt:
	@echo $(shell test ! -e $(WORKSPACE)/install_config.txt && echo -n "run 'make conf ...'")
	CONF = $(shell test -e $(WORKSPACE)/install_config.txt)

check_conf: $(WORKSPACE)/install_config.txt
	@echo "configuration file is at place"

install: Dockerfile.$(target)-install check_conf

	@echo "*" > .dockerignore
	@echo "!$(WORKSPACE)/install_config.txt" >> .dockerignore

	docker build -t $(INSTALLFULLNAME) -f Dockerfile.$(target)-install \
	--build-arg BASE=$(DISTRFULLNAME) \
	--build-arg WOKRKSPACE=$(workspace) \
	.

image: install Dockerfile.$(target)

	@echo "*" > .dockerignore
	docker build -t "$(IMAGEFULLNAME)" -f Dockerfile.$(target) \
	--build-arg BASE=$(INSTALLFULLNAME) \
	--build-arg USER_ID=$(user_id) \
	--build-arg ADD_APPS=$(add_apps) \
	.

tar: image
	mkdir -p $(WORKSPACE)
	rm -f $(WORKSPACE)/$(WORKSPACE).tar
	docker container rm --force $(target)-export
	docker run --name $(target)-export "$(IMAGEFULLNAME)" echo
	docker export $(target)-export > $(WORKSPACE)/$(WORKSPACE).tar
	docker container rm --force $(target)-export

import:
	docker import $(IMPORT_PATH) "$(IMAGEFULLNAME)"

prune:
	docker rmi $(IMAGEFULLNAME)
	docker rmi $(INSTALLFULLNAME)
	docker rmi $(CONFFULLNAME)
	docker rmi $(DISTRFULLNAME)

clean: prune
	rm -f $(WORKSPACE)/install_config.txt

clean_all: clean
	rm -f $(WORKSPACE)/$(WORKSPACE).tar

version:
	cd examples/version && make IMAGE="$(IMAGEFULLNAME)"

test_sim:
	cd examples/sim && make IMAGE="$(IMAGEFULLNAME)"

test_synth:
	cd examples/synth && make IMAGE="$(IMAGEFULLNAME)"

test_clean:
	cd examples/synth && make clean IMAGE="$(IMAGEFULLNAME)"

simulate:

bitstream:

gui:
