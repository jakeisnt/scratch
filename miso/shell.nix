let pkgs = import <nixpkgs> { };
in pkgs.mkShell { buildInputs = [ pkgs.hello pkgs.cabal-install ]; }
