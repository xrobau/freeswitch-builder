#!/bin/bash

SRC=$1
VERSION=$2
if [ ! -e $SRC ]; then
	echo Wait, $SRC does not exist.
	exit 1
fi

tar --strip-components=1 -xvf $SRC '*/freeswitch.spec'

SPECFILE=freeswitch.spec
DEVTOOLS=/opt/rh/devtoolset-9/root/usr/bin/

set -x
set -e
sed -ri '/^%define (version|release) /d' $SPECFILE
sed -ri '/^BuildRoot/d' $SPECFILE
sed -ri 's/^(%define nonparsedversion) .+$/\1 %{version}/' $SPECFILE
sed -ri 's/mariadb-connector-c$/MariaDB-shared/' $SPECFILE
sed -ri 's/mariadb-connector-c-devel$/MariaDB-devel/' $SPECFILE

# Openssl 1.1
sed -ri 's/BuildRequires: openssl-devel.+$/BuildRequires: openssl11-devel/' $SPECFILE
sed -ri 's/Requires: openssl.+$/Requires: openssl11/' $SPECFILE

# Replace the %setup line with a link to our derived directory
sed -ri 's/^%setup.+/%setup -b0 -q -n %{extracted}/' $SPECFILE
# And source0
sed -ri 's/^Source0:.+$/Source0: '$(basename $SRC)'/' $SPECFILE

# We already have run bootstrap, this does not need to be redone
sed -ri 's/^(autoreconf.+)/# \1/' $SPECFILE

# Parallel make
#sed -ri 's/^%\{__make}$/%make_build/' $SPECFILE

# Remove kazoo, mongo and signalwire
sed -ri '/^%package (kazoo|application-mongo|event-cdr-mongo|application-signalwire)/,+8d' $SPECFILE
sed -ri '/^%files (kazoo|application-mongo|event-cdr-mongo|application-signalwire)/,+2d' $SPECFILE
sed -ri 's/event_handlers.mod_(kazoo|cdr_mongodb)//' $SPECFILE
sed -ri 's/applications.(mod_mongo|mod_signalwire)//' $SPECFILE

# Add the stuff to enable ccache
sed -ri '/^if test -f bootstrap.sh/iexport PATH=/usr/lib64/ccache${PATH:+:${PATH}}\nexport CCACHE_DIR=/usr/local/ccache\nexport CCACHE_PATH='$DEVTOOLS'\nset\nls -al /usr/local/ccache' $SPECFILE
# The docker container has already enabled devtoolset
sed -ri 's/^(.+devtoolset.+enable)$/# Already enabled\n# \1/' $SPECFILE

# Fix -release
sed -ri '/^%setup/a sed -ir "s/-(release|dev)/-\%{release}/" ./configure.ac' $SPECFILE

SRCPATCHES=$(echo patches/freeswitch/*)
COUNT=1
FILES=""
PATCHES=""
for p in $SRCPATCHES; do
	srcfile=$(basename $p)
	if [[ "$srcfile" == *patch ]]; then
		FILES="${FILES}Patch${COUNT}:\t$srcfile\n"
		PATCHES="${PATCHES}%patch -P${COUNT} -p1\n"
		COUNT=$(( $COUNT + 1 ))
	fi
done

PATCHES="${PATCHES}cp %{SOURCE99} build\/"

# Add our patches and replace the freeswitch.service.file
sed -ri '/^Prefix:/i Source99: freeswitch.service' $SPECFILE
#FILES="Patch1:\t001-display_update.patch\nPatch3:\t003-write-header-with-csv.patch\nPatch"
sed -ri "/^Prefix:/a $FILES" $SPECFILE
#PATCHES="%patch -P1 -p1\n%patch -P3 -p1\ncp %{SOURCE99} build\/"
sed -ri "/^#Hotfix/{N;N;s/$/$PATCHES/}" $SPECFILE

