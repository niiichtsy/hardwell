# hardwell

hardwell is a toolbox of miscellaneous general-purpose HDL modules (mainly written in Verilog and SystemVerilog), intended to be reused and adapted to various projects.

## Building
The modules can be built using scripts utilizing Xilinx vendor tools. To create a single module, move to its directory, then simply run:
```
make ip 
```
which should create run/ and products/ directories. To use the IP, simply add the products/ directory path to the IP repository of your project.

To build an entire library, invoke:
```
make lib LIB=<library of your choice>
```
from the project's root directory (by default, creates all available libraries). Afterwards, add the library folder to the IP repository of your project.
If called from a module directory, it will build that module's dependencies. 
Same goes for ```clean-lib```.

Tested and built using Vivado 2021.2, though I imagine the process will remain the same for future releases.

## Structure
The modules are grouped into libraries, as described below:
```
arithmetic - basic arithmetic logic circuits.

utils - various utility blocks.

network - networking tools.
```
