#!/usr/bin/bash
PKG_NAME="$1"

if [ -z "$PKG_NAME" ]; then
	echo "$0 [PKG_NAME]"
	exit 0
fi

echo "PKG_NAME=$PKG_NAME"

pushd `pwd`
cd output/h700/build
rm -rf "$PKG_NAME"*

popd

make h700-pkg PKG="$PKG_NAME"
