#!/bin/sh
#
# example build using some guix pkgs
#

# install modified guile packages with guix
cd $(dirname $0) && \
mkdir -p build/guix/guile build/guix/guile-next && \
guix package -f guile/guile-2.2.scm -p build/guix/guile/guile && \
# needs relative path for local patches
cd guile && \
guix package -f guile-3.0.scm -p ../build/guix/guile-next/guile-next && \
cd  .. && \
# compile install check run
# use guix-profiles pkgconfig and add link dir
mkdir -p build && \
autoreconf -vif && \
cd build && \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-$PWD/guix/guile-next/guile-next/lib/pkgconfig} LDFLAGS=${LDFLAGS:--L$PWD/guix/guile-next/guile-next/lib} ../configure --prefix=$PWD --enable-static-prog && \
make clean all install distcheck run
