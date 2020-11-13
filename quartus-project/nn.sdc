#
# Copyright (c) 2017 Intel Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#

# inform quartus that the clk port brings a 50MHz clock into our design so
# that timing closure on our design can be analyzed

create_clock -name clk -period "50MHz" [get_ports clk]
derive_clock_uncertainty

# inform quartus that the PIO inputs and outputs have no critical timing
# requirements.  These signals are driving LEDs and reading discrete push button
# and switch inputs, there are no timing relationships that are critical for any
# of this

set_false_path -from [get_ports {switch[0]}] -to *
set_false_path -from [get_ports {switch[1]}] -to *
set_false_path -from [get_ports {switch[2]}] -to *
set_false_path -from [get_ports {switch[3]}] -to *
set_false_path -from * -to [get_ports {leds[0]}]
set_false_path -from * -to [get_ports {leds[1]}]
set_false_path -from * -to [get_ports {leds[2]}]
set_false_path -from * -to [get_ports {leds[3]}]
set_false_path -from * -to [get_ports {leds[4]}]
set_false_path -from * -to [get_ports {leds[5]}]
set_false_path -from * -to [get_ports {leds[6]}]
set_false_path -from * -to [get_ports {leds[7]}]
set_false_path -from [get_ports {push_button[0]}] -to *
set_false_path -from [get_ports {push_button[1]}] -to *

# Define timing constraints for the JTAG IO pins so that Quartus properly closes
# timing on these signal paths.  Otherwise we could have unreliable JTAG
# communication with the device over the USB Blaster II connection.
# NOTE: the 'altera_reserved_tck' clock is automatically defined by Quartus

set_input_delay  -clock altera_reserved_tck -clock_fall 3 [get_ports {altera_reserved_tdi}]
set_input_delay  -clock altera_reserved_tck -clock_fall 3 [get_ports {altera_reserved_tms}]
set_output_delay -clock altera_reserved_tck             3 [get_ports {altera_reserved_tdo}]

# Define clocks for the HPS ports that expose clock signals to avoid
# unconstrained clock warnings
create_clock -period "1 MHz" [get_ports {hps_io_hps_io_i2c0_inst_SCL}]
create_clock -period "1 MHz" [get_ports {hps_io_hps_io_i2c1_inst_SCL}]
create_clock -period "48 MHz" [get_ports {hps_io_hps_io_usb1_inst_CLK}]
