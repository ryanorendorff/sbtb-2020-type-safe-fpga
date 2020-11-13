let

  pkgs = import ./nixpkgs.nix;
  presentation = import ./default.nix;

in presentation.overrideAttrs
(oldAttrs: rec { buildInputs = oldAttrs.buildInputs ++ [ pkgs.watchexec ]; })
