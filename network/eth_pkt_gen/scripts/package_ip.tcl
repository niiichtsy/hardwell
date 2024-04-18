source $env(ROOT_DIR)/tcl_env.tcl

create_project -force $proj_name -dir $outputDir

set_property TARGET_LANGUAGE VERILOG [current_project]

import_files -fileset sources_1 $hdl_list 

ipx::package_project -root_dir $productsDir -vendor $env(VIVADO_VENDOR) -library $env(VIVADO_LIBRARY) -taxonomy /UserIP -import_files -set_current false -force

# Define additional inferences as needed
ipx::unload_core $productsDir/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $productsDir $productsDir/component.xml
update_compile_order -fileset sources_1
set_property version $env(VERSION) [ipx::current_core]
set_property core_revision $env(DATESTAMP) [ipx::current_core]

set_property widget {checkBox} [ipgui::get_guiparamspec -name "INCLUDE_PREAMBLE" -component [ipx::current_core] ]
set_property value true [ipx::get_user_parameters INCLUDE_PREAMBLE -of_objects [ipx::current_core]]
set_property value true [ipx::get_hdl_parameters INCLUDE_PREAMBLE -of_objects [ipx::current_core]]
set_property value_format bool [ipx::get_user_parameters INCLUDE_PREAMBLE -of_objects [ipx::current_core]]
set_property value_format bool [ipx::get_hdl_parameters INCLUDE_PREAMBLE -of_objects [ipx::current_core]]

set_property widget {comboBox} [ipgui::get_guiparamspec -name "DATA_SOURCE" -component [ipx::current_core] ]
set_property value_validation_type pairs [ipx::get_user_parameters DATA_SOURCE -of_objects [ipx::current_core]]
set_property value_validation_pairs {USER_DATA 1 LFSR 0} [ipx::get_user_parameters DATA_SOURCE -of_objects [ipx::current_core]]

set_property widget {comboBox} [ipgui::get_guiparamspec -name "ETHERTYPE" -component [ipx::current_core] ]
set_property value_validation_type pairs [ipx::get_user_parameters ETHERTYPE -of_objects [ipx::current_core]]
set_property value_validation_pairs {VLAN 0x00008100 ETHERNET 0x00000800} [ipx::get_user_parameters ETHERTYPE -of_objects [ipx::current_core]]

ipx::update_source_project_archive -component [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project -delete
