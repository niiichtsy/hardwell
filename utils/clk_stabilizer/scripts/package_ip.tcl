#
# Package IP script
#
set proj_name $env(VIVADO_PROJ_NAME)

# Sources
set srcRoot [file normalize [pwd]/src]

# Library sources
set libIpRoot $env(IP_LIBRARY_PATH)
set libIpList $env(IP_LIST)

# Outputs
set outputDir [file normalize [pwd]/run]
set productsDir [file normalize [pwd]/products]

# Project parameters
set_param general.maxThreads 8
set jobs [get_param general.maxThreads]

# List of source files
set hdl_list [glob $srcRoot/*]

# List of library source files
set lib_list []
foreach libRoot $libIpRoot {
    foreach lib $libIpList {
        lappend lib_list [glob -nocomplain $libRoot/$lib/src/*]
    }
}

# A little bit of magic to remove empty strings 
set hdl_list [list {*}$hdl_list {*}$lib_list ]
set hdl_list [lsearch -all -inline -not -exact $hdl_list {}]

create_project -force $proj_name -dir $outputDir

set_property TARGET_LANGUAGE VERILOG [current_project]

import_files -fileset sources_1 $hdl_list 

ipx::package_project -root_dir $productsDir -vendor $env(VIVADO_VENDOR) -library $env(VIVADO_LIBRARY) -taxonomy /UserIP -import_files -set_current false -force
ipx::unload_core $productsDir/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $productsDir $productsDir/component.xml
update_compile_order -fileset sources_1

# Define additional inferences as needed
ipx::infer_bus_interface out_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface stable_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface prog_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]

set_property version $env(VERSION) [ipx::current_core]
set_property core_revision $env(DATESTAMP) [ipx::current_core]
ipx::update_source_project_archive -component [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project -delete
