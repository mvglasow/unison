#!/bin/bash
#
# NAME
#   provision-ocaml.sh - provision a foreign chroot envionment
#
# SYNOPSIS
#   provision-ocaml.sh OCAML_VERSION
#
# DESCRIPTION
#   This script sets up OCaml in a foreign chroot environment.
#
# OPTIONS
#   OCAML_VERSION
#         OCaml version to install

[ $# -eq 0 ] && { echo "ERROR: OCAML_VERSION argument is missing; aborting." ; exit 1 ; }
OCAML_VERSION=$1
bash-wrapper 'opam init -y --disable-sandboxing'
bash-wrapper 'eval $(opam config env)'
bash-wrapper "opam switch create $OCAML_VERSION $OCAML_VERSION -y"
bash-wrapper 'eval $(opam config env)'
# which ocaml  # FIXME remove
bash-wrapper 'ocaml -version'   # FIXME remove
bash-wrapper 'opam install opam-depext'

