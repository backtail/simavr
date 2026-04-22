{
  pkgs ? import <nixpkgs> { },
}:

pkgs.stdenv.mkDerivation {
  pname = "simavr";
  version = "master";

  src = ./.;

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
