#! /bin/sh

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

SOURCE_DIR="$2"
BUILD_DIR=$(echo "$(cd "$(dirname "$3")"; pwd -P)/$(basename "$3")")

if [ "$ARCH" = "arm64" ]; then
  IOS_PLATFORMDIR="$DEVELOPER_DIR/Platforms/iPhoneOS.platform"
  IOS_SYSROOT=($IOS_PLATFORMDIR/Developer/SDKs/iPhoneOS*.sdk)
  export CFLAGS="-Wall --target=arm64-apple-ios13.0 -funwind-tables -isysroot ${IOS_SYSROOT[0]}"

  cd "$BUILD_DIR"
  mkdir build
  cd build

  touch toolchain.cmake
  echo "set(CMAKE_SYSTEM_NAME Darwin)" >> toolchain.cmake
  echo "set(CMAKE_SYSTEM_PROCESSOR aarch64)" >> toolchain.cmake
  echo "set(CMAKE_C_COMPILER $TOOLCHAIN_BIN/clang)" >> toolchain.cmake
  echo "set(CMAKE_C_COMPILER_TARGET arm64-apple-ios13.0)" >> toolchain.cmake
  echo "set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)" >> toolchain.cmake

  cmake -G"Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake -DCMAKE_OSX_SYSROOT=${IOS_SYSROOT[0]} -DPNG_SUPPORTED=FALSE -DENABLE_SHARED=FALSE -DWITH_JPEG8=1 -DBUILD=10000 -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ../mozjpeg
  make jpeg-static turbojpeg-static
elif [ "$ARCH" = "sim_arm64" ]; then
  IOS_PLATFORMDIR="$(xcode-select -p)/Platforms/iPhoneSimulator.platform"
  IOS_SYSROOT=($IOS_PLATFORMDIR/Developer/SDKs/iPhoneSimulator*.sdk)
  export CFLAGS="-Wall -arch arm64 --target=arm64-apple-ios13.0-simulator -miphonesimulator-version-min=13.0 -funwind-tables"

  cd "$BUILD_DIR"
  mkdir build
  cd build

  touch toolchain.cmake
  echo "set(CMAKE_SYSTEM_NAME Darwin)" >> toolchain.cmake
  echo "set(CMAKE_SYSTEM_PROCESSOR aarch64)" >> toolchain.cmake
  echo "set(CMAKE_C_COMPILER $(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang)" >> toolchain.cmake

  cmake -G"Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake -DCMAKE_OSX_SYSROOT=${IOS_SYSROOT[0]} -DPNG_SUPPORTED=FALSE -DENABLE_SHARED=FALSE -DWITH_JPEG8=1 -DBUILD=10000 -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ../mozjpeg
  make
else
  echo "Unsupported architecture $ARCH"
  exit 1
fi
