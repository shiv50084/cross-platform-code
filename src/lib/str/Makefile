SHELL = /bin/sh
.PHONY: clean, mkdir, install, uninstall, html, pdf

ifndef release.version
    release.version = 0.0.1
endif

# TODO list
# * Static libraries instead of shared?
# * This file is getting big, maybe it's
#   a good idea to split. Create a Makefile
#   for each library.

SYSTEM := $(shell uname -s)
MACHINE := $(shell uname -m)

# determine current platform
BUILD_TYPE ?= debug
ifeq ($(OS),Windows_NT)
    ifeq ($(findstring CYGWIN_NT,${SYSTEM}),CYGWIN_NT)
	OSTYPE ?= CYGWIN_NT
	MACHINETYPE ?= $(MACHINE)
	build.level = $(shell date)
    else
	OSTYPE ?= $(OS)
	MACHINETYPE ?= $(PROCESSOR_ARCHITECTURE)
    endif
else
    OSTYPE ?= $(SYSTEM)
    MACHINETYPE ?= $(MACHINE)
    build.level = $(shell date)
endif # OS
ifeq ($(OSTYPE),linux)
    OSTYPE = Linux
endif

# assume this is normally run in the main Paho directory
ifndef srcdir
    srcdir = .
endif

ifndef incdir
    incdir = ../../../include
endif

ifndef blddir
    blddir = ../../../build/output
endif

ifndef prefix
    prefix = /usr/local
endif

ifndef exec_prefix
    exec_prefix = ${prefix}
endif

bindir = $(exec_prefix)/bin
includedir = $(prefix)/include
libdir = $(exec_prefix)/lib

SOURCE_FILES_STR = $(wildcard $(srcdir)/*.c)

HEADERS_STR = $(incdir)/str/*.h

# The names of the libraries to be built
LIB_STR = str

CC ?= gcc

ifndef INSTALL
INSTALL = install
endif
INSTALL_PROGRAM = $(INSTALL)
ifeq ($(OSTYPE),CYGWIN_NT)
# The library needs executable permissions in Cygwin
INSTALL_DATA =  $(INSTALL)
else
INSTALL_DATA =  $(INSTALL) -m 0644
endif
DOXYGEN_COMMAND = doxygen

MAJOR_VERSION = 0
MINOR_VERSION = 0
VERSION = ${MAJOR_VERSION}.${MINOR_VERSION}

ifeq ($(OSTYPE),CYGWIN_NT)
# The library in Cygwin has a specific format,
# check the link https://cygwin.com/cygwin-ug-net/dll.html
LIBNAME_PREFIX = cyg
LIBNAME_EXT = dll
else ifeq ($(OSTYPE),Darwin)
LIBNAME_PREFIX = lib
LIBNAME_EXT = dylib
else
LIBNAME_PREFIX = lib
LIBNAME_EXT = so
endif

LIB_STR_LIBNAME = ${LIBNAME_PREFIX}${LIB_STR}.${LIBNAME_EXT}

LIB_STR_TARGET = ${blddir}/${LIB_STR_LIBNAME}.${VERSION}

#FLAGS_EXE = $(LDFLAGS) -I ${incdir} -lpthread -L ${blddir}
#FLAGS_EXES = $(LDFLAGS) -I ${incdir} ${START_GROUP} -lpthread -lssl -lcrypto ${END_GROUP} -L ${blddir}

ifeq ($(OSTYPE),CYGWIN_NT)
LDFLAGS_CYGWIN = -Wl,--export-all-symbols -Wl,--enable-auto-import

CCFLAGS_SO_STR = -g $(CFLAGS) -I $(incdir)/str/ -Os -Wall -fvisibility=hidden
LDFLAGS_STR = $(LDFLAGS) -shared -Wl,--no-whole-archive -lpthread $(LDFLAGS_CYGWIN)
else
CCFLAGS_SO_STR = -g -fPIC $(CFLAGS) -I $(incdir)/str/ -Os -Wall -fvisibility=hidden
LDFLAGS_STR = $(LDFLAGS) -shared -lpthread
endif

ifeq ($(OSTYPE),Linux)

EXTRA_LIB = -ldl

LDFLAGS_STR += -Wl,-soname,${LIB_STR_LIBNAME}.${MAJOR_VERSION}

else ifeq ($(OSTYPE),Darwin)

EXTRA_LIB = -ldl

CCFLAGS_SO_STR += -dynamiclib -Wno-deprecated-declarations -undefined dynamic_lookup -DUSE_NAMED_SEMAPHORES
LDFLAGS_STR += -Wl,-install_name,${LIB_STR_LIBNAME}.${MAJOR_VERSION}

else ifeq ($(OSTYPE),CYGWIN_NT)

LDFLAGS_STR += -Wl,--out-implib=${blddir}/lib$(LIB_STR).${LIBNAME_EXT}.a

endif

all: build

build: | mkdir ${LIB_STR_TARGET}

clean:
	rm -rf ${blddir}/*

mkdir:
	-mkdir -p ${blddir}/samples
	-mkdir -p ${blddir}/test
	echo OSTYPE is $(OSTYPE)

${LIB_STR_TARGET}: ${SOURCE_FILES_STR} ${HEADERS_STR}
	${CC} ${CCFLAGS_SO_STR} -o $@ ${SOURCE_FILES_STR} ${LDFLAGS_STR}
	-ln -s ${LIB_STR_LIBNAME}.${VERSION}  ${blddir}/${LIB_STR_LIBNAME}.${MAJOR_VERSION}
	-ln -s ${LIB_STR_LIBNAME}.${MAJOR_VERSION} ${blddir}/${LIB_STR_LIBNAME}

strip_options:
	$(eval INSTALL_OPTS := -s)

install-strip: build strip_options install

install: build
	$(INSTALL_PROGRAM) -d $(DESTDIR)${libdir}
	$(INSTALL_PROGRAM) -d $(DESTDIR)${includedir}
	$(INSTALL_DATA) ${INSTALL_OPTS} ${LIB_STR_TARGET} $(DESTDIR)${libdir}
ifeq ($(OSTYPE),CYGWIN_NT)
	ln -fs ${LIB_STR_LIBNAME}.${VERSION}  $(DESTDIR)${libdir}/${LIB_STR_LIBNAME}.${MAJOR_VERSION}
	$(INSTALL_DATA) ${blddir}/lib*.dll.a $(DESTDIR)${libdir}
else
	/sbin/ldconfig $(DESTDIR)${libdir}
endif
	ln -fs ${LIB_STR_LIBNAME}.${MAJOR_VERSION} $(DESTDIR)${libdir}/${LIB_STR_LIBNAME}
	$(INSTALL_DATA) ${HEADERS_STR} $(DESTDIR)${includedir}

uninstall:
	rm -f $(DESTDIR)${libdir}/${LIB_STR_LIBNAME}.*
ifeq ($(OSTYPE),CYGWIN_NT)
	rm -f $(DESTDIR)${libdir}/*${LIB_STR}*.dll.a
else
	/sbin/ldconfig $(DESTDIR)${libdir}
endif
	rm -f $(DESTDIR)${libdir}/${LIB_STR_LIBNAME}
	rm -f $(DESTDIR)${includedir}/${HEADERS_STR}

html:
	-mkdir -p ${blddir}/doc
