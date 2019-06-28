#!/bin/sh

#Comment out first
#sudo cp /usr/local/lib/libIP2Proxy.so.1 /usr/lib/x86_64-linux-gnu/
#sudo cp /usr/local/lib/libIP2Proxy.so /usr/lib/x86_64-linux-gnu/

#Check if the IP2Proxy C Library is been installed or not
if [ -e /usr/local/lib/libIP2Proxy.so ]
then
    echo "Detected IP2Proxy C Library."
else
        cat >&2 <<'EOF'
IP2Proxy C Library is not installed in your system. Please get a copy from https://github.com/ip2location/ip2proxy-c and follow the instructions in readme file to install first before installing IP2Proxy Varnish Library
EOF
        exit 1
fi

warn() {
	echo "WARNING: $@" 1>&2
}

case `uname -s` in
Darwin)
	LIBTOOLIZE=glibtoolize
	;;
FreeBSD)
	LIBTOOLIZE=libtoolize
	;;
Linux)
	LIBTOOLIZE=libtoolize
	;;
SunOS)
	LIBTOOLIZE=libtoolize
	;;
*)
	warn "unrecognized platform:" `uname -s`
	LIBTOOLIZE=libtoolize
esac

automake_version=`automake --version | tr ' ' '\n' | egrep '^[0-9]\.[0-9a-z.-]+'`
if [ -z "$automake_version" ] ; then
	warn "unable to determine automake version"
else
	case $automake_version in
		0.*|1.[0-8]|1.[0-8][.-]*)
			warn "automake ($automake_version) detected; 1.9 or newer recommended"
			;;
		*)
			;;
	esac
fi

# check for varnishapi.m4 in custom paths
dataroot=$(pkg-config --variable=datarootdir varnishapi 2>/dev/null)
if [ -z "$dataroot" ] ; then
        cat >&2 <<'EOF'
Package varnishapi was not found in the pkg-config search path.
Perhaps you should add the directory containing `varnishapi.pc'
to the PKG_CONFIG_PATH environment variable
EOF
        exit 1
fi
set -ex

$LIBTOOLIZE --copy --force
aclocal -I m4 -I ${dataroot}/aclocal
autoheader
automake --add-missing --copy --foreign
autoconf
