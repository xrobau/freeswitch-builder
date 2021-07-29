VERSION=20210728
RELEASE=1
CLANGVERS=12.0.0
NPROCS=$(shell nproc)
JOBS=$(shell echo $$(( $(NPROCS) * 2 )) )
BUILDDIR=$(shell pwd)/build
SOURCEDIR=$(shell pwd)/source
RPMSOURCE=$(BUILDDIR)/SOURCES

RPMBASE=$(BUILDDIR)/RPMS/x86_64

VOLUMES=-v /usr/local/ccache:/usr/local/ccache -v $(BUILDDIR):/usr/local/build

CLANGFILE=clang+llvm-$(CLANGVERS)-x86_64-linux-gnu-centos7.tar.xz
CLANGSRC=https://github.com/xrobau/centos7clang/releases/download/v12.0.0/$(CLANGFILE)
CLANGDOCKERTAG=$(shell pwd)/.clang_docker_build

LIBSSHASH=8a12e1c750e86133564be69cfece9ccfe39deb52
LIBSSSHORT = $(shell echo $(LIBSSHASH) | cut -c1-7)
LIBSSFILENAME = libstirshaken-$(VERSION)-$(LIBSSSHORT).tar.gz
LIBSSURL=https://github.com/signalwire/libstirshaken/tarball/$(LIBSSHASH)
LIBSSPREFIX=signalwire-libstirshaken-$(LIBSSSHORT)
LIBSSRPM=libstirshaken-$(VERSION)-$(RELEASE).el7.x86_64.rpm
LIBSSDEVELRPM=libstirshaken-devel-$(VERSION)-$(RELEASE).el7.x86_64.rpm
LIBSSDOCKERTAG=$(shell pwd)/.libss_docker_build

LIBKSHASH=0b4a6e8181578ed9594cad536c11fb4e284a4849
LIBKSSHORT = $(shell echo $(LIBKSHASH) | cut -c1-7)
LIBKSFILENAME = libks-$(VERSION)-$(LIBKSSHORT).tar.gz
LIBKSURL=https://github.com/signalwire/libks/tarball/$(LIBKSHASH)
LIBKSRPM=libks-$(VERSION)-$(RELEASE).el7.x86_64.rpm
LIBKSPREFIX=signalwire-libks-$(LIBKSSHORT)
LIBKSDOCKERTAG=$(shell pwd)/.libks_docker_build

LIBJWTVERS=1.13.1
LIBJWTRPM=libjwt-$(LIBJWTVERS)-1.el7.x86_64.rpm
LIBJWTDEVELRPM=libjwt-devel-$(LIBJWTVERS)-1.el7.x86_64.rpm
LIBJWTFILE=libjwt-$(LIBJWTVERS).tar.gz
LIBJWTURL=https://github.com/benmcollins/libjwt/archive/v$(LIBJWTVERS).tar.gz

