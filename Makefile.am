# This is an automake file; process in automake
ACLOCAL_AMFLAGS = -I m4 --install
EXTRA_DIST = example.sh guix-channel/ src/hello.scm README.org Makefile.bak

# .go and .scm files
GUILECOMPILED = ${GUILE_SITE:%/share/guile/site/@GUILE_EFFECTIVE_VERSION@=%/lib/guile/@GUILE_EFFECTIVE_VERSION@/ccache}
GUILESOURCE = ${GUILE_SITE:%/site/@GUILE_EFFECTIVE_VERSION@=%/@GUILE_EFFECTIVE_VERSION@}

# exe
pkglibexec_PROGRAMS = eg
eg_SOURCES = src/simple-guile.c src/hello.scm.h
eg_CFLAGS = ${GUILE_CFLAGS}
eg_LDFLAGS = ${GUILE_LDFLAGS}
if ENABLE_STATIC_PROG
eg_LDFLAGS += -all-static
endif

# shared
pkglib_LTLIBRARIES = eg.la
eg_la_SOURCES = src/simple-guile.c
eg_la_CFLAGS = ${GUILE_CFLAGS}
eg_la_LDFLAGS = ${GUILE_LTLIBS} -module

# local hooks for guile files as they are not in the project or binary
install-data-local:
	mkdir -p ${DESTDIR}${pkgdatadir}
	chmod -R u+w ${DESTDIR}${pkgdatadir}
	cp -r ${GUILECOMPILED} ${DESTDIR}${pkgdatadir}
	cp -r ${GUILESOURCE} ${DESTDIR}${pkgdatadir}
	chmod -R u+w ${DESTDIR}${pkgdatadir}

uninstall-local:
	rm -rf ${DESTDIR}${pkgdatadir}

# runtime
RUN_ARGS ?= -v

GUILE_LOAD_PATH ?= ${GUILESOURCE}
GUILE_LOAD_PATH_VAR = GUILE_LOAD_PATH=${GUILE_LOAD_PATH}

GUILE_LOAD_COMPILED_PATH ?= ${GUILECOMPILED}
GUILE_LOAD_COMPILED_PATH_VAR = GUILE_LOAD_COMPILED_PATH=${GUILE_LOAD_COMPILED_PATH}

# libtool can generate a wrapper too
LD_PRE_VAR ?= #"LD_PRELOAD=/usr/lib/libc.so.6:/usr/lib/libpthread.so.0"
LD_LIB_VAR ?= #"LD_LIBRARY_PATH=~/.guix-profile/lib"
LD_PATH ?= #"/usr/lib/ld-linux-x86-64.so.2"

.PHONY: run
run: eg
	${GUILE_LOAD_PATH_VAR} ${GUILE_LOAD_COMPILED_PATH_VAR} ${LD_LIB_VAR} ${LD_PRE_VAR} ${LD_PATH} ./$< ${RUN_ARGS}
#xxd -i hello.scm | sed 's/unsigned//g' | sed 's/\([0-9a-f]\)$/\0, 0x00/' > hello.scm.h
