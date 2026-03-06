#! /bin/sh

set -ex

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
BUILD_DIR=$(echo "$(cd "$(dirname "$2")"; pwd -P)/$(basename "$2")")
SOURCE_CODE_ARCHIVE="$3"

MINIOSVERSION="13.0"

OPT_CFLAGS="-Os -g"
OPT_LDFLAGS=""
OPT_CONFIG_ARGS=""

OUTPUTDIR="$BUILD_DIR/Public"

# where we will keep our sources and build from.
SRCDIR="${BUILD_DIR}/src"
mkdir -p $SRCDIR
# where we will store intermediary builds
INTERDIR="${BUILD_DIR}/built"
mkdir -p $INTERDIR

########################################

tar zxf "$BUILD_DIR/$SOURCE_CODE_ARCHIVE" -C $SRCDIR
cd "${SRCDIR}/opus-"*

if [ "${ARCH}" = "linux_x86_64" ] || [ "${ARCH}" = "linux_arm64" ]; then
  mkdir -p "${INTERDIR}"

  # Keep it simple and portable for container builds.
  ./configure \
    --disable-shared \
    --enable-static \
    --with-pic \
    --disable-extra-programs \
    --disable-doc \
    --disable-asm \
    --enable-intrinsics \
    ${OPT_CONFIG_ARGS} \
    --prefix="${INTERDIR}" \
    CFLAGS="$CFLAGS ${OPT_CFLAGS} -fPIC" \
    LDFLAGS="$LDFLAGS ${OPT_LDFLAGS}"

  make -j"$(getconf _NPROCESSORS_ONLN || echo 4)"
  make install
  exit 0
elif [ "${ARCH}" == "x86_64" ]; then
  PLATFORM="iphonesimulator"
  TARGET_TRIPLE="x86_64-apple-ios$MINIOSVERSION-simulator"
  MIN_VERSION_FLAG="-mios-simulator-version-min=${MINIOSVERSION}"
  EXTRA_CONFIG="--host=x86_64-apple-darwin"
elif [ "${ARCH}" == "sim_arm64" ]; then
  PLATFORM="iphonesimulator"
  TARGET_TRIPLE="arm64-apple-ios$MINIOSVERSION-simulator"
  MIN_VERSION_FLAG="-mios-simulator-version-min=${MINIOSVERSION}"
  EXTRA_CONFIG="--host=arm-apple-darwin20"
else
  PLATFORM="iphoneos"
  TARGET_TRIPLE="arm64-apple-ios$MINIOSVERSION"
  MIN_VERSION_FLAG="-miphoneos-version-min=${MINIOSVERSION}"
  EXTRA_CONFIG="--host=arm-apple-darwin"
fi

SDK_PATH="$(xcrun --sdk $PLATFORM --show-sdk-path 2>/dev/null)"
CC="$(xcrun --find clang 2>/dev/null || echo clang) --target=${TARGET_TRIPLE}"
AR="$(xcrun --find ar 2>/dev/null || echo ar)"
RANLIB="$(xcrun --find ranlib 2>/dev/null || echo ranlib)"

mkdir -p "${INTERDIR}"

./configure --disable-shared --enable-static --with-pic --disable-extra-programs --disable-doc --disable-asm --enable-intrinsics ${EXTRA_CONFIG} \
  --prefix="${INTERDIR}" \
  CC="$CC" \
  AR="$AR" \
  RANLIB="$RANLIB" \
  LDFLAGS="$LDFLAGS ${OPT_LDFLAGS} -fPIE ${MIN_VERSION_FLAG} -L${OUTPUTDIR}/lib -isysroot ${SDK_PATH}" \
  CFLAGS="$CFLAGS ${OPT_CFLAGS} -fPIE ${MIN_VERSION_FLAG} -I${OUTPUTDIR}/include -isysroot ${SDK_PATH}" \

make -j
make install
