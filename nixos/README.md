NixOS 20.03 in VMware Fusion Install Instructions
=================================================

These instructions are for installing NixOS 20.03 on VMware Fusion Player 12.
However, they should work for any VMware virtualization software.

1. Follow the instructions for the **UEFI** setup in the NixOS manual:  https://nixos.org/manual/nixos/stable/index.html#sec-installation
2. When it comes time to set up your `configuration.nix`, you can copy over the contents of the `configuration.nix` in this repository. The two pieces of interest in the file are:

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
3. Run `nixos-install`
4. Shutdown. Make sure to remove the ISO from the virtual drive before starting
   the VM again.
