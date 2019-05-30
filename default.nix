{ nixpkgs ? import ./nixpkgs.nix }:
with import nixpkgs {};
callPackage ./openspace {}
