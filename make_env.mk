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
cmd_separator = ;
red = \\e[31m$1\\e[39m
green = \\e[32m$1\\e[39m
yellow = \\e[33m$1\\e[39m
print = printf "$(call green,[$(TIMESTAMP)]) $1\n"

# Aliases
HIDE = > /dev/null
MUTE = @
RM = rm -rf
SELF_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Git variables
export GIT_SHA = $(shell git rev-parse --short HEAD)
export GIT_BRANCH = $(shell git symbolic-ref --short HEAD)
# RUNNER_TOKEN =
# RUNNER_URL =
# PIPELINE_TRIGGER = $(shell curl -X POST -F token=$(RUNNER_TOKEN) -F ref=$(GIT_BRANCH) $(RUNNER_URL))

# Vivado variables
VIV_RUN = $(XILINX_VIVADO)/bin/vivado
VIV_SCRIPTS_DIR = scripts
VIV_PRJ_DIR = run
VIV_PROD_DIR = products
VIV_REPORTS_DIR = $(VIV_PROD_DIR)/reports
VIV_IP = $(VIV_SCRIPTS_DIR)/package_ip.tcl
VIV_UPG = $(VIV_SCRIPTS_DIR)/upgrade_ip.tcl

LIB ?= all

# Description
.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make ip'
	@echo '    Create and package a new Vivado IP'
	@echo '  make upgrade'
	@echo '    Upgrade an existing Vivado IP'
	@echo '  make clean'
	@echo '    Clean Vivado projects files & output products produced in a previous run'
	@echo '  make gitlab-run-pipeline'
	@echo '    Run job at GitLab server - compile project and create artifacts'
	@echo '  make lib <LIB=[all | arithm | util | net]>'
	@echo '    Create and package specified libraries'
	@echo '  make clean-lib <LIB=[all | arithm | util | net]>'
	@echo '    Clean Vivado projects files & output products for specified libraries'
	@echo ''

.PHONY: all ip upgrade clean gitlab-run-pipeline lib clean-lib
all: clean ip upgrade

ip: lib 
	@if [ -d $(VIV_PROD_DIR) ]; then \
	$(call print,IP $(call yellow,$(VIVADO_PROJ_NAME)) already built! Call $(call red,make upgrade) if you wish to upgrade it.); \
	else \
	$(call print,Creating IP $(call yellow,$(VIVADO_PROJ_NAME)) for Git SHA commit $(call green,$(GIT_SHA))...); \
	$(VIV_RUN) -mode batch -notrace -source $(VIV_IP); \
	fi; 

upgrade:
	@if [ ! -d $(VIV_PROD_DIR) ]; then \
	$(call print,IP $(call yellow,$(VIVADO_PROJ_NAME)) not yet built! Call $(call red,make ip) to build it first.); \
	else \
	$(call print,Upgrading IP $(call yellow,$(VIVADO_PROJ_NAME)) for Git SHA commit $(call green,$(GIT_SHA))...); \
	$(VIV_RUN) -mode batch -notrace -source $(VIV_UPG); \
	fi;

clean:
	@$(call print,Cleaning IP $(call yellow,$(VIVADO_PROJ_NAME)) for Git SHA commit $(call green,$(GIT_SHA))...)
	@$(RM) $(VIV_PRJ_DIR) vivado* .Xil *dynamic* *.log *.xpe *.mif \
	$(RM) $(VIV_REPORTS_DIR) $(VIV_PROD_DIR)

gitlab-run-pipeline:
	@$(call print,Triggering remote runner for Git SHA commit $(call green,$(GIT_SHA))...)
	@echo Run remote pipeline at $(GIT_BRANCH).
	@$(MUTE) $(PIPELINE_TRIGGER)

## This is not very elegant, but oh well. I'll probably figure out a better way to do this at some point
lib:
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "util" ]; then \
		$(call print,Building $(call red, utility) IP Libraries for Git SHA commit $(call green,$(GIT_SHA))...); \
		for lib in $(UTIL_LIST); do \
			$(MAKE) -C $(UTIL_LIBRARY_PATH)$${lib} ip || exit $$?; \
		done \
	fi;
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "arithm" ]; then \
		$(call print,Building $(call red, arithmetic) IP Libraries for Git SHA commit $(call green,$(GIT_SHA))...); \
		for lib in $(ARITHM_LIST); do \
			$(MAKE) -C $(ARITHM_LIBRARY_PATH)$${lib} ip || exit $$?; \
		done \
	fi;
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "net" ]; then \
		$(call print,Building $(call red, network) IP Libraries for Git SHA commit $(call green,$(GIT_SHA))...); \
		for lib in $(NET_LIST); do \
			$(MAKE) -C $(NET_LIBRARY_PATH)$${lib} ip || exit $$?; \
		done \
	fi;

clean-lib:
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "util" ]; then \
		$(call print,Cleaning $(call red, utility) IP Libraries for Git SHA commit $(call green,$(GIT_SHA))...); \
		for lib in $(UTIL_LIST); do \
			$(MAKE) -C $(UTIL_LIBRARY_PATH)$${lib} clean || exit $$?; \
		done \
	fi;
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "arithm" ]; then \
		$(call print,Cleaning $(call red, arithmetic) IP Libraries for Git SHA commit $(call green,$(GIT_SHA))...); \
		for lib in $(ARITHM_LIST); do \
			$(MAKE) -C $(ARITHM_LIBRARY_PATH)$${lib} clean || exit $$?; \
		done \
	fi;
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "net" ]; then \
		$(call print,Cleaning $(call red, network) IP Libraries for Git SHA commit $(call green,$(GIT_SHA))...); \
		for lib in $(NET_LIST); do \
			$(MAKE) -C $(NET_LIBRARY_PATH)$${lib} clean || exit $$?; \
		done \
	fi;

# Temporary helper function to update all scripts while I tweak them to perfection
update-scripts:
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "util" ]; then \
		for lib in $(UTIL_LIST); do \
			cp ./package_ip.tcl $(UTIL_LIBRARY_PATH)$${lib}/scripts/package_ip.tcl; \
			cp ./upgrade_ip.tcl $(UTIL_LIBRARY_PATH)$${lib}/scripts/upgrade_ip.tcl; \
		done \
	fi;
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "arithm" ]; then \
		for lib in $(ARITHM_LIST); do \
			cp ./package_ip.tcl $(ARITHM_LIBRARY_PATH)$${lib}/scripts/package_ip.tcl; \
			cp ./upgrade_ip.tcl $(ARITHM_LIBRARY_PATH)$${lib}/scripts/upgrade_ip.tcl; \
		done \
	fi;
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "net" ]; then \
		for lib in $(NET_LIST); do \
			cp ./package_ip.tcl $(NET_LIBRARY_PATH)$${lib}/scripts/package_ip.tcl; \
			cp ./upgrade_ip.tcl $(NET_LIBRARY_PATH)$${lib}/scripts/upgrade_ip.tcl; \
		done \
	fi;
