let
  pkgs = import ./nixpkgs.nix;
  gitignoreSource = import ../nix/gitignore-source.nix;

  texlive = pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-small fontspec pgfopts epsdice beamer beamertheme-metropolis;
  };

  fonts = pkgs.makeFontsConf {
    fontDirectories = with pkgs; [ fira fira-mono iosevka ];
  };

in pkgs.stdenv.mkDerivation {
  name =
    "Programming-machine-learning-algorithms-in-hardware-sanely-using-Haskell-and-Rust";

  src = gitignoreSource ./.;

  phases = [ "unpackPhase" "buildPhase" ];

  buildInputs = with pkgs; [ texlive pandoc ];

  FONTCONFIG_FILE = "${fonts}";

  buildPhase = ''
    mkdir $out
    make
    cp SBTB-2020-Type-Safe-FPGA.pdf $out
  '';
}
