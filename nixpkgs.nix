# nixpkgs unstable channel from October 15th, 2020
import (builtins.fetchTarball {

  url =

    "https://github.com/NixOS/nixpkgs/archive/a26e92a67d884db696792d25dcc44c466a1bc8b4.tar.gz";
  sha256 = "0w4sp4cgncr62vgzknny76whlansab94dq2lx27if77ir3zpfiia";
}) { }
