# at least
AC_PREREQ([2.69])
AC_INIT([eg], [1.0])

# src file that not in other dir
AC_CONFIG_SRCDIR([src/simple-guile.c])
#AC_CONFIG_HEADERS([config.h])

# keep clean
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])

# init automake
AM_INIT_AUTOMAKE([1.16 subdir-objects -Wall parallel-tests color-tests foreign -Werror])
AM_PROG_AR

# check for libtool
LT_PREREQ([2.4.6])
LT_INIT

# Checks for c compiler
AC_PROG_CC

# Check for Guile 3 or 2.2
GUILE_PKG([3.0 2.2])
GUILE_FLAGS
GUILE_SITE_DIR

# Change libtool link opts
AC_ARG_ENABLE(static-prog,
AS_HELP_STRING([--enable-static-prog], [link statically]),
enable_static_prog=$enableval, enable_static_prog=no)
AM_CONDITIONAL(ENABLE_STATIC_PROG, test "$enable_static_prog" != "no")

# Generate a Makefile, based on the results.
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
