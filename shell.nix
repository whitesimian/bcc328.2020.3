{ nixpkgs ? import <nixpkgs> {} } :

let
  inherit (nixpkgs) pkgs;
  ocamlPackages = pkgs.ocamlPackages;
  #ocamlPackages = pkgs.ocamlPackages_latest;
  #ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_10;
in

pkgs.stdenv.mkDerivation {
  name = "my-ocaml-env-0";
  buildInputs = [
    # can be provided by opam
    # ocamlPackages.dune
    # ##ocamlPackages.earlybird
    # #ocamlPackages.findlib
    # ocamlPackages.menhir
    # ocamlPackages.merlin
    # ocamlPackages.ocaml
    # ##ocamlPackages.patience_diff
    # ocamlPackages.ppx_deriving
    # ocamlPackages.ppx_expect
    # ##ocamlPackages.ppx_here
    # ocamlPackages.ppx_import
    # ##ocamlPackages.re
    # ocamlPackages.camomile
    # ocamlPackages.llvm
    # ocamlPackages.utop
    # #ocamlPackages.ocaml-print-intf # not available in nixpkgs
    # #ocamlPackages.ocaml-lsp-server # not available in nixpkgs
    # #pkgs.ocamlformat

    # tools outside of opam
    pkgs.binutils
    pkgs.gcc
    pkgs.m4

    # needed for ocaml-lsp-server
    pkgs.clang-tools
    pkgs.llvmPackages_latest.clang

    # needed for llvm bindings
    pkgs.llvmPackages_latest.llvm
    pkgs.python2Full
    pkgs.pkg-config
    pkgs.cmake
    pkgs.zlib
    pkgs.ncurses

    pkgs.opam
    pkgs.rlwrap
    pkgs.vscode
    (pkgs.emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
      pkgs.dune
      pkgs.ocamlformat
    ])))
  ];
}
