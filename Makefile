include ./make_env.mk

# Arithmetic
ARITHM_LIBRARY_PATH := $(ROOT_DIR)/arithmetic/
ARITHM_LIST += adder
ARITHM_LIST += adder_subtractor
ARITHM_LIST += half_adder
ARITHM_LIST += half_subtractor
ARITHM_LIST += subtractor

# Utilities
UTIL_LIBRARY_PATH := $(ROOT_DIR)/utils/
UTIL_LIST += blinky
UTIL_LIST += clk_divider
UTIL_LIST += clk_stabilizer
UTIL_LIST += lfsr
UTIL_LIST += strober

# Networking
NET_LIBRARY_PATH := $(ROOT_DIR)/network/
NET_LIST += eth_pkt_gen

