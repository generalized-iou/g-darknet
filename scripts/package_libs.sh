#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
LDDS="$(ldd $DIR/../darknet | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//')"
mkdir -p $DIR/../lib
for ldd in $LDDS; do cp $ldd $DIR/../lib/; done
