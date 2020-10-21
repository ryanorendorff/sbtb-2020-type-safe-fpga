NixOS 20.03 in VMware Fusion Install Instructions
=================================================

These instructions are for installing NixOS 20.03 on VMware Fusion Player 12.
However, they should work for any VMware virtualization software.

1. Download the NixOS 20.03 ISO from nixos.org
2. Start VMware fusion, specify `install from ISO` option.
3. If it asks for a boot type, choose UEFI.
4. For the type, choose `Other Linux 5.x and later kernel 64-bit`.
5. When given a choice to setup the virtual machine, you can change the number
of processors to 4 and the amount of ram to 8192 MB. These are the numbers we
used; you can use whatever works best for your setup. The more cores you have
the faster it should be to compile the FPGA bitfile.
6. Boot the virtual machine.
7. Follow the instructions for the **UEFI** setup in the NixOS manual:  https://nixos.org/manual/nixos/stable/index.html#sec-installation
8. When it comes time to set up your `configuration.nix`, you can copy over the contents of the `configuration.nix` in this repository. The two pieces of interest in the file are:

    - The VMware tools are set using `virtualisation.vmware.guest.enable = true;`
    - To flash the FPGA on the DE10 Nano without using a root account through the USB Blaster II port (the mini-B USB port near the HDMI adapter), you need to add some `udev` rules.
        ```
        # Configuration required for the DE10 Nano
        services.udev.extraRules = ''
          # Rules required to interface with the DE10 Nano without using root access.
          # USB-Blaster
          SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6001", MODE="0666"
          SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6002", MODE="0666"

          SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6003", MODE="0666"

          # USB-Blaster II
          SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6010", MODE="0666"
          SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6810", MODE="0666"
        '';
        ```
9. Run `nixos-install`
10. Shutdown. Make sure to remove the ISO from the virtual drive before starting
    the VM again.
