{ nixpkgs ? let
  rev = "50d5d73e22bb2830f490e26a528579facfc7f302"; # nixos-19.03 on May 30, 2019
  sha256 = "0c1inf0pc2jizkrfl3629s154r55ya5asmwnwn6g64ppz2wwzizi";
  in fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/${rev}.tar.gz";
    inherit sha256;
  }
}: let

pkgs = import nixpkgs {};

nix-bundle = pkgs.fetchFromGitHub {
  owner  = "timjrd";
  repo   = "nix-bundle";
  rev    = "353ad2c56502b680611cdfcc4583aac48de07e9b";
  sha256 = "16spin84bzmd1x2fl13h0pvlbkzzn88hs2w3g2132pk1k8dphaf3";
};

bundle = import "${nix-bundle}/appimage-top.nix" {
  nixpkgs' = nixpkgs;
};

nixos = pkgs.callPackage ./openspace {};

opengl = import ./opengl.nix;
non-nixos' = root: pkgs.stdenvNoCC.mkDerivation rec {
  name         = "openspace-non-nixos-${nixos.version}";
  buildInputs  = [ pkgs.makeWrapper ];
  phases       = [ "installPhase"   ];
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${nixos}/share $out/share
    makeWrapper ${nixos}/bin/OpenSpace $out/bin/OpenSpace --run '${wrapper}'
  '';
  
  # see https://github.com/NixOS/nixpkgs/issues/9415#issuecomment-139655485
  rpath   = builtins.concatStringsSep ":" (map (x: root+x) opengl.libdirs);
  wrapper = ''
    PATH=${pkgs.patchelf}/bin:${pkgs.coreutils}/bin:$PATH
    shim=$HOME/.openspace/shim
    rm -rf $shim
    mkdir -p $shim
    for lib in ${toString opengl.libs}; do
      for dir in ${toString opengl.libdirs}; do
        src=${root}$dir/$lib
        dst=$shim/$lib
        if [[ -e $src ]]; then
          cp --dereference --no-preserve=all $src $dst
          patchelf --set-rpath ${rpath} $dst
          break
        fi
      done
    done
    export LD_LIBRARY_PATH=$shim:$LD_LIBRARY_PATH
  '';
};

in rec {
  inherit nixos;
  
  non-nixos     = non-nixos' "";
  appdir-target = non-nixos' "/host";
  
  appdir = bundle.appdir {
    name   = "openspace";
    target = appdir-target;
  };
  
  appimage = bundle.appimage appdir;
}
