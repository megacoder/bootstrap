#! /bin/sh

# Bootstrap the project from CVS.

test -r CVS/Entries || {
  echo "$0: CVS directory not found. Normally this script is for"
  echo "bootstrapping a CVS checkout of the project. Continuing anyway..."
  echo ""
}

# Optionally source a local shell script so user can add extra CFLAGS et al.
# on a "semi-permanent" basis. All settings will be automatically exported.
if test -f ./extra-config.sh ; then
  echo "Adding settings from ./extra-config.sh ..."
  cat ./extra-config.sh
  set -a
  . ./extra-config.sh
  set +a
fi

# OS X has "glibtoolize", so be nice and look for that too.
LIBTOOLIZE=""
for prog in libtoolize glibtoolize ; do
  if $prog --version > /dev/null 2>&1 ; then
    LIBTOOLIZE=$prog
    break
  fi
done
if test "x$LIBTOOLIZE" = "x" ; then
  echo "$0: libtoolize not found"
  exit 1
fi
$LIBTOOLIZE --force --automake --copy || {
  echo "$0: $LIBTOOLIZE failed"
  exit 1
}

# OS X fink users may have autoconf macros in /sw/share/aclocal.
# Search other user-specified locations while we're at it.

acdirs=""
for dir in /sw/share/aclocal $AC_M4_DIRS ; do
  if test -d "$dir" ; then
    acdirs="-I $dir $acdirs"
  fi
done
aclocal --force $acdirs || {
  echo "$0: aclocal failed"
  exit 1
}

autoheader --force || {
  echo "$0: autoheader failed"
  exit 1
}
automake --force-missing --add-missing --copy || {
  echo "$0: automake failed"
  exit 1
}
autoconf --force  || {
  echo "$0: autoconf failed"
  exit 1
}

if ./configure "$@" ; then
  echo "Now type 'make' to compile."
else
  echo "$0: configure failed"
  exit 1
fi
