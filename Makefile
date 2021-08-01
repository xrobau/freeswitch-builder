## If you change this version, make sure you
## run 'make clean' to nuke all the old spec files.
VERSION=20210729
RELEASE=1
CLANGVERS=12.0.0
NPROCS=$(shell nproc)
JOBS=$(shell echo $$(( $(NPROCS) * 2 )) )
BUILDDIR=$(shell pwd)/build
DOWNLOADS=$(shell pwd)/downloads
RPMSOURCE=$(BUILDDIR)/SOURCES

RPMBASE=$(BUILDDIR)/RPMS/x86_64

VOLUMES=-v /usr/local/ccache:/usr/local/ccache -v $(BUILDDIR):/usr/local/build

CLANGFILE=clang+llvm-$(CLANGVERS)-x86_64-linux-gnu-centos7.tar.xz
CLANGSRC=https://github.com/xrobau/centos7clang/releases/download/v12.0.0/$(CLANGFILE)
CLANGDOCKERTAG=$(shell pwd)/.clang_docker_build

##########
## Things you may want to change
##
## Git hash for libstirshaken 
##   https://github.com/signalwire/libstirshaken
LIBSSHASH=8a12e1c750e86133564be69cfece9ccfe39deb52

## Git hash for libkitchensink
##   https://github.com/signalwire/libks
LIBKSHASH=0b4a6e8181578ed9594cad536c11fb4e284a4849

## libjwt version
##   https://github.com/benmcollins/libjwt/archive
LIBJWTVERS=1.13.1

## Git hash for libsofia-sip 
##   https://github.com/freeswitch/sofia-sip
SOFIAHASH=fbab3b7b3d077105378585d75d61a0a9c6fb7a4e
## What version and release we are claiming it is.
SOFIAVERSION=1.13.4
SOFIARELEASE=22

## Git hash for freeswitch
##   https://github.com/signalwire/freeswitch
FSHASH=5c6fd51c115f4029926197095d436d527277c0e2
## What version of freeswitch we are claiming it is
FSVERSION=1.10.7
## Download these dependancies before building. They're
## mentioned in the spec file, so.. just do it!
FSDEPS=pocketsphinx-0.8.tar.gz sphinxbase-0.8.tar.gz communicator_semi_6000_20080321.tar.gz freeradius-client-1.1.7.tar.gz

## This is what we're tagging the rpm as. You probably want
## to change 'dev2' to something else.
FSRELEASE=$(VERSION).dev2.$(FSSHORT)

##
## If you're adding new RPMS, add them here (after adding a new section below)
RPMS=$(RPMBASE)/$(LIBJWTRPM) $(RPMBASE)/$(LIBKSRPM) $(RPMBASE)/$(LIBSSRPM) $(RPMBASE)/$(FSRPM)
##
##
##########

##########
##
## Wildcard match for all the sub-containers. If you added a new
## container that needs rpms injected into it, add it here.
##
## This is here so you can put something like libksdocker/blah.foo.rpm as
## a requirement, and blah.foo.rpm will be built if it needs to, and then
## moved into place.
##

testdocker/%.rpm libksdocker/%.rpm libssdocker/%.rpm fsdocker/%.rpm: $(RPMBASE)/%.rpm
	cp $(<) $(@)

##
##########

##########
## Other stuff you probably don't need to care about, unless
## you're hacking on releases or something.
##

RPMSUFFIX=el7.x86_64.rpm

LIBSSSHORT = $(shell echo $(LIBSSHASH) | cut -c1-7)
LIBSSFILENAME = libstirshaken-$(VERSION)-$(LIBSSSHORT).tar.gz
LIBSSURL=https://github.com/signalwire/libstirshaken/tarball/$(LIBSSHASH)
LIBSSPREFIX=signalwire-libstirshaken-$(LIBSSSHORT)
LIBSSRPM=libstirshaken-$(VERSION)-$(RELEASE).$(RPMSUFFIX)
LIBSSDEVELRPM=libstirshaken-devel-$(VERSION)-$(RELEASE).$(RPMSUFFIX)
LIBSSDOCKERTAG=$(shell pwd)/.libss_docker_build

