{ pkgs ? import <nixpkgs> { } } :
pkgs.mkShell {
    nativeBuildInputs = with pkgs; [
        glibc.static
        zlib.static
        libffi
        libtool
    ];

    LD_LIBRARY_PATH = with pkgs; ''
        ${glibc.static.outPath}/lib:${zlib.static.outPath}/lib
    '';
}