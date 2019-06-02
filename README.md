# Experimental Linux AppImage package of [OpenSpace](https://www.openspaceproject.com/)

**DISCLAIMER: This package is NOT affiliated with the OpenSpace project.**

## [Download](https://github.com/timjrd/OpenSpace.AppImage/releases/), make [executable](https://docs.appimage.org/user-guide/run-appimages.html), run
... and be prepared for the crash!


## Building the image

### Setup
Install the [Nix package manager](https://nixos.org/nix/):
```
curl https://nixos.org/nix/install | sh
source ~/.nix-profile/etc/profile.d/nix.sh
```

### Build
```
nix-build --cores 0 -A appimage https://github.com/timjrd/OpenSpace.AppImage/archive/master.tar.gz
```
This will fetch OpenSpace source code from GitHub including all
submodules, build it, and package it as an AppImage using
[nix-bundle](https://github.com/matthewbauer/nix-bundle/). This will
take a long time after which you will find the image in `result/`.
