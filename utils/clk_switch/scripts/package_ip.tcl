source $env(ROOT_DIR)/tcl_env.tcl

create_project -force $proj_name -dir $outputDir

set_property TARGET_LANGUAGE VERILOG [current_project]

import_files -fileset sources_1 $hdl_list 

ipx::package_project -root_dir $productsDir -vendor $env(VIVADO_VENDOR) -library $env(VIVADO_LIBRARY) -taxonomy /UserIP -import_files -set_current false -force

ipx::unload_core $productsDir/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $productsDir $productsDir/component.xml
update_compile_order -fileset sources_1
set_property version $env(VERSION) [ipx::current_core]
set_property core_revision $env(DATESTAMP) [ipx::current_core]

# Define additional inferences as needed
ipx::infer_bus_interface clk_in0 xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface clk_in1 xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface clk_out xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]

# Package the project
ipx::update_source_project_archive -component [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project -delete
