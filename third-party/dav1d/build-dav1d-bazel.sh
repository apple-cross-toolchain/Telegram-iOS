#!/bin/bash

set -e

ARCH="$1"

BUILD_DIR="$2"

MESON_OPTIONS="--buildtype=release --default-library=static -Denable_tools=false -Denable_tests=false"
CROSSFILE=""

customize_crossfile() {
    custom_xcode_path="$(xcode-select -p)"
    toolchain_bin="$custom_xcode_path/Toolchains/XcodeDefault.xctoolchain/usr/bin"
    sed -e "s|/Applications/Xcode.app/Contents/Developer|$custom_xcode_path|g" \
        -e "s|'clang++'|'$toolchain_bin/clang++'|g" \
        -e "s|'clang'|'$toolchain_bin/clang'|g" \
        -e "s|^ar = 'ar'|ar = '$toolchain_bin/ar'|" \
        -e "s|^strip = 'strip'|strip = '$toolchain_bin/strip'|" \
        -e "s|'-arch', 'arm64'|'-arch', 'arm64', '--target=$3'|g" \
        "$1" > "$2"
}

if [ "$ARCH" = "arm64" ]; then
    customize_crossfile "$BUILD_DIR/dav1d/package/crossfiles/arm64-iPhoneOS.meson" "$BUILD_DIR/dav1d/package/crossfiles/arm64-iPhoneOS-custom.meson" arm64-apple-ios11.0
    CROSSFILE="../package/crossfiles/arm64-iPhoneOS-custom.meson"
elif [ "$ARCH" = "sim_arm64" ]; then
    customize_crossfile "$BUILD_DIR/arm64-iPhoneSimulator.meson" "$BUILD_DIR/dav1d/package/crossfiles/arm64-iPhoneSimulator-custom.meson" arm64-apple-ios11.0-simulator
    CROSSFILE="../package/crossfiles/arm64-iPhoneSimulator-custom.meson"
elif [ "$ARCH" = "macos_arm64" ]; then
    TARGET_CROSSFILE="$BUILD_DIR/dav1d/package/crossfiles/arm64-MacOSX-custom.meson"
    custom_xcode_path="$(xcode-select -p)"
    MACOS_SYSROOT="$custom_xcode_path/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
    cat > "$TARGET_CROSSFILE" << MESONEOF
[binaries]
c = ['clang', '-arch', 'arm64', '-isysroot', '$MACOS_SYSROOT']
cpp = ['clang++', '-arch', 'arm64', '-isysroot', '$MACOS_SYSROOT']
objc = ['clang', '-arch', 'arm64', '-isysroot', '$MACOS_SYSROOT']
objcpp = ['clang++', '-arch', 'arm64', '-isysroot', '$MACOS_SYSROOT']
ar = 'ar'
strip = 'strip'

[built-in options]
c_args = ['-mmacosx-version-min=14.0']
cpp_args = ['-mmacosx-version-min=14.0']
c_link_args = ['-mmacosx-version-min=14.0']
cpp_link_args = ['-mmacosx-version-min=14.0']
objc_args = ['-mmacosx-version-min=14.0']
objcpp_args = ['-mmacosx-version-min=14.0']

[properties]
root = '$custom_xcode_path/Platforms/MacOSX.platform/Developer'
needs_exe_wrapper = false

[host_machine]
system = 'darwin'
subsystem = 'macos'
kernel = 'xnu'
cpu_family = 'aarch64'
cpu = 'arm64'
endian = 'little'
MESONEOF
    CROSSFILE="../package/crossfiles/arm64-MacOSX-custom.meson"
elif [ "$ARCH" = "linux_arm64" ] || [ "$ARCH" = "linux_x86_64" ]; then
    # Native Linux build - no cross file needed
    CROSSFILE=""
else
    echo "Unsupported architecture $ARCH"
    exit 1
fi

pushd "$BUILD_DIR/dav1d"
rm -rf build
mkdir build
pushd build

MESON_CMD=$(command -v meson.py 2>/dev/null || command -v meson 2>/dev/null || echo meson.py)

if [ -n "$CROSSFILE" ]; then
    $MESON_CMD setup .. --cross-file="$CROSSFILE" $MESON_OPTIONS
else
    $MESON_CMD setup .. $MESON_OPTIONS
fi
ninja

popd
popd

