# Programming machine learning algorithms in hardware, sanely, using Haskell and Rust!

Using Depdentent and Affine Types for robust FPGA programming.

Presented at [Scale by the Bay 2020 (SBTB 2020)](https://scalebythebay2020.sched.com/event/e55t/programming-machine-learning-algorithms-in-hardware-sanely-using-haskell-and-rust).

## How to run

We are using the DE10-Nano FPGA board, as it is relatively cheap and with plenty of documentation.

### Installing [Intel Quantus Prime Lite][quartus] on NixOS

We compiled the FPGA programs interactively in a NixOS 20.03 virtual machine using [VMware Fusion Player 12][vmware-fusion], which is now free! If you would like to install NixOS in a VMware instance as well, we have provided the configuration file in `nixos/configuration.nix`.

With a NixOS machine up, you can do the following to get started with development on the FPGA.

1. Download this repository and run `nix-env -f quartus.nix` to install [Intel Quantus Prime Lite][quartus]. This is used to compile the code for the FPGA.

2. You will then need to modify your `/etc/nixos/configuration.nix` to [include the following](https://rocketboards.org/foswiki/Documentation/UsingUSBBlasterUnderLinux):

    ```
    services.udev.extraRules = ''
      # USB-Blaster
      SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6001", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6002", MODE="0666"
    
      SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6003", MODE="0666"
    
      # USB-Blaster II
      SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6010", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6810", MODE="0666"
    '';
    ```
    
    This enables the FPGA to be programmed through the USB Blaster II interface without using a root account. 
    

## Abstract

We’re all used to programming software. But what about programming reconfigurable hardware? That’s exactly what we can do with Field Programmable Gate Arrays (FPGAs). Programming hardware opens up a whole new dimension to optimizing performance and resource utilization. However, programming FPGAs is challenging and requires esoteric tooling. We can do better! In this talk, we will show how we can use the Clash language to safely program FPGAs and Rust to correctly use them in a machine learning application. Our first step is converting a functional machine learning program into computer hardware. How do we do that? We use Clash! Clash is a Haskell like language that allows programmers to define hardware structurally. It does this by compiling functional programs into logic gates that are then turned into circuits on the FPGA. Clash includes a dependent type system, which allows Clash to guarantee that the circuits are wired up correctly on the FPGA, leading to fewer errors. We will demonstrate how a simple machine learning algorithm can be sped up by the hardware parallelism afforded to FPGAs, and highlight how Clash’s type system provides compile time guarantees that the hardware circuits are implemented correctly. OK, so we’ve got our FPGA hardware wired up correctly using Clash, but how do we make sure we use it correctly? What if we’re using it to run powerful and dangerous magnets in an imaging scanner? Well, we better do it right. We’ll talk about how we can use Rust to build a safe session interface over our hardware machine learning algorithm that provides important compile-time guarantees on how the hardware is accessed in software. Rust’s borrow checker ensures that we cannot access resources such as FIFO buffers outside of the scope of the hardware they refer to; additionally we also cannot forget to perform important hardware clean up when these resources go out of scope. This application will demonstrate how Rust’s unique type system enables both an ergonomic and compile time-validated interface to the Clash validated FPGA hardware. 

<!-- References -->
[quartus]: https://fpgasoftware.intel.com/?edition=lite
[vmware-fusion]: https://www.vmware.com/products/fusion/fusion-evaluation.html
