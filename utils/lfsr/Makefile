include ../../make_env.mk

# Vivado variables (user-defined)
export VIVADO_PROJ_NAME := lfsr
export VIVADO_VENDOR := niiichtsy
export VIVADO_LIBRARY := hardwell

# Core version 
export VERSION := 1.0

# IP library paths
export IP_LIBRARY_PATH :=

# Library dependecies
export IP_LIST := 

# Make products target
$(VIV_PROD_DIR): $(shell find $(VIV_SRC_DIR)) $(shell find $(IP_LIBRARY_PATH)$(IP_LIST)/$(VIV_SRC_DIR) $(HIDE))
	@$(call print, Creating IP $(call yellow,$(VIVADO_PROJ_NAME)) for Git SHA commit $(call green,$(GIT_SHA))...); 
	@$(VIV_RUN) -mode batch -notrace -source $(VIV_IP) $(HIDE);