LIBKSSHORT = $(shell echo $(LIBKSHASH) | cut -c1-7)
LIBKSFILENAME = libks-$(VERSION)-$(LIBKSSHORT).tar.gz
LIBKSURL=https://github.com/signalwire/libks/tarball/$(LIBKSHASH)
LIBKSRPM=libks-$(VERSION)-$(RELEASE).$(RPMSUFFIX)
LIBKSPREFIX=signalwire-libks-$(LIBKSSHORT)
LIBKSDOCKERTAG=$(shell pwd)/.libks_docker_build

LIBJWTVERS=1.13.1
LIBJWTRPM=libjwt-$(LIBJWTVERS)-1.$(RPMSUFFIX)
LIBJWTDEVELRPM=libjwt-devel-$(LIBJWTVERS)-1.$(RPMSUFFIX)
LIBJWTFILE=libjwt-$(LIBJWTVERS).tar.gz
LIBJWTURL=https://github.com/benmcollins/libjwt/archive/v$(LIBJWTVERS).tar.gz

FSURL=https://github.com/signalwire/freeswitch/tarball/$(FSHASH)
FSSHORT=$(shell echo $(FSHASH) | cut -c1-7)
FSBASEFILENAME=freeswitch-orig-$(VERSION)-$(FSSHORT).tar.gz
FSFILENAME=freeswitch-$(VERSION)-$(FSSHORT).tar.gz
FSPREFIX=signalwire-freeswitch-$(FSSHORT)
FSDOCKERTAG=$(shell pwd)/.fs_docker_build
FSEXTRADEFINE=-D 'release $(FSRELEASE)' -D 'version $(FSVERSION)' -D 'extracted $(FSPREFIX)' -D 'configure_options "LDFLAGS=-L/usr/lib64/openssl11"'
FSPATCHES=$(notdir $(wildcard patches/freeswitch/*))
FSRPM=freeswitch-$(FSVERSION)-$(FSRELEASE).$(RPMSUFFIX)

SOFIAURL=https://github.com/freeswitch/sofia-sip/tarball/$(SOFIAHASH)
SOFIASHORT = $(shell echo $(SOFIAHASH) | cut -c1-7)
SOFIAPREFIX=freeswitch-sofia-sip-$(SOFIASHORT)
SOFIAFILENAME=$(SOFIAPREFIX).tar.gz
SOFIARPM=sofia-sip-$(SOFIAVERSION)-$(SOFIARELEASE).$(RPMSUFFIX)
##
##########

##########
## Automation and stuff in this section. Should all just work.
##
RPMBUILD=rpmbuild --define "_topdir /usr/local/build" -ba

FSDEPDOWNLOAD=$(addprefix $(DOWNLOADS)/,$(FSDEPS))
FSDEPDEST=$(addprefix $(RPMSOURCE)/,$(FSDEPS))
FSPATCHESDEST=$(addprefix $(RPMSOURCE)/,$(FSPATCHES))

##
##########

.PHONY: help shell setup rpms clean distclean

help:
	@echo "Instructions:"
	@echo "  'make shell'     - gives you a shell in the fsbuilder container"
	@echo "  'make rpms'      - build all rpms (into build/RPMS)"
	@echo "  'make setup'     - Makes sure the clang container is ready"
	@echo "  'make clean'     - Removes all packages and builds (except clang)"
	@echo "  'make distclean' - Same as clean but also remove clang"
	@echo "Container names:"
	@echo "  'make clangcontainer'"
	@echo "  'make test'"

shell: $(FSDOCKERTAG) $(RPMSOURCE)/$(FSFILENAME)
	docker run --rm $(VOLUMES) -it fsbuilder:$(VERSION) bash

rpms: setup $(RPMS)

setup: $(CLANGDOCKERTAG) | /usr/local/ccache/ccache.conf $(RPMSOURCE) $(BUILDDIR) $(DOWNLOADS)

clean:
	rm -rf build $(LIBSSDOCKERTAG) $(CLANGDOCKERTAG) $(LIBKSDOCKERTAG) $(FSDOCKERTAG) freeswitch.spec *tar.gz

distclean: clean
	rm -rf clangdocker/$(CLANGFILE)


##########
# Common patterns
$(RPMSOURCE)/%: $(DOWNLOADS)/%
	cp $(<) $(@)

build/%.spec: %.spec
	cp $(<) $(@)

/usr/local/ccache/ccache.conf: ccache.conf
	mkdir -p $(@D) && chmod 777 $(@D)
	cp $(<) $(@)

$(BUILDDIR) $(DOWNLOADS) $(RPMSOURCE):
	mkdir -p $(@) && chmod 777 $(@)

##
##########

##########
##
## Clang 12.0.0 base image
##

.PHONY: clang
clang: setup $(CLANGDOCKERTAG)

$(DOWNLOADS)/$(CLANGFILE): | $(DOWNLOADS)
	wget $(CLANGSRC) -O $(@)

clangdocker/$(CLANGFILE): $(DOWNLOADS)/$(CLANGFILE)
	cp $(<) $(@)

$(CLANGDOCKERTAG): clangdocker/$(CLANGFILE) $(wildcard clangdocker/*)
	@echo Starting $(@)
	docker build --build-arg CLANG=$(CLANGFILE) -t clangbuilder:$(CLANGVERS) clangdocker
	touch $(@)

##
##
##########


######
##
## libjwt
## Built using clang container.
##

.PHONY: libjwt
libjwt: setup $(RPMBASE)/$(LIBJWTRPM)

$(DOWNLOADS)/$(LIBJWTFILE): | $(DOWNLOADS)
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

.PHONY: libks libks-shell
libks: $(RPMBASE)/$(LIBKSRPM)
libks-shell: $(LIBKSDOCKERTAG)
	docker run --rm $(VOLUMES) -it libksbuilder:$(VERSION) bash

$(LIBKSDOCKERTAG): $(CLANGDOCKERTAG) libksdocker/$(LIBJWTRPM) libksdocker/$(LIBJWTDEVELRPM) $(wildcard libksdocker/*)
	@echo Starting $(@)
	docker build --build-arg LIBJWT=$(LIBJWTRPM) --build-arg LIBJWTDEVEL=$(LIBJWTDEVELRPM) -t libksbuilder:$(VERSION) libksdocker
	touch $(@)

$(DOWNLOADS)/$(LIBKSFILENAME):
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

$(DOWNLOADS)/$(LIBSSFILENAME):
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

$(DOWNLOADS)/$(SOFIAFILENAME):
	wget -nc -O $(@) $(SOFIAURL)

build/sofia-sip.spec: sofia-sip.spec
	sed -e 's/__SOFIAVERSION__/$(SOFIAVERSION)/' -e 's/__SOFIARELEASE__/$(SOFIARELEASE)/' -e 's/__SOFIASOURCE__/$(SOFIAFILENAME)/' -e 's/__SOFIAPREFIX__/$(SOFIAPREFIX)/' $< > $(@)

$(RPMBASE)/$(SOFIARPM): $(LIBSSDOCKERTAG) build/sofia-sip.spec $(RPMSOURCE)/$(SOFIAFILENAME)
	docker run --rm $(VOLUMES) -it libssbuilder:$(VERSION) $(RPMBUILD) sofia-sip.spec

##
##
##
#####

#####
## Freeswitch. Finally!

.PHONY: freeswitch freeswitch-dep freeswitch-shell
freeswitch: setup $(RPMBASE)/$(FSRPM)
freeswitch-dep: $(FSDEPDEST)
freeswitch-shell: $(FSDOCKERTAG)
	docker run --rm $(VOLUMES) -it fsbuilder:$(VERSION) bash

## This is generated by a script, taking the source spec file and
## patching it
build/freeswitch.spec: $(RPMSOURCE)/$(FSFILENAME) $(FSPATCHESDEST) $(FSDEPDEST) $(shell pwd)/gen-freeswitchspec.sh
	$(shell pwd)/gen-freeswitchspec.sh $(DOWNLOADS)/$(FSFILENAME) $(FSVERSION)
	cp freeswitch.spec $(@)

## This is a list of the freeswitch dependancies to download.
$(FSDEPDOWNLOAD): | $(DOWNLOADS)
	wget -nc -O $(@) http://files.freeswitch.org/downloads/libs/$(@F)
	
## Some makefile magic to glob all the freeswitch patches into place
.SECONDEXPANSION:
$(FSPATCHESDEST): patches/freeswitch/$$(@F)
	cp $(<) $(@)

## This is the raw file, from github. autoconf/bootstrap needs to be
## run against it.
$(DOWNLOADS)/$(FSBASEFILENAME):
	wget -O $(@) $(FSURL)

## Build our freeswitch building container. We add libss and libsofia to the libssbuilder
## container, and ALSO switch back to RHEL devtoolset-9. No more clang!

## These are all the libsofia rpms we add. I add them all because why not?
SOFIAPMREQS=devel glib glib-devel utils
SOFIAREQS=$(addprefix fsdocker/,$(addsuffix -$(SOFIAVERSION)-$(SOFIARELEASE).$(RPMSUFFIX),sofia-sip $(addprefix sofia-sip-,$(SOFIAPMREQS))))

$(FSDOCKERTAG): fsdocker/$(LIBSSRPM) fsdocker/$(LIBSSDEVELRPM) fsdocker/$(SOFIARPM) $(SOFIAREQS) $(wildcard fsdocker/*)
	@echo Starting $(@)
	docker build --build-arg LIBSS=$(LIBSSRPM) --build-arg LIBSSDEVEL=$(LIBSSDEVELRPM) --build-arg LIBSOFIA=$(SOFIAVERSION)-$(SOFIARELEASE) --build-arg VERSION=$(VERSION) -t fsbuilder:$(VERSION) fsdocker
	touch $(@)

## Now the container is built, we need to build the REAL source package, by
## grabbing the raw code from github, running bootstrap in it, and then
## packaging it back up

## This is the 'real' source package, after autoconf/bootstrap.sh has been run in it.
$(DOWNLOADS)/$(FSFILENAME): build/autoconf/$(FSPREFIX)/Makefile.in
	tar -C build/autoconf -cf $(@) $(FSPREFIX)

## Pull down BASEFILENAME (from github), extract it and use the fsbuilder container
## to run boostrap.
build/autoconf/$(FSPREFIX)/Makefile.in: $(DOWNLOADS)/$(FSBASEFILENAME) $(FSDOCKERTAG)
	mkdir -p build/autoconf && tar -C build/autoconf -xf $<
	docker run --rm $(VOLUMES) -w /usr/local/build/autoconf/$(FSPREFIX) -it fsbuilder:$(VERSION) ./bootstrap.sh -j

## And now we can finally build all the RPMS.
$(RPMBASE)/$(FSRPM): $(FSDEPDEST) $(RPMSOURCE)/$(FSFILENAME) build/freeswitch.spec | $(FSDOCKERTAG)
	docker run --rm $(VOLUMES) -it fsbuilder:$(VERSION) $(RPMBUILD) $(FSEXTRADEFINE) freeswitch.spec

##
##
##
#####

#####
##
##
TESTDOCKERTAG=$(shell pwd)/.test_docker_build
TESTPREFIX=freeswitch
TESTSUFFIX=-$(FSVERSION)-$(FSRELEASE).$(RPMSUFFIX)
FSTESTPKGS=lua application-httapi database-mariadb application-directory event-json-cdr application-limit xml-cdr application-lcr application-nibblebill format-native-file xml-curl application-db lang-en application-curl application-hash format-local-stream debuginfo
TESTRPMS=$(TESTPREFIX)$(TESTSUFFIX) $(addsuffix $(TESTSUFFIX),$(addprefix freeswitch-,$(FSTESTPKGS)))
TESTRPMSDEST=$(addprefix testdocker/,$(TESTRPMS))

.PHONY: test
test: $(TESTDOCKERTAG) build/install.sh
	docker run --rm $(VOLUMES) -it testdocker:$(VERSION) bash

testdocker/fs.tar.gz: fs.tar.gz
	cp $@ $<

fs.tar.gz:
	@echo You need to create fs.tar.gz somehow. Tar up /etc/freeswitch or something
	@exit 1

$(TESTDOCKERTAG): testdocker/fs.tar.gz $(RPMBASE)/$(FSRPM) $(TESTRPMSDEST) $(wildcard testdocker/*)
	@echo Starting $(@)
	docker build --build-arg VERSION=$(VERSION) --build-arg FREESWITCH=$(FSVERSION)-$(FSRELEASE).$(RPMSUFFIX) -t testdocker:$(VERSION) testdocker
	touch $(@)

