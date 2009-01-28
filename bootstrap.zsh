#!/bin/zsh

ME=$(basename $0)
USAGE="usage: ${ME} [-p prefix] [package]"

PREFIX=
while getopts p: c
do
	case "${c}" in
	p )	PREFIX="${OPTARG}";;
	* )	echo "${USAGE}" >&2; exit 1;;
	esac
done
shift $(expr ${OPTIND} - 1)

if [ "${PREFIX}" = "" ]; then
	if [ $# -lt 1 ]; then
		echo "${USAGE}" >&2
		exit 1
	fi
	PREFIX="/opt/${1}"
	shift
fi

if [ ! "${PREFIX}" ]; then
	echo "${ME}: either use '-p prefix' or give a package name." >&2
	echo "${USAGE}" >&2
	exit 1
fi

echo "Cleaning up any prior configuration."
find . -name config.cache -print | xargs rm -f
find . -name autom4te.cache -print | xargs rm -rf
echo "Making sure we have a configure script."
if [ ! -f configure ]; then
	if [ -x autogen.sh ]; then
		echo "... via autogen.sh"
		./autogen.sh --help
	elif [ -x bootstrap.sh ]; then
		echo "... via bootstrap.sh"
		./bootstrap.sh --help
	else
		echo "... via autodeconf"
		autoreconf -fis
	fi
fi
if [ ! -x ./configure ]; then
	echo "Could not find or produce a ./configure file!"
	exit 1
fi
echo "Running configure with preferred arguments"
export	CC='gcc -m64 -std=gnu99'
export	CFLAGS='-pipe -Os'
export	CXX='ccache g++ -m64'
export	CXXFLAGS='-pipe -Os'
./configure								\
	--prefix="${PREFIX}"						\
	"$@"								|
tee configure.log

