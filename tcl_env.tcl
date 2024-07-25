#
# Package IP script
#
set proj_name $env(VIVADO_PROJ_NAME)

# Sources
set srcRoot [file normalize [pwd]/src]

# Library sources
set libIpRoot $env(DEP_LIBRARY_PATH)
if {[info exists ::env(DEP_LIST)]} {
    set libIpList $env(DEP_LIST)
}

# Outputs
set outputDir [file normalize [pwd]/run]
set productsDir [file normalize [pwd]/products]

# Project parameters
set_param general.maxThreads 8
set jobs [get_param general.maxThreads]

# List of source files
set hdl_list [glob $srcRoot/*]
puts "HDL sources: $hdl_list"

# List of library source files
set lib_list []

# List of library source files
if {[info exists ::env(DEP_LIST)]} {
    foreach libRoot $libIpRoot {
        foreach lib $libIpList {
            lappend lib_list [glob -nocomplain $libRoot/{$lib}.v]
            lappend lib_list [glob -nocomplain $libRoot/$lib/src/*]
        }
    }
}

# A little bit of magic to remove empty strings 
set hdl_list [list {*}$hdl_list {*}$lib_list ]
set hdl_list [lsearch -all -inline -not -exact $hdl_list {}]
