# hardwell

hardwell contains a toolbox of miscellaneous basic HDL (mainly Verilog and SystemVerilog) modules, intended to be reused and adapted to various projects.

## Building
The modules can be built using scripts utilizing Xilinx vendor tools. To create a module, make sure Vivado is available in your PATH, then simply run:
```
make ip && make upgrade
```
which should create run/ and products/ directories. To use the IP, simply add the products/ directory path to the IP repository of your project.
Tested and built using Vivado 2021.2, though I imagine the process will remain the same for future releases.

## Structure
The modules are grouped into folders, as described below:
```
arithmetic - basic arithmetic logic circuits.

utils - various utility blocks.

```
