# Useful hacks
export DATESTAMP := $(shell date +"%H%d%m%g")
TIMESTAMP = $(shell date +"%T")
copy_file = cp $1 $2
copy_dir = cp -r $1 $2
remove_file = rm -rf $1
remove_dir = rm -rf $1
mk_dir = mkdir -p $1
read_file = cat $1 2> /dev/null
make_dir_link = ln -s $1 $2
make_link = ln -s $1 $2
print_lines = @echo $1 | tr ' ' '\n'
green = \\e[32m$1\\e[39m
print = @printf "$(call green,[$(TIMESTAMP)]) $1\n"
cmd_separator = ;
HIDE = > /dev/null
MUTE = @
RM = rm -rf

# Xilinx tool variables
VIVADO_RUN = $(XILINX_VIVADO)/bin/vivado
SCRIPTS_DIR = scripts
PRODUCTS_DIR = products

# Git variables
export GIT_SHA = $(shell git rev-parse --short HEAD)
export GIT_BRANCH = $(shell git symbolic-ref --short HEAD)
# RUNNER_TOKEN =
# RUNNER_URL =
# PIPELINE_TRIGGER = $(shell curl -X POST -F token=$(RUNNER_TOKEN) -F ref=$(GIT_BRANCH) $(RUNNER_URL))

# Vivado variables
VIV_PRJ_DIR = run
VIV_SCRIPTS_DIR = scripts
VIV_PROD_DIR = products
VIV_REPORTS_DIR = $(VIV_PROD_DIR)/reports
VIV_SRC = $(VIV_SCRIPTS_DIR)/package_ip.tcl
VIV_UPG = $(VIV_SCRIPTS_DIR)/upgrade_ip.tcl

# Description
.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make ip'
	@echo '    Create and package a Vivado IP'
	@echo '  make upgrade'
	@echo '    Upgrade an existing Vivado IP'
	@echo '  make clean-project'
	@echo '    Clean Vivado files produced in a previous run'
	@echo '  make clean-products'
	@echo '    Clean output products'
	@echo '  make gitlab-run-pipeline'
	@echo '    Run job at GitLab server - compile project and create artifacts'
	@echo '  make lib <LIB=[all | arithm | util | net]>'
	@echo '    Create and package specified libraries'
	@echo '  make clean-lib <LIB=[all | arithm | util | net]>'
	@echo '    Clean output products and project files for specified libraries'
	@echo ''

.PHONY: all ip upgrade clean-project clean-products gitlab-run-pipeline lib clean-lib
all: clean-project clean-products ip upgrade

ip:
	$(call print,Creating IP for Git SHA commit $(call green,$(GIT_SHA)))
	$(VIVADO_RUN) -mode batch -notrace -source $(VIV_SRC)

upgrade:
	$(call print,Upgrading IP for Git SHA commit $(call green,$(GIT_SHA)))
	$(VIVADO_RUN) -mode batch -notrace -source $(VIV_UPG)

clean-project:
	$(call print,Cleaning project for Git SHA commit $(call green,$(GIT_SHA)))
	$(RM) $(VIV_PRJ_DIR) vivado* .Xil *dynamic* *.log *.xpe *.mif

clean-products:
	$(call print,Cleaning products for Git SHA commit $(call green,$(GIT_SHA)))
	$(RM) $(VIV_REPORTS_DIR) $(VIV_PROD_DIR)

gitlab-run-pipeline:
	$(call print,Triggering remote runner for Git SHA commit $(call green,$(GIT_SHA)))
	@echo Run remote pipeline at $(GIT_BRANCH).
	$(MUTE) $(PIPELINE_TRIGGER)

## This is not very elegant, but oh well. I'll probably figure out a better way to do this at some point
lib:
	@if [ $(LIB) = all ] || [ $(LIB) = util ]; then \
		for lib in $(UTIL_LIST); do \
			$(call print,Building utility IP Libraries for Git SHA commit $(call green,$(GIT_SHA))); \
			$(MAKE) -C $(UTIL_LIBRARY_PATH)$${lib} ip || exit $$?; \
		done \
	fi;
	@if [ $(LIB) = all ] || [ $(LIB) = arithm ]; then \
		 for lib in $(ARITHM_LIST); do \
			$(call print,Building arithmetic IP Libraries for Git SHA commit $(call green,$(GIT_SHA))); \
			$(MAKE) -C $(ARITHM_LIBRARY_PATH)$${lib} ip || exit $$?; \
		done \
	fi;
	@if [ $(LIB) = all ] || [ $(LIB) = net ]; then \
		for lib in $(NET_LIST); do \
			$(call print,Building network IP Libraries for Git SHA commit $(call green,$(GIT_SHA))); \
			$(MAKE) -C $(NET_LIBRARY_PATH)$${lib} ip || exit $$?; \
		done \
	fi;


clean-lib:
	@if [ $(LIB) = all ] || [ $(LIB) = util ]; then \
		for lib in $(UTIL_LIST); do \
			$(call print,Cleaning utility IP Libraries for Git SHA commit $(call green,$(GIT_SHA))); \
			$(MAKE) -C $(UTIL_LIBRARY_PATH)$${lib} clean-project clean-products || exit $$?; \
		done \
	fi;
	@if [ $(LIB) = all ] || [ $(LIB) = arithm ]; then \
		 for lib in $(ARITHM_LIST); do \
			$(call print,Cleaning arithmetic IP Libraries for Git SHA commit $(call green,$(GIT_SHA))); \
			$(MAKE) -C $(ARITHM_LIBRARY_PATH)$${lib} clean-project clean-products || exit $$?; \
		done \
	fi;
	@if [ $(LIB) = all ] || [ $(LIB) = net ]; then \
		for lib in $(NET_LIST); do \
			$(call print,Cleaning network IP Libraries for Git SHA commit $(call green,$(GIT_SHA))); \
			$(MAKE) -C $(NET_LIBRARY_PATH)$${lib} clean-project clean-products || exit $$?; \
		done \
	fi;
