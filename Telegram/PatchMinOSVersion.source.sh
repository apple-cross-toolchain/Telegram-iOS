#!/bin/sh

set -e

# Resolve DEVELOPER_DIR and add toolchain bin to PATH
if [ -n "${DEVELOPER_DIR:-}" ]; then
	if [ "${DEVELOPER_DIR}" = "${DEVELOPER_DIR#/}" ]; then
		export DEVELOPER_DIR="$(cd "$DEVELOPER_DIR" && pwd -P)"
	fi
	export PATH="$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"
fi

name=<<<NAME>>>
version=<<<MIN_OS_VERSION>>>

f="$1/$name"

plist_path="$f/Info.plist"
plutil -replace MinimumOSVersion -string $version "$plist_path"
if [ "$version" == "14.0" ]; then
	binary_path="$f/$(basename $f | sed -e s/\.appex//g)"
	xcrun lipo "$binary_path" -remove armv7 -o "$binary_path" 2>/dev/null || true
fi
