# For using Intel Quartus on NixOS.
let
  src = builtins.fetchTarball {
    url = "https://github.com/nprindle/nix-quartus/archive/0f5021ebcffbaf0de446aa9027f16dd591b34157.tar.gz";
    sha256 = "0fr8z9x5lq8bm03dc482gp9qwd51l43a5szpmr27pb99q2bq62ry";
  };
in (import src {}).altera-quartus-prime-lite-18
