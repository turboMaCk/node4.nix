# Node 4.9 nix

Nix expression for legacy Node 4.9 version. **Always prefer update over usage of this legacy version.**.

## Usage

```nix
{ pkgs ? import <nixpkgs> {} }:
import (pkgs.fetchGithub {
  owner = "turboMaCk";
  repo = "node4.nix";
  rev = "";
  sha256 = "";
}) pkgs
```
