#!/bin/zsh
[ "${BOOTSTRAP_VERBOSE}" = "" ] || set -x
ME=$(basename $0)

VPATH=.
if [ "$1" ]; then
	VPATH="${1}"
fi
if [ ! -d "${VPATH}" ]; then
	echo "${ME}: VPATH (${VPATH}) does not exist." >&2
	exit 1
fi
echo "Cleaning up any prior configuration."
find . -name config.cache -print | xargs rm -f
find . -name autom4te.cache -print | xargs rm -rf
echo "Making sure we have new configure script."
rm -f configure
if [ -x ${VPATH}/autogen.sh ]; then
	echo "... ${VPATH}/via autogen.sh"
	${VPATH}/autogen.sh --help
elif [ -x ${VPATH}/bootstrap.sh ]; then
	echo "... via ${VPATH}/bootstrap.sh"
	${VPATH}/bootstrap.sh --help
elif [ -x ${VPATH}/bootstrap ]; then
	echo "... via ${VPATH}/bootstrap"
	${VPATH}/bootstrap --help
else
	echo "... via autoreconf"
	autoreconf -fisv ${VPATH}
fi
if [ ! -x ./configure ]; then
	echo "Could not find or produce a ./configure file!"
	exit 1
fi
case "$(arch)" in
x86_64 )	CCMODE=-m64;;
* )		CCMODE=-m32;;
esac
echo "Running configure with preferred arguments"
export	CC="ccache gcc -std=gnu99 ${CCMODE}"
export	CFLAGS='-pipe -Os'
export	CXX="ccache g++ ${CCMODE}"
export	CXXFLAGS='-pipe -Os'
./configure								\
	$@

