# Node 4.9 nix

Nix expression for legacy Node 4.9 version. **Always prefer update over usage of this legacy version.**.

release.nix contains pinned version of nixpks.

## Usage

```nix
{ pkgs ? import <nixpkgs> {} }:
import (pkgs.fetchFromGitHub {
  owner = "turboMaCk";
  repo = "node4.nix";
  rev = "23966d91cbd39018bfd7f1646e46e7c7fe665778";
  sha256 = "0zsd1q2ip4qdlnym82v1lb6mpqq3r87pxqixa9d283hcngljyfhf"
}) pkgs
```