FSHASH=5c6fd51c115f4029926197095d436d527277c0e2
FSURL=https://github.com/signalwire/freeswitch/tarball/$(FSHASH)
FSVERSION=1.10.8
FSRELEASE=$(VERSION).dev1
FSSHORT = $(shell echo $(FSHASH) | cut -c1-7)
FSBASEFILENAME = freeswitch-orig-$(VERSION)-$(FSSHORT).tar.gz
FSFILENAME = freeswitch-$(VERSION)-$(FSSHORT).tar.gz
FSPREFIX=signalwire-freeswitch-$(FSSHORT)
FSDOCKERTAG=$(shell pwd)/.fs_docker_build
FSEXTRADEFINE = -D 'release $(FSRELEASE)' -D 'version $(FSVERSION)' -D 'extracted $(FSPREFIX)' -D 'configure_options "LDFLAGS=-L/usr/lib64/openssl11"'
FSPATCHES=$(notdir $(wildcard patches/freeswitch/*))
FSRPM=freeswitch-$(FSVERSION)-$(FSRELEASE).el7.x86_64.rpm

SOFIAHASH=fbab3b7b3d077105378585d75d61a0a9c6fb7a4e
SOFIAURL=https://github.com/freeswitch/sofia-sip/tarball/$(SOFIAHASH)
SOFIASHORT = $(shell echo $(SOFIAHASH) | cut -c1-7)
SOFIAVERSION=1.13.4
SOFIARELEASE=22
SOFIAPREFIX=freeswitch-sofia-sip-$(SOFIASHORT)
SOFIAFILENAME=$(SOFIAPREFIX).tar.gz
SOFIARPM=sofia-sip-$(SOFIAVERSION)-$(SOFIARELEASE).el7.x86_64.rpm

RPMBUILD=rpmbuild --define "_topdir /usr/local/build" -ba

FSDEPS=v8-3.24.14.tar.bz2 mongo-c-driver-1.1.0.tar.gz pocketsphinx-0.8.tar.gz sphinxbase-0.8.tar.gz communicator_semi_6000_20080321.tar.gz libmemcached-0.32.tar.gz freeradius-client-1.1.7.tar.gz

FSDEPDEST=$(addprefix build/SOURCES/,$(FSDEPS))
FSPATCHESDEST=$(addprefix build/SOURCES/,$(FSPATCHES))

RPMS=$(RPMBASE)/$(LIBJWTRPM) $(RPMBASE)/$(LIBKSRPM) $(RPMBASE)/$(LIBSSRPM)

.PHONY: shell setup rpms clean freeswitch

test:
	echo $(CLANGDOCKERTAG)

shell: $(FSDOCKERTAG) build/SOURCES/$(FSFILENAME)
	docker run --rm $(VOLUMES) -it fsbuilder:$(VERSION) bash

setup: $(BUILDDIR) $(SOURCEDIR) /usr/local/ccache/ccache.conf build/SOURCES $(CLANGDOCKERTAG)

clean:
	rm -rf build $(LIBSSDOCKERTAG) $(CLANGDOCKERTAG) $(LIBKSDOCKERTAG) $(FSDOCKERTAG) freeswitch.spec


# Wildcard match for all the sub-containers
libksdocker/%.rpm libssdocker/%.rpm fsdocker/%.rpm: $(RPMBASE)/%.rpm
	cp $(<) $(@)


#####
# Common patterns
build/SOURCES/%: %
	cp $(<) $(@)

build/%.spec: %.spec
	cp $(<) $(@)

/usr/local/ccache/ccache.conf: ccache.conf
	mkdir -p $(@D) && chmod 777 $(@D)
	cp $(<) $(@)

$(BUILDDIR) $(SOURCEDIR) $(RPMSOURCE):
	mkdir -p $(@) && chmod 777 $(@)


##
#####

######
##
## Clang 12.0.0 base image
##

.PHONY: clangcontainer
clangcontainer: setup $(CLANGDOCKERTAG)

clangdocker/$(CLANGFILE):
	wget $(CLANGSRC) -O $(@)

$(CLANGDOCKERTAG): clangdocker/$(CLANGFILE) $(wildcard clangdocker/*)
	@echo Starting $(@)
	docker build --build-arg CLANG=$(CLANGFILE) -t clangbuilder:$(CLANGVERS) clangdocker
	touch $(@)

##
##
##
######


######
##
## libjwt
## Built using clang container.
##

.PHONY: libjwt
libjwt: setup $(RPMBASE)/$(LIBJWTRPM)

$(RPMSOURCE)/$(LIBJWTFILE): | $(RPMSOURCE)
	wget $(LIBJWTURL) -O $(@)

$(RPMBASE)/$(LIBJWTRPM): $(CLANGDOCKERTAG) $(RPMSOURCE)/$(LIBJWTFILE) build/libjwt.spec
	docker run --rm $(VOLUMES) -it clangbuilder:$(CLANGVERS) $(RPMBUILD) libjwt.spec

##
##
##
######

######
## libks
## This creates the 'libksbuilder' container, from the clang container, and adds
## the libjwt and libjwt-devel RPMs from the previous build
##

.PHONY: libks
libks: $(RPMBASE)/$(LIBKSRPM)

$(LIBKSDOCKERTAG): libksdocker/$(LIBJWTRPM) libksdocker/$(LIBJWTDEVELRPM) $(wildcard libksdocker/*)
	@echo Starting $(@)
	docker build --build-arg LIBJWT=$(LIBJWTRPM) --build-arg LIBJWTDEVEL=$(LIBJWTDEVELRPM) -t libksbuilder:$(VERSION) libksdocker
	touch $(@)

$(LIBKSFILENAME):
	wget $(LIBKSURL) -O $(@)

build/libks.spec: libks.spec
	sed -e 's/__VERSION__/$(VERSION)/' -e 's/__RELEASE__/$(RELEASE)/' -e 's/__SOURCE__/$(LIBKSFILENAME)/' -e 's/__LIBKSPREFIX__/$(LIBKSPREFIX)/' $< > $(@)

## And then build the RPM using the container and spec file we just made
$(RPMBASE)/$(LIBKSRPM): $(LIBKSDOCKERTAG) $(RPMSOURCE)/$(LIBKSFILENAME) build/libks.spec
	docker run --rm $(VOLUMES) -it libksbuilder:$(VERSION) $(RPMBUILD) libks.spec

##
##
##
#####

#####
## libstirshaken
## The libssbuilder container is created from the libksbuilder container, adding the
## libks lib that was just created
##

.PHONY: libss
libss: setup $(RPMBASE)/$(LIBSSRPM)

$(LIBSSDOCKERTAG): libssdocker/$(LIBKSRPM) $(wildcard libssdocker/*)
	@echo Starting $(@)
	docker build --build-arg LIBKS=$(LIBKSRPM) --build-arg VERSION=$(VERSION) -t libssbuilder:$(VERSION) libssdocker
	touch $(@)

$(LIBSSFILENAME):
	wget $(LIBSSURL) -O $(@)

build/libstirshaken.spec: libstirshaken.spec
	sed -e 's/__VERSION__/$(VERSION)/' -e 's/__RELEASE__/$(RELEASE)/' -e 's/__SOURCE__/$(LIBSSFILENAME)/' -e 's/__LIBSSPREFIX__/$(LIBSSPREFIX)/' $< > $(@)

## You know the drill by now.
$(RPMBASE)/$(LIBSSRPM): $(LIBSSDOCKERTAG) $(RPMSOURCE)/$(LIBSSFILENAME) build/libstirshaken.spec
	docker run --rm $(VOLUMES) -it libssbuilder:$(VERSION) $(RPMBUILD) libstirshaken.spec

##
##
##
#####

#####
## lib-sofia-sip
## This doesn't need its own container, it can use the libssbuilder container
## to build itself. (We're still using clang 12.0.0 at this point)

.PHONY: libsofia
libsofia: setup $(RPMBASE)/$(SOFIARPM)

$(SOFIAFILENAME):
	wget -nc -O $(@) $(SOFIAURL)

build/sofia-sip.spec: sofia-sip.spec
	sed -e 's/__SOFIAVERSION__/$(SOFIAVERSION)/' -e 's/__SOFIARELEASE__/$(SOFIARELEASE)/' -e 's/__SOFIASOURCE__/$(SOFIAFILENAME)/' -e 's/__SOFIAPREFIX__/$(SOFIAPREFIX)/' $< > $(@)

$(RPMBASE)/$(SOFIARPM): $(LIBSSDOCKERTAG) build/sofia-sip.spec build/SOURCES/$(SOFIAFILENAME)
	docker run --rm $(VOLUMES) -it libssbuilder:$(VERSION) $(RPMBUILD) sofia-sip.spec

##
##
##
#####

#####
## Freeswitch. Finally!

.PHONY: freeswitch
freeswitch: setup $(RPMBASE)/$(FSRPM)

## This is generated by a script, taking the source spec file and
## patching it
freeswitch.spec: $(FSFILENAME) $(FSPATCHESDEST) $(FSDEPDEST) $(shell pwd)/gen-freeswitchspec.sh
	$(shell pwd)/gen-freeswitchspec.sh $(<) $(FSVERSION)

## This is a list of the freeswitch dependancies to download
$(FSDEPDEST):
	wget -nc -O $(@) http://files.freeswitch.org/downloads/libs/$(@F)
	
## Some makefile magic to glob all the freeswitch patches into place
.SECONDEXPANSION:
$(FSPATCHESDEST): patches/freeswitch/$$(@F)
	cp $(<) $(@)

## This is the raw file, from github. autoconf/bootstrap needs to be
## run against it.
$(FSBASEFILENAME): $(FSDOCKERTAG)
	wget -O $(@) $(FSURL)

## Build our freeswitch building container. We add libss and libsofia to the libssbuilder
## container, and ALSO switch back to RHEL devtoolset-9. No more clang!

## These are all the libsofia rpms we add. I add them all because why not?
SOFIAPMREQS=devel glib glib-devel utils
SOFIAREQS=$(addprefix fsdocker/,$(addsuffix -$(SOFIAVERSION)-$(SOFIARELEASE).el7.x86_64.rpm,sofia-sip $(addprefix sofia-sip-,$(SOFIAPMREQS))))

$(FSDOCKERTAG): fsdocker/$(LIBSSRPM) fsdocker/$(LIBSSDEVELRPM) fsdocker/$(SOFIARPM) $(SOFIAREQS) $(wildcard fsdocker/*)
	@echo Starting $(@)
	docker build --build-arg LIBSS=$(LIBSSRPM) --build-arg LIBSSDEVEL=$(LIBSSDEVELRPM) --build-arg LIBSOFIA=$(SOFIAVERSION)-$(SOFIARELEASE) --build-arg VERSION=$(VERSION) -t fsbuilder:$(VERSION) fsdocker
	touch $(@)

## Now the container is built, we need to build the REAL source package, by
## grabbing the raw code from github, running bootstrap in it, and then
## packaging it back up

## This is the 'real' source package, after autoconf/bootstrap.sh has been run in it
$(FSFILENAME): build/autoconf/$(FSPREFIX)/Makefile.in
	tar -C build/autoconf -cf $(@) $(FSPREFIX)

## Pull down BASEFILENAME (from github), extract it and use the fsbuilder container
## to run boostrap.
build/autoconf/$(FSPREFIX)/Makefile.in: $(FSBASEFILENAME)
	mkdir -p build/autoconf && tar -C build/autoconf -xf $<
	docker run --rm $(VOLUMES) -w /usr/local/build/autoconf/$(FSPREFIX) -it fsbuilder:$(VERSION) ./bootstrap.sh -j

## And now we can finally build all the RPMS.
$(RPMBASE)/$(FSRPM): build/SOURCES/$(FSFILENAME) build/freeswitch.spec | $(FSDOCKERTAG)
	docker run --rm $(VOLUMES) -it fsbuilder:$(VERSION) $(RPMBUILD) $(FSEXTRADEFINE) freeswitch.spec

##
##
##
#####

