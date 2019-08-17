# Node 4.9 nix

Nix expression for legacy Node 4.9 version. **Always prefer update over usage of this legacy version.**.

## Usage

```nix
{ pkgs ? import <nixpkgs> {} }:
import (pkgs.fetchFromGitHub {
  owner = "turboMaCk";
  repo = "node4.nix";
  rev = "3a2a43001874d24f7f3c72915d27776e16a53090";
  sha256 = "1fvdv97w5c4jps8kai6vmyxrbnasl2ncgkww7rfkqn6ib8wq8zsn";
}) pkgs
```
