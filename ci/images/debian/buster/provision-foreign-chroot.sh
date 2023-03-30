#!/bin/bash
#
# NAME
#   provision-foreign-chroot.sh - provision a foreign chroot envionment
#
# SYNOPSIS
#   provision-foreign-chroot.sh CROSS_ARCH
#
# DESCRIPTION
#   This script sets up a foreign chroot environment.
#
# OPTIONS
#   CROSS_ARCH
#         Target architecture, as passed to `debootstrap`
#
# ENVIRONMENT
#   Operation of this script is controlled by several environment variables:
#
#   CROSS_MIRROR
#         Path to the mirror site for `debootstrap`
#
#   CROSS_RELEASE
#         Release to be installed in the foreign chroot environment, as passed to `debootstrap`

[ $# -eq 0 ] && { echo "ERROR: CROSS_ARCH argument is missing; aborting." ; exit 1 ; }
[[ -v CROSS_MIRROR ]] || { echo "ERROR: CROSS_MIRROR is not set; aborting." ; exit 1 ; }
[[ -v CROSS_RELEASE ]] || { echo "ERROR: CROSS_RELEASE is not set; aborting." ; exit 1 ; }
CROSS_ARCH=$1
CROSS_ROOT="/opt/chroot/${CROSS_ARCH}"
apt-get -y install debootstrap qemu-user-static binfmt-support
mkdir -p $CROSS_ROOT
debootstrap --variant=buildd --include=fakeroot,build-essential,ca-certificates,debian-archive-keyring,git,sudo --arch=${CROSS_ARCH} --foreign ${CROSS_RELEASE} $CROSS_ROOT $CROSS_MIRROR
mkdir -p $CROSS_ROOT/usr/bin
ln /usr/bin/qemu-*-static $CROSS_ROOT/usr/bin/
chroot $CROSS_ROOT ./debootstrap/debootstrap --second-stage
mkdir -p $CROSS_ROOT/proc
mount -B /proc $CROSS_ROOT/proc
mkdir -p $CROSS_ROOT/sys
mount -B /sys $CROSS_ROOT/sys
# replicate users and groups if we’re not running as root
if [ $(whoami) != root ] ; then
  sudo ln -f /etc/passwd $CROSS_ROOT/etc/passwd
  sudo ln -f /etc/group $CROSS_ROOT/etc/group
fi
# home dir is needed in any case
mkdir -p $CROSS_ROOT/$HOME
mount --bind $HOME $CROSS_ROOT/$HOME
# TODO fix package authentication rather than using --allow-unauthenticated
bash-wrapper 'apt-get -y --allow-unauthenticated install librsvg2-bin imagemagick opam libgtk-3-dev'

