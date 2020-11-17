Compiling Clash programs to the DE10 Nano
=========================================

This folder contains a basic project that connects the forward propagation
neural network written in Clash to the DE10 Nano, connected through the Avalon
interconnect framework on Intel FPGAs. The contained quartus project is
automatically configered for the HPS (32-bit ARM-A9) processor with the correct
pins.

1. Use clash to compile the `RunNetwork.hs` file in the `ip` folder using
   `clash RunNetwork.hs --verilog`.
2. Copy the resulting file in `ip/verilog/RunNetwork/runNetwork/runNetwork.v`
   to this folder. A copy from the time of the presentation is currently in
   this folder.
3. To use the Avalon interconnect, we need to make a wrapper component that
   connects to the Avalon bridge. This is done in the `runNetworkTop.sv` system
   verilog file. If the size of the network changes, or a pipeline architecture
   is introduced, then this file will need to change. Such a file could be made
   in Clash as well, but is currently made by hand as a simple example.
4. Open the Quartus project in this folder.
5. Using the Platform Designer tool, add both the `runNetworkTop.sv` and
   `runNetwork.v` files to a new component (left hand bar in Platform
   designer). Name this component `runNetworkAVS`.
6. Add the `runNetworkAVS` to the block diagram. Connect it to the master
   clock, the HPS avalon master bridge, and whatever reset line (likely the HPS
   reset line and clock reset line). 
7. Specify the address to start at `0x0002 0000`. Since the main avalon AXI
   bridge starts at `0xc000 0000`, the final starting address will be `0xc002 0000`.
8. Save in Platform Designer and then click "Generate HDL". Accept the
   defaults. Click Finish after this is done.
9. Back in Quartus, click click on "Compile" in the left hand pane and select
   Start. Prepare to wait for up to 15 minutes to compile the FPGA bitfile,
   which will be stored in `output_files/nn.rbf`
10. Make sure the FPGA board is in the compressed RBF MSEL mode (the default
    when the board ships).
11. SCP the `output_files/nn.rbf` file to the DE10 Nano in the `/media/FAT`
    directory, which is available to the bootloader.
12. Connect to the DE10 nano through the UART connection (using say `screen`).
    Reboot the DE10 Nano and interrupt the initial boot sequence by pressing
    any key.
13. At the uboot command prompt, enter the following commands

    ```
    setenv fpga_file nn.rbf
    run fpga_cfg
    fatload mmc 0:1 +\$+{kernel_addr_r} zImage
    fatload mmc 0:1 +\$+{fdt_addr} socfpga_cyclone5_de10_nano.dtb
    setenv bootargs +\textquotesingle+console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait+\textquotesingle+
    bootz +\$+{kernel_addr_r} - +\$+{fdt_addr}
    ```

14. You should now be booted with the neural network on the FPGA. You can write
    to it through `/dev/mem` using address `0xc002 0000`. For the network shown
    in the presentation, the register mapping is:

    - `x`: `0xc002 0000` (read-write 32 bit signed fixed number (`SFixed 7 25`))
    - `y`: `0xc002 0004` (read-write 32 bit signed fixed number (`SFixed 7 25`))
    - `result`: `0xc002 0008` (read 32 bit signed fixed number (`SFixed 7 25`))
