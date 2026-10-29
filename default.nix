{
  pkgs ? import <nixpkgs> { },
}:

pkgs.stdenv.mkDerivation {
  pname = "simavr";
  version = "master";

  # Keep the derivation stable across the detached Git worktrees created by
  # remote_tests.py. Both entries contain job-specific paths and neither is
  # an input to the simavr build.
  src = builtins.path {
    path = ./.;
    name = "monoplex-simavr-source";
    filter = path: type:
      let name = baseNameOf path;
      in name != ".git" && name != "result";
  };

  nativeBuildInputs = with pkgs; [
    gnumake
    gcc
    pkg-config
    which
    patchelf
    git
    libelf
  ];

  buildPhase = ''
    make RELEASE=1 build-simavr
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/include
    cp -L simavr/run_avr $out/bin/
    cp -L simavr/obj-*/libsimavr.so* $out/lib/
    cp -r simavr/sim/* $out/include
    patchelf --set-rpath $out/lib $out/bin/run_avr
  '';

  doCheck = false;
}
