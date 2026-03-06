#!/bin/sh

set -e

# Resolve DEVELOPER_DIR to an absolute path before any cd.
if [ -z "${DEVELOPER_DIR:-}" ]; then
  echo "DEVELOPER_DIR must be set" >&2
  exit 1
fi
if [ "${DEVELOPER_DIR}" = "${DEVELOPER_DIR#/}" ]; then
  export DEVELOPER_DIR="$(cd "$DEVELOPER_DIR" && pwd -P)"
fi
TOOLCHAIN_BIN="$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin"
export PATH="$TOOLCHAIN_BIN:$PATH"

ARCH="$1"

BUILD_DIR="$2"

MESON_OPTIONS="--buildtype=release --default-library=static -Denable_tools=false -Denable_tests=false"
CROSSFILE=""

if [ "$ARCH" = "arm64" ]; then
    CROSSFILE="../package/crossfiles/arm64-iPhoneOS.meson"
elif [ "$ARCH" = "sim_arm64" ]; then
    rm -f "arm64-iPhoneSimulator-custom.meson"
    TARGET_CROSSFILE="$BUILD_DIR/dav1d/package/crossfiles/arm64-iPhoneSimulator-custom.meson"
    cp "$BUILD_DIR/arm64-iPhoneSimulator.meson" "$TARGET_CROSSFILE"
    custom_xcode_path="${DEVELOPER_DIR}/"
    sed -i "s|/Applications/Xcode.app/Contents/Developer/|$custom_xcode_path|g" "$TARGET_CROSSFILE"
    CROSSFILE="../package/crossfiles/arm64-iPhoneSimulator-custom.meson"
else
    echo "Unsupported architecture $ARCH"
    exit 1
fi

pushd "$BUILD_DIR/dav1d"
rm -rf build
mkdir build
pushd build

meson.py setup .. --cross-file="$CROSSFILE" $MESON_OPTIONS
ninja

popd
popd
