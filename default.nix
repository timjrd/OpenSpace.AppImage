{ nixpkgs ? let
  rev = "50d5d73e22bb2830f490e26a528579facfc7f302"; # nixos-19.03 on May 30, 2019
  sha256 = "0c1inf0pc2jizkrfl3629s154r55ya5asmwnwn6g64ppz2wwzizi";
  in fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/${rev}.tar.gz";
    inherit sha256;
  }
}: let pkgs = import nixpkgs {}; in rec {
  openspace = pkgs.callPackage ./openspace {};
  openspace-appimage = let
    nixbundle = pkgs.fetchFromGitHub {
      owner  = "timjrd";
      repo   = "nix-bundle";
      rev    = "e4cb2e74f730d087072850f13ed3aad4c4030dd9";
      sha256 = "0hd5pwk55j89v4ig01lhh8y2l444sjkhjqnkx6qq3c5j4zn0ysv5";
    };
    in with import "${nixbundle}/appimage-top.nix" { nixpkgs' = nixpkgs; };
    appimage (appdir {
      name = "openspace";
      target = openspace;
    });
}
