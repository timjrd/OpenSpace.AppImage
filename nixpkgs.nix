let rev    = "376981987177b7bd8448db268d04f41dde355f3b"; # nixos-19.03 on May 26, 2019
    sha256 = "17m5zsn4gs76fkrmwn91kmx71fkfnwgavaz9jwmi5m940l2gd0jm";
in fetchTarball {
  url = "https://github.com/NixOS/nixpkgs-channels/archive/${rev}.tar.gz";
  inherit sha256;
}
