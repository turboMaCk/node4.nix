 # Node.js 4 build
# this should build node.js 4.9.1 from source
# commit: https://github.com/nodejs/node/tree/b8eef6d10bf45a4d659a84d670dbf3afff0250a2
# tested:
#   - [x] NixOS (Linux)
#   - [x] MacOS
# Based on https://github.com/NixOS/nixpkgs/blob/a23c20eff89a2ff1f4970f40fb2726948ea29d25/pkgs/development/web/nodejs/nodejs.nix
# Mac fixes based on https://github.com/NixOS/nixpkgs/blob/4586b7b888d789462530b6cb92a8dc0ad2b88167/pkgs/development/web/nodejs/nodejs.nix

{ stdenv, fetchurl, openssl, python2, zlib, libuv, utillinux, http-parser
, pkgconfig, which
, darwin ? null
, ...
}:

with stdenv.lib;

let

  inherit (darwin.apple_sdk.frameworks) CoreServices ApplicationServices;

  sharedLibDeps = { inherit openssl zlib libuv; } // (optionalAttrs (!stdenv.isDarwin) { inherit http-parser; });

  sharedConfigureFlags = concatMap (name: [
    "--shared-${name}"
    "--shared-${name}-libpath=${getLib sharedLibDeps.${name}}/lib"
    /** Closure notes: we explicitly avoid specifying --shared-*-includes,
     *  as that would put the paths into bin/nodejs.
     *  Including pkgconfig in build inputs would also have the same effect!
     */
  ]) (builtins.attrNames sharedLibDeps);

in
stdenv.mkDerivation rec {
  name = "nodejs-${version}";
  # version is full commit hash!
  version = "4.9.1";

  # official node.js distribution
  src = fetchurl {
    url = "http://nodejs.org/dist/v${version}/node-v${version}.tar.xz";
    sha256 = "00flv81rzhhsar0sv6v35n88jn6z1g4hly4qdsf6k4c3jhpj7lfp";
  };

  buildInputs = optionals stdenv.isDarwin [ CoreServices ApplicationServices ]
  ++ [ python2 which zlib libuv openssl ]
  ++ optionals stdenv.isLinux [ utillinux http-parser ]
  ++ optionals stdenv.isDarwin [ pkgconfig darwin.cctools ];

  configureFlags = sharedConfigureFlags ++ [ "--without-dtrace" ];

  dontDisableStatic = true;

  enableParallelBuilding = true;

  passthru.interpreterName = "nodejs";

  setupHook = ./setup-hook.sh;

  preBuild = optionalString stdenv.isDarwin ''
    sed -i -e "s|tr1/type_traits|type_traits|g" \
    -e "s|std::tr1|std|" src/util.h
  '';

  prePatch = ''
    patchShebangs .
    sed -i 's/raise.*No Xcode or CLT version detected.*/version = "7.0.0"/' tools/gyp/pylib/gyp/xcode_emulation.py
  '';

  postInstall = ''
    PATH=$out/bin:$PATH patchShebangs $out
    mkdir -p $out/share/bash-completion/completions/
    $out/bin/npm completion > $out/share/bash-completion/completions/npm
  '';

  meta = {
    description = "Event-driven I/O framework for the V8 JavaScript engine";
    homepage = https://nodejs.org;
    license = licenses.mit;
    maintainers = with maintainers; [ goibhniu gilligan cko ];
    platforms = platforms.linux ++ platforms.darwin;
  };

  passthru.python = python2; # to ensure nodeEnv uses the same version
}
