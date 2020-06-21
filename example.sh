#!/bin/sh
#
# example build using some guix pkgs
#

# install modified guile packages with guix
cd $(dirname $0) && \
mkdir -p build/guix/guile-next && \
guix package -L $PWD/guix-channel/ -p build/guix/guile-next/guile-next -i guile-next-static && \
# compile install check run
# use guix-profiles pkgconfig and add link dir
mkdir -p build && \
autoreconf -vif && \
cd build && \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-$PWD/guix/guile-next/guile-next/lib/pkgconfig} LDFLAGS=${LDFLAGS:--L$PWD/guix/guile-next/guile-next/lib} ../configure --prefix=$PWD --enable-static-prog && \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-$PWD/guix/guile-next/guile-next/lib/pkgconfig} make clean all install distcheck run
