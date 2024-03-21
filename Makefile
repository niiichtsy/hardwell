include ./make_env.mk

# Arithmetic
ARITHM_LIBRARY_PATH := arithmetic/
ARITHM_LIST += adder
ARITHM_LIST += adder_subtractor
ARITHM_LIST += half_adder
ARITHM_LIST += half_subtractor
ARITHM_LIST += subtractor

# Utilities
UTIL_LIBRARY_PATH := utils/
UTIL_LIST += blinky
UTIL_LIST += clk_divider
UTIL_LIST += clk_stabilizer
UTIL_LIST += lfsr
UTIL_LIST += strober

# Networking
NET_LIBRARY_PATH := network/

LIB ?= all
