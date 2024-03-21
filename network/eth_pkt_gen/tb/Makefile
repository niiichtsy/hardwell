# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

TOPLEVEL_LANG ?= verilog

SIM ?= icarus

DUT = lfsr

ROOT_DIR ?= $(shell pwd)/..

VERILOG_SOURCES = $(ROOT_DIR)/src/lfsr.sv

RUN_ARGS += -y $(XILINX_VIVADO)/data/verilog/pwropt/pwropt_unisims/

MODULE = $(DUT)_tb
TOPLEVEL = $(DUT)

include $(shell cocotb-config --makefiles)/Makefile.sim
