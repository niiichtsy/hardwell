# blinky
A simple blinky module which operates in two modes, based on the mode switch_input:
* by default, the blinky will count to whatever number of available LEDs was specified, and output the counter on the led_out port.
* if mode_switch was toggled, the blinky will count only if ext_counter signal was provided.

TODO:
- [ ] Change the ext_counter mode to async counting based on input signal (for example, increment the counter each time a button connected to the ext_counter port is pressed)
