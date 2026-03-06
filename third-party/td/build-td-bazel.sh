#!/bin/bash

set -e
set -x

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
OPENSSL_DIR="$4"

openssl_crypto_library="${OPENSSL_DIR}/lib/libcrypto.a"
options=""
options="$options -DOPENSSL_FOUND=1"
options="$options -DOPENSSL_CRYPTO_LIBRARY=${openssl_crypto_library}"
options="$options -DOPENSSL_INCLUDE_DIR=${OPENSSL_DIR}/src/include"
options="$options -DCMAKE_BUILD_TYPE=Release"
options="$options -DIOS_DEPLOYMENT_TARGET=13.0"

cd "$BUILD_DIR"

# Generate source files using the host compiler, not the Apple cross toolchain.
SAVED_PATH="$PATH"
CROSS_BIN="$TOOLCHAIN_BIN"
NATIVE_PATH=""
IFS=: read -ra PATH_PARTS <<< "$PATH"
for p in "${PATH_PARTS[@]}"; do
  if [ "$p" != "$CROSS_BIN" ]; then
    NATIVE_PATH="${NATIVE_PATH:+$NATIVE_PATH:}$p"
  fi
done
mkdir native-build
cd native-build
export PATH="$NATIVE_PATH"
CC="/usr/bin/gcc" CXX="/usr/bin/g++" cmake -DTD_GENERATE_SOURCE_FILES=ON ../td
cmake --build . -- -j$(nproc)
export PATH="$SAVED_PATH"
cd ..

if [ "$ARCH" = "arm64" ]; then
  IOS_PLATFORMDIR="$DEVELOPER_DIR/Platforms/iPhoneOS.platform"
  IOS_SYSROOT=($IOS_PLATFORMDIR/Developer/SDKs/iPhoneOS*.sdk)
  TARGET_TRIPLE="arm64-apple-ios13.0"
  export CFLAGS="-Wall --target=${TARGET_TRIPLE} -funwind-tables -isysroot ${IOS_SYSROOT[0]}"
elif [ "$ARCH" = "sim_arm64" ]; then
  IOS_PLATFORMDIR="$DEVELOPER_DIR/Platforms/iPhoneSimulator.platform"
  IOS_SYSROOT=($IOS_PLATFORMDIR/Developer/SDKs/iPhoneSimulator*.sdk)
  TARGET_TRIPLE="arm64-apple-ios13.0-simulator"
  export CFLAGS="-Wall --target=${TARGET_TRIPLE} -funwind-tables -isysroot ${IOS_SYSROOT[0]}"
else
  echo "Unsupported architecture $ARCH"
  exit 1
fi

export CXXFLAGS="$CFLAGS"

mkdir build
cd build

touch toolchain.cmake
echo "set(CMAKE_SYSTEM_NAME Darwin)" >> toolchain.cmake
echo "set(CMAKE_SYSTEM_PROCESSOR aarch64)" >> toolchain.cmake
echo "set(CMAKE_C_COMPILER $TOOLCHAIN_BIN/clang)" >> toolchain.cmake
echo "set(CMAKE_CXX_COMPILER $TOOLCHAIN_BIN/clang++)" >> toolchain.cmake
echo "set(CMAKE_C_COMPILER_TARGET ${TARGET_TRIPLE})" >> toolchain.cmake
echo "set(CMAKE_CXX_COMPILER_TARGET ${TARGET_TRIPLE})" >> toolchain.cmake
echo "set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)" >> toolchain.cmake

cmake -G"Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake -DCMAKE_OSX_SYSROOT=${IOS_SYSROOT[0]} ../td $options
make tde2e -j$(nproc)
