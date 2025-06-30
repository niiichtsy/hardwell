# Useful hacks
red = \\e[31m$1\\e[39m
green = \\e[32m$1\\e[39m
yellow = \\e[33m$1\\e[39m
cyan = \\e[36m$1\\e[39m

# Helper print functions: regular, no newline and no timestamp
print = printf "$(call green,[$(TIMESTAMP)]) $1\n"
print_nonl = printf "$(call green,[$(TIMESTAMP)]) $1"
print_nots = printf "$1\n"

# Aliases & useful env variables
export DATESTAMP := $(shell date +"%H%d%m%g")
TIMESTAMP = $(shell date +"%T")
HIDE = >/dev/null
2HIDE = &>/dev/null
MUTE = @
RM = rm -rf
export SELF_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Git variables
export GIT_SHA = $(shell git rev-parse --short HEAD)
export GIT_BRANCH = $(shell git symbolic-ref --short HEAD)
# RUNNER_TOKEN =
# RUNNER_URL =
# PIPELINE_TRIGGER = $(shell curl -X POST -F token=$(RUNNER_TOKEN) -F ref=$(GIT_BRANCH) $(RUNNER_URL))

# Vivado variables
VIV_RUN = $(XILINX_VIVADO)/bin/vivado
export VIV_SCRIPTS_DIR = scripts
export VIV_PRJ_DIR = run
export VIV_PROD_DIR = products
export VIV_SRC_DIR = src
VIV_IP = $(VIV_SCRIPTS_DIR)/package_ip.tcl
export PART := 

# Library lists
ARITHM_LIBRARY_PATH := $(ROOT_DIR)/arithmetic/
ARITHM_LIST ?=
UTIL_LIBRARY_PATH := $(ROOT_DIR)/utils/
UTIL_LIST ?=
NET_LIBRARY_PATH := $(ROOT_DIR)/network/
NET_LIST ?=
LIB ?= all

# Description
.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make ip'
	@echo '    Create and package Vivado IP'
	@echo '  make clean'
	@echo '    Clean Vivado projects files & output products produced in a previous run'
	@echo '  make gitlab-run-pipeline'
	@echo '    Run job at GitLab server - compile project and create artifacts'
	@echo '  make lib <LIB=[all | arithm | util | net]>'
	@echo '    Create and package specified libraries'
	@echo '  make clean-lib <LIB=[all | arithm | util | net]>'
	@echo '    Clean Vivado projects files & output products for specified libraries'
	@echo ''

.PHONY: all gitlab-run-pipeline lib clean-lib 

lib:
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "util" ]; then \
		$(call print,Building $(call cyan, utility) IP Libraries for Git SHA commit $(call green,$(GIT_SHA))...); \
		for lib in $(UTIL_LIST); do \
			$(MAKE) -C $(UTIL_LIBRARY_PATH)$${lib} ip || exit $$?; \
		done \
	fi;
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "arithm" ]; then \
		$(call print,Building $(call cyan, arithmetic) IP Libraries for Git SHA commit $(call green,$(GIT_SHA))...); \
		for lib in $(ARITHM_LIST); do \
			$(MAKE) -C $(ARITHM_LIBRARY_PATH)$${lib} ip || exit $$?; \
		done \
	fi;
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "net" ]; then \
		$(call print,Building $(call cyan, network) IP Libraries for Git SHA commit $(call green,$(GIT_SHA))...); \
		for lib in $(NET_LIST); do \
			$(MAKE) -C $(NET_LIBRARY_PATH)$${lib} ip || exit $$?; \
		done \
	fi;

clean-lib:
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "util" ]; then \
		$(call print,Cleaning $(call cyan, utility) IP Libraries for Git SHA commit $(call green,$(GIT_SHA))...); \
		for lib in $(UTIL_LIST); do \
			$(MAKE) -C $(UTIL_LIBRARY_PATH)$${lib} clean || exit $$?; \
		done \
	fi;
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "arithm" ]; then \
		$(call print,Cleaning $(call cyan, arithmetic) IP Libraries for Git SHA commit $(call green,$(GIT_SHA))...); \
		for lib in $(ARITHM_LIST); do \
			$(MAKE) -C $(ARITHM_LIBRARY_PATH)$${lib} clean || exit $$?; \
		done \
	fi;
	@if [ "$(LIB)" = "all" ] || [ "$(LIB)" = "net" ]; then \
		$(call print,Cleaning $(call cyan, network) IP Libraries for Git SHA commit $(call green,$(GIT_SHA))...); \
		for lib in $(NET_LIST); do \
			$(MAKE) -C $(NET_LIBRARY_PATH)$${lib} clean || exit $$?; \
		done \
	fi;

gitlab-run-pipeline:
	@$(call print,Triggering remote runner for Git SHA commit $(call green,$(GIT_SHA))...)
	@echo Run remote pipeline at $(GIT_BRANCH).
	@$(MUTE) $(PIPELINE_TRIGGER)

