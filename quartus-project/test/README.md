How to test the neural network on the DE10 nano
===============================================

Once the neural network FPGA bitfile has been loaded onto the DE10 Nano (see
the `quartus-project/README.md` file), you can test the neural network using
the following steps.

1. On a host computer, copy the `devmem.c` file into this folder using the
   following commands.

   ```
   git clone https://gfiber.googlesource.com/vendor/opensource/toolbox
   cp toolbox/devmem.c .
   rm -rf toolbox
   ```

2. Get the script using your favorite downloader (say `wget`)

   ```
   wget https://github.com/intel-iot-devkit/terasic-de10-nano-kit/raw/master/tutorials/MyFirstHPSSystem/writeup_linux/c_examples/build_devmem.sh
   ```

3. Copy this entire folder to the DE10 using `scp`.
4. On the DE10, cd to this directory and run `./build_devmem.sh`. Add execute
   permission flags (`chmod +x`) if needed.
5. Run the script `./run2Dnetwork.sh` and verify that the lines saying "Actual
   output" match those saying "Expected output".
