let

  pkgs = import ../nix/nixpkgs.nix;
  gitignoreSource = import ../nix/gitignore-source.nix;

  clash-compiler = import (fetchTarball {
    url = "https://github.com/clash-lang/clash-compiler/archive/v1.2.4.tar.gz";
    sha256 = "0dc62aijrkacfjlckv461pj6i8h8mj7qry09mikxh6jl077a9wlz";
  }) { };

  clash-env = (pkgs.haskellPackages.ghcWithPackages (p:
    with p; [
      clash-compiler.clash-ghc

      ghc-typelits-extra
      ghc-typelits-knownnat
      ghc-typelits-natnormalise
    ]));

in pkgs.stdenv.mkDerivation {
  name = "ip";
  version = "1.0";

  src = gitignoreSource ./.;

  buildInputs = [ clash-env ];

  buildPhase = ''
    clash RunNetwork.hs --verilog
    clash DotProduct.hs --verilog
    clash DotProductSignal.hs --verilog
    clash ReLU.hs --verilog
  '';

  installPhase = ''
    mkdir $out
    cp -r verilog/* $out/
  '';
}
