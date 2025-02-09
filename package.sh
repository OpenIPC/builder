#!/bin/bash
#
# OpenIPC | version 2025.02.09
# A simple script for quick and complete recompilation of a package


LANG=C
PACKAGE=$1
PACKAGE="${PACKAGE:=busybox}"

rm -rfv \
    openipc/output/per-package/${PACKAGE} \
    openipc/output/build/${PACKAGE}*

make -C openipc/output ${PACKAGE}-{dirclean,rebuild}

exit 0
