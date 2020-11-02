let

  clash-compiler = fetchTarball {
    url = "https://github.com/clash-lang/clash-compiler/archive/v1.2.4.tar.gz"; 
    sha256 = "0dc62aijrkacfjlckv461pj6i8h8mj7qry09mikxh6jl077a9wlz";
  };
in 
  import "${clash-compiler}/shell.nix"
