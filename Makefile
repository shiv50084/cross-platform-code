#*******************************************************************************
#  Copyright (c) 2009, 2015 IBM Corp.
# 
#  All rights reserved. This program and the accompanying materials
#  are made available under the terms of the Eclipse Public License v1.0
#  and Eclipse Distribution License v1.0 which accompany this distribution. 
# 
#  The Eclipse Public License is available at 
#     http://www.eclipse.org/legal/epl-v10.html
#  and the Eclipse Distribution License is available at 
#    http://www.eclipse.org/org/documents/edl-v10.php.
# 
#  Contributors:
#     Ian Craggs - initial API and implementation and/or initial documentation
#     Allan Stockdill-Mander - SSL updates
#     Andy Piper - various fixes
#     Ian Craggs - OSX build
#     Rainer Poisel - support for multi-core builds and cross-compilation
#*******************************************************************************/

# Note: on OS X you should install XCode and the associated command-line tools

SHELL = /bin/sh
.PHONY: clean, mkdir, install, uninstall, html, pdf

ifndef release.version
    release.version = 0.0.1
endif

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
    srcdir = src
endif

ifndef incdir
    incdir = include
endif

ifndef blddir
    blddir = build/output
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

SOURCE_FILES_STR = $(wildcard $(srcdir)/lib/str/*.c)
#SOURCE_FILES_C = $(filter-out $(srcdir)/MQTTAsync.c $(srcdir)/MQTTVersion.c $(srcdir)/SSLSocket.c, $(SOURCE_FILES))
#SOURCE_FILES_CS = $(filter-out $(srcdir)/MQTTAsync.c $(srcdir)/MQTTVersion.c, $(SOURCE_FILES))
#SOURCE_FILES_A = $(filter-out $(srcdir)/MQTTClient.c $(srcdir)/MQTTVersion.c $(srcdir)/SSLSocket.c, $(SOURCE_FILES))
#SOURCE_FILES_AS = $(filter-out $(srcdir)/MQTTClient.c $(srcdir)/MQTTVersion.c, $(SOURCE_FILES))

HEADERS_STR = $(incdir)/str/*.h
#HEADERS_C = $(filter-out $(incdir)/MQTTAsync.h, $(HEADERS))
#HEADERS_A = $(HEADERS)

#SAMPLE_FILES_C = stdinpub stdoutsub pubsync pubasync subasync
#SYNC_SAMPLES = ${addprefix ${blddir}/samples/,${SAMPLE_FILES_C}}

#SAMPLE_FILES_A = stdoutsuba MQTTAsync_subscribe MQTTAsync_publish
#ASYNC_SAMPLES = ${addprefix ${blddir}/samples/,${SAMPLE_FILES_A}}

#TEST_FILES_C = test1 sync_client_test test_mqtt4sync
#SYNC_TESTS = ${addprefix ${blddir}/test/,${TEST_FILES_C}}

#TEST_FILES_CS = test3
#SYNC_SSL_TESTS = ${addprefix ${blddir}/test/,${TEST_FILES_CS}}

#TEST_FILES_A = test4 test_mqtt4async
#ASYNC_TESTS = ${addprefix ${blddir}/test/,${TEST_FILES_A}}

#TEST_FILES_AS = test5
#ASYNC_SSL_TESTS = ${addprefix ${blddir}/test/,${TEST_FILES_AS}}

# The names of the four different libraries to be built
LIB_STR = str
#MQTTLIB_C = paho-mqtt3c
#MQTTLIB_CS = paho-mqtt3cs
#MQTTLIB_A = paho-mqtt3a
#MQTTLIB_AS = paho-mqtt3as

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
#MQTTLIB_C_LIBNAME = ${LIBNAME_PREFIX}${MQTTLIB_C}.${LIBNAME_EXT}
#MQTTLIB_CS_LIBNAME = ${LIBNAME_PREFIX}${MQTTLIB_CS}.${LIBNAME_EXT}
#MQTTLIB_A_LIBNAME = ${LIBNAME_PREFIX}${MQTTLIB_A}.${LIBNAME_EXT}
#MQTTLIB_AS_LIBNAME = ${LIBNAME_PREFIX}${MQTTLIB_AS}.${LIBNAME_EXT}

LIB_STR_TARGET = ${blddir}/${LIB_STR_LIBNAME}.${VERSION}
#MQTTLIB_C_TARGET = ${blddir}/${MQTTLIB_C_LIBNAME}.${VERSION}
#MQTTLIB_CS_TARGET = ${blddir}/${MQTTLIB_CS_LIBNAME}.${VERSION}
#MQTTLIB_A_TARGET = ${blddir}/${MQTTLIB_A_LIBNAME}.${VERSION}
#MQTTLIB_AS_TARGET = ${blddir}/${MQTTLIB_AS_LIBNAME}.${VERSION}

#MQTTVERSION_TARGET = ${blddir}/MQTTVersion

FLAGS_EXE = $(LDFLAGS) -I ${incdir} -lpthread -L ${blddir}
#FLAGS_EXES = $(LDFLAGS) -I ${incdir} ${START_GROUP} -lpthread -lssl -lcrypto ${END_GROUP} -L ${blddir}

ifeq ($(OSTYPE),CYGWIN_NT)
CCFLAGS_SO_STR = -g $(CFLAGS) -I $(incdir)/str/ -Os -Wall -fvisibility=hidden
#CCFLAGS_SO = -g $(CFLAGS) -Os -Wall -fvisibility=hidden
LDFLAGS_CYGWIN = -Wl,--export-all-symbols -Wl,--enable-auto-import
LDFLAGS_STR = $(LDFLAGS) -shared -Wl,--no-whole-archive -lpthread $(LDFLAGS_CYGWIN)
#LDFLAGS_C = $(LDFLAGS) -shared -Wl,--no-whole-archive -lpthread -Wl,-init,$(MQTTCLIENT_INIT) $(LDFLAGS_CYGWIN)
#LDFLAGS_CS = $(LDFLAGS) -shared -Wl,--no-whole-archive -lpthread $(EXTRA_LIB) -lssl -lcrypto -Wl,-init,$(MQTTCLIENT_INIT) $(LDFLAGS_CYGWIN)
#LDFLAGS_A = $(LDFLAGS) -shared -Wl,--no-whole-archive -lpthread -Wl,-init,$(MQTTASYNC_INIT) $(LDFLAGS_CYGWIN)
#LDFLAGS_AS = $(LDFLAGS) -shared -Wl,--no-whole-archive -lpthread $(EXTRA_LIB) -lssl -lcrypto -Wl,-init,$(MQTTASYNC_INIT) $(LDFLAGS_CYGWIN)
else
CCFLAGS_SO_STR = -g -fPIC $(CFLAGS) -I $(incdir)/str/ -Os -Wall -fvisibility=hidden
#CCFLAGS_SO = -g -fPIC $(CFLAGS) -Os -Wall -fvisibility=hidden
LDFLAGS_STR = $(LDFLAGS) -shared -lpthread
#LDFLAGS_C = $(LDFLAGS) -shared -Wl,-init,$(MQTTCLIENT_INIT) -lpthread
#LDFLAGS_CS = $(LDFLAGS) -shared $(START_GROUP) -lpthread $(EXTRA_LIB) -lssl -lcrypto $(END_GROUP) -Wl,-init,$(MQTTCLIENT_INIT)
#LDFLAGS_A = $(LDFLAGS) -shared -Wl,-init,$(MQTTASYNC_INIT) -lpthread
#LDFLAGS_AS = $(LDFLAGS) -shared $(START_GROUP) -lpthread $(EXTRA_LIB) -lssl -lcrypto $(END_GROUP) -Wl,-init,$(MQTTASYNC_INIT)
endif

ifeq ($(OSTYPE),Linux)

#SED_COMMAND = sed -i "s/\#\#MQTTCLIENT_VERSION_TAG\#\#/${release.version}/g; s/\#\#MQTTCLIENT_BUILD_TAG\#\#/${build.level}/g" 

#MQTTCLIENT_INIT = MQTTClient_init
#MQTTASYNC_INIT = MQTTAsync_init
#START_GROUP = -Wl,--start-group
#END_GROUP = -Wl,--end-group

EXTRA_LIB = -ldl

LDFLAGS_STR += -Wl,-soname,${LIB_STR_LIBNAME}.${MAJOR_VERSION}
#LDFLAGS_C += -Wl,-soname,${MQTTLIB_C_LIBNAME}.${MAJOR_VERSION}
#LDFLAGS_CS += -Wl,-soname,${MQTTLIB_CS_LIBNAME}.${MAJOR_VERSION} -Wl,-no-whole-archive
#LDFLAGS_A += -Wl,-soname,${MQTTLIB_A_LIBNAME}.${MAJOR_VERSION}
#LDFLAGS_AS += -Wl,-soname,${MQTTLIB_AS_LIBNAME}.${MAJOR_VERSION} -Wl,-no-whole-archive

else ifeq ($(OSTYPE),Darwin)

#SED_COMMAND = sed -i "" -e "s/\#\#MQTTCLIENT_VERSION_TAG\#\#/${release.version}/g" -e "s/\#\#MQTTCLIENT_BUILD_TAG\#\#/${build.level}/g" 

#MQTTCLIENT_INIT = _MQTTClient_init
#MQTTASYNC_INIT = _MQTTAsync_init
#START_GROUP =
#END_GROUP = 

EXTRA_LIB = -ldl

CCFLAGS_SO_STR += -dynamiclib -Wno-deprecated-declarations -DUSE_NAMED_SEMAPHORES
LDFLAGS_STR += -Wl,-install_name,${LIB_STR_LIBNAME}.${MAJOR_VERSION}
#LDFLAGS_C += -Wl,-install_name,${MQTTLIB_C_LIBNAME}.${MAJOR_VERSION}
#LDFLAGS_CS += -Wl,-install_name,${MQTTLIB_CS_LIBNAME}.${MAJOR_VERSION}
#LDFLAGS_A += -Wl,-install_name,${MQTTLIB_A_LIBNAME}.${MAJOR_VERSION}
#LDFLAGS_AS += -Wl,-install_name,${MQTTLIB_AS_LIBNAME}.${MAJOR_VERSION}

else ifeq ($(OSTYPE),CYGWIN_NT)

#SED_COMMAND = sed -i "s/\#\#MQTTCLIENT_VERSION_TAG\#\#/${release.version}/g; s/\#\#MQTTCLIENT_BUILD_TAG\#\#/${build.level}/g"

#MQTTCLIENT_INIT = _MQTTClient_init
#MQTTASYNC_INIT = _MQTTAsync_init
#START_GROUP =
#END_GROUP = 

LDFLAGS_STR += -Wl,--out-implib=${blddir}/lib$(LIB_STR).${LIBNAME_EXT}.a
#LDFLAGS_C += -Wl,--out-implib=${blddir}/lib$(MQTTLIB_C).${LIBNAME_EXT}.a
#LDFLAGS_CS += -Wl,--out-implib=${blddir}/lib$(MQTTLIB_CS).${LIBNAME_EXT}.a
#LDFLAGS_A += -Wl,--out-implib=${blddir}/lib${MQTTLIB_A}.${LIBNAME_EXT}.a
#LDFLAGS_AS += -Wl,--out-implib=${blddir}/lib${MQTTLIB_AS}.${LIBNAME_EXT}.a
endif

all: build

#build: | mkdir ${MQTTLIB_C_TARGET} ${MQTTLIB_CS_TARGET} ${MQTTLIB_A_TARGET} ${MQTTLIB_AS_TARGET} ${MQTTVERSION_TARGET} ${SYNC_SAMPLES} ${ASYNC_SAMPLES} ${SYNC_TESTS} ${SYNC_SSL_TESTS} ${ASYNC_TESTS} ${ASYNC_SSL_TESTS}
build: | mkdir ${LIB_STR_TARGET}

clean:
	rm -rf ${blddir}/*

mkdir:
	-mkdir -p ${blddir}/samples
	-mkdir -p ${blddir}/test
	echo OSTYPE is $(OSTYPE)

#${SYNC_TESTS}: ${blddir}/test/%: ${srcdir}/../test/%.c $(MQTTLIB_C_TARGET)
#	${CC} -g -o $@ $< -l${MQTTLIB_C} ${FLAGS_EXE}

#${SYNC_SSL_TESTS}: ${blddir}/test/%: ${srcdir}/../test/%.c $(MQTTLIB_CS_TARGET)
#	${CC} -g -o $@ $< -l${MQTTLIB_CS} ${FLAGS_EXES}

#${ASYNC_TESTS}: ${blddir}/test/%: ${srcdir}/../test/%.c $(MQTTLIB_CS_TARGET)
#	${CC} -g -o $@ $< -l${MQTTLIB_A} ${FLAGS_EXE}

#${ASYNC_SSL_TESTS}: ${blddir}/test/%: ${srcdir}/../test/%.c $(MQTTLIB_CS_TARGET) $(MQTTLIB_AS_TARGET)
#	${CC} -g -o $@ $< -l${MQTTLIB_AS} ${FLAGS_EXES}

#${SYNC_SAMPLES}: ${blddir}/samples/%: ${srcdir}/samples/%.c $(MQTTLIB_C_TARGET)
#	${CC} -o $@ $< -l${MQTTLIB_C} ${FLAGS_EXE}

#${ASYNC_SAMPLES}: ${blddir}/samples/%: ${srcdir}/samples/%.c $(MQTTLIB_A_TARGET)
#	${CC} -o $@ $< -l${MQTTLIB_A} ${FLAGS_EXE}

${LIB_STR_TARGET}: ${SOURCE_FILES_STR} ${HEADERS_STR}
	${CC} ${CCFLAGS_SO_STR} -o $@ ${SOURCE_FILES_STR} ${LDFLAGS_STR}
	-ln -s ${LIB_STR_LIBNAME}.${VERSION}  ${blddir}/${LIB_STR_LIBNAME}.${MAJOR_VERSION}
	-ln -s ${LIB_STR_LIBNAME}.${MAJOR_VERSION} ${blddir}/${LIB_STR_LIBNAME}

#${MQTTLIB_C_TARGET}: ${SOURCE_FILES_C} ${HEADERS_C}
#	$(SED_COMMAND) $(srcdir)/MQTTClient.c
#	${CC} ${CCFLAGS_SO} -o $@ ${SOURCE_FILES_C} ${LDFLAGS_C}
#	-ln -s ${MQTTLIB_C_LIBNAME}.${VERSION}  ${blddir}/${MQTTLIB_C_LIBNAME}.${MAJOR_VERSION}
#	-ln -s ${MQTTLIB_C_LIBNAME}.${MAJOR_VERSION} ${blddir}/${MQTTLIB_C_LIBNAME}

#${MQTTLIB_CS_TARGET}: ${SOURCE_FILES_CS} ${HEADERS_C}
#	$(SED_COMMAND) $(srcdir)/MQTTClient.c
#	${CC} ${CCFLAGS_SO} -o $@ ${SOURCE_FILES_CS} -DOPENSSL ${LDFLAGS_CS}
#	-ln -s ${MQTTLIB_CS_LIBNAME}.${VERSION}  ${blddir}/${MQTTLIB_CS_LIBNAME}.${MAJOR_VERSION}
#	-ln -s ${MQTTLIB_CS_LIBNAME}.${MAJOR_VERSION} ${blddir}/${MQTTLIB_CS_LIBNAME}

#${MQTTLIB_A_TARGET}: ${SOURCE_FILES_A} ${HEADERS_A}
#	$(SED_COMMAND) $(srcdir)/MQTTAsync.c
#	${CC} ${CCFLAGS_SO} -o $@ ${SOURCE_FILES_A} ${LDFLAGS_A}
#	-ln -s ${MQTTLIB_A_LIBNAME}.${VERSION}  ${blddir}/${MQTTLIB_A_LIBNAME}.${MAJOR_VERSION}
#	-ln -s ${MQTTLIB_A_LIBNAME}.${MAJOR_VERSION} ${blddir}/${MQTTLIB_A_LIBNAME}

#${MQTTLIB_AS_TARGET}: ${SOURCE_FILES_AS} ${HEADERS_A}
#	$(SED_COMMAND) $(srcdir)/MQTTAsync.c 
#	${CC} ${CCFLAGS_SO} -o $@ ${SOURCE_FILES_AS} -DOPENSSL ${LDFLAGS_AS}
#	-ln -s ${MQTTLIB_AS_LIBNAME}.${VERSION}  ${blddir}/${MQTTLIB_AS_LIBNAME}.${MAJOR_VERSION}
#	-ln -s ${MQTTLIB_AS_LIBNAME}.${MAJOR_VERSION} ${blddir}/${MQTTLIB_AS_LIBNAME}

#${MQTTVERSION_TARGET}: $(srcdir)/MQTTVersion.c $(srcdir)/MQTTAsync.h ${MQTTLIB_A_TARGET} $(MQTTLIB_CS_TARGET)
#	${CC} -o $@ $(srcdir)/MQTTVersion.c -l${MQTTLIB_A} ${FLAGS_EXE} ${EXTRA_LIB}

strip_options:
	$(eval INSTALL_OPTS := -s)

install-strip: build strip_options install

install: build
	$(INSTALL_PROGRAM) -d $(DESTDIR)${libdir}
	$(INSTALL_PROGRAM) -d $(DESTDIR)${includedir}
	$(INSTALL_DATA) ${INSTALL_OPTS} ${LIB_STR_TARGET} $(DESTDIR)${libdir}
#	$(INSTALL_DATA) ${INSTALL_OPTS} ${MQTTLIB_C_TARGET} $(DESTDIR)${libdir}
#	$(INSTALL_DATA) ${INSTALL_OPTS} ${MQTTLIB_CS_TARGET} $(DESTDIR)${libdir}
#	$(INSTALL_DATA) ${INSTALL_OPTS} ${MQTTLIB_A_TARGET} $(DESTDIR)${libdir}
#	$(INSTALL_DATA) ${INSTALL_OPTS} ${MQTTLIB_AS_TARGET} $(DESTDIR)${libdir}
#	$(INSTALL_PROGRAM) ${INSTALL_OPTS} ${MQTTVERSION_TARGET} $(DESTDIR)${bindir}
ifeq ($(OSTYPE),CYGWIN_NT)
	ln -fs ${LIB_STR_LIBNAME}.${VERSION}  $(DESTDIR)${libdir}/${LIB_STR_LIBNAME}.${MAJOR_VERSION}
#	ln -fs ${MQTTLIB_C_LIBNAME}.${VERSION}  $(DESTDIR)${libdir}/${MQTTLIB_C_LIBNAME}.${MAJOR_VERSION}
#	ln -fs ${MQTTLIB_CS_LIBNAME}.${VERSION}  $(DESTDIR)${libdir}/${MQTTLIB_CS_LIBNAME}.${MAJOR_VERSION}
#	ln -fs ${MQTTLIB_A_LIBNAME}.${VERSION}  $(DESTDIR)${libdir}/${MQTTLIB_A_LIBNAME}.${MAJOR_VERSION}
#	ln -fs ${MQTTLIB_AS_LIBNAME}.${VERSION}  $(DESTDIR)${libdir}/${MQTTLIB_AS_LIBNAME}.${MAJOR_VERSION}
	$(INSTALL_DATA) ${blddir}/lib*.dll.a $(DESTDIR)${libdir}
else
	/sbin/ldconfig $(DESTDIR)${libdir}
endif
	ln -fs ${LIB_STR_LIBNAME}.${MAJOR_VERSION} $(DESTDIR)${libdir}/${LIB_STR_LIBNAME}
#	ln -fs ${MQTTLIB_C_LIBNAME}.${MAJOR_VERSION} $(DESTDIR)${libdir}/${MQTTLIB_C_LIBNAME}
#	ln -fs ${MQTTLIB_CS_LIBNAME}.${MAJOR_VERSION} $(DESTDIR)${libdir}/${MQTTLIB_CS_LIBNAME}
#	ln -fs ${MQTTLIB_A_LIBNAME}.${MAJOR_VERSION} $(DESTDIR)${libdir}/${MQTTLIB_A_LIBNAME}
#	ln -fs ${MQTTLIB_AS_LIBNAME}.${MAJOR_VERSION} $(DESTDIR)${libdir}/${MQTTLIB_AS_LIBNAME}
	$(INSTALL_DATA) ${HEADERS_STR} $(DESTDIR)${includedir}
#	$(INSTALL_DATA) ${srcdir}/MQTTAsync.h $(DESTDIR)${includedir}
#	$(INSTALL_DATA) ${srcdir}/MQTTClient.h $(DESTDIR)${includedir}
#	$(INSTALL_DATA) ${srcdir}/MQTTClientPersistence.h $(DESTDIR)${includedir}

uninstall:
	rm -f $(DESTDIR)${libdir}/${LIB_STR_LIBNAME}.*
#	rm -f $(DESTDIR)${libdir}/${MQTTLIB_C_LIBNAME}.*
#	rm -f $(DESTDIR)${libdir}/${MQTTLIB_CS_LIBNAME}.*
#	rm -f $(DESTDIR)${libdir}/${MQTTLIB_A_LIBNAME}.*
#	rm -f $(DESTDIR)${libdir}/${MQTTLIB_AS_LIBNAME}.*
#	rm -f $(DESTDIR)${bindir}/MQTTVersion
ifeq ($(OSTYPE),CYGWIN_NT)
	rm -f $(DESTDIR)${libdir}/*${LIB_STR}*.dll.a
else
	/sbin/ldconfig $(DESTDIR)${libdir}
endif
	rm -f $(DESTDIR)${libdir}/${LIB_STR_LIBNAME}
#	rm -f $(DESTDIR)${libdir}/${MQTTLIB_C_LIBNAME}
#	rm -f $(DESTDIR)${libdir}/${MQTTLIB_CS_LIBNAME}
#	rm -f $(DESTDIR)${libdir}/${MQTTLIB_A_LIBNAME}
#	rm -f $(DESTDIR)${libdir}/${MQTTLIB_AS_LIBNAME}
	rm -f $(DESTDIR)${includedir}/${HEADERS_STR}
#	rm -f $(DESTDIR)${includedir}/MQTTAsync.h
#	rm -f $(DESTDIR)${includedir}/MQTTClient.h
#	rm -f $(DESTDIR)${includedir}/MQTTClientPersistence.h

html:
	-mkdir -p ${blddir}/doc
#	cd ${srcdir}; $(DOXYGEN_COMMAND) ../doc/DoxyfileV3ClientAPI
#	cd ${srcdir}; $(DOXYGEN_COMMAND) ../doc/DoxyfileV3AsyncAPI
#	cd ${srcdir}; $(DOXYGEN_COMMAND) ../doc/DoxyfileV3ClientInternal
