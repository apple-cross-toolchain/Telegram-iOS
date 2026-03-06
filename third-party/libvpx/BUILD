load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

headers = [
    "vp8.h",
    "vp8cx.h",
    "vp8dx.h",
    "vpx_codec.h",
    "vpx_decoder.h",
    "vpx_encoder.h",
    "vpx_frame_buffer.h",
    "vpx_image.h",
    "vpx_integer.h",
    "vpx_version.h",
    "vpx_ext_ratectrl.h",
    "vpx_tpl.h",
]

libs = [
    "VPX",
]

filegroup(
    name = "libvpx_sources",
    srcs = glob([
        "libvpx/**/*"
    ]),
)


genrule(
    name = "libvpx_build",
    srcs = [
        "build-libvpx-bazel.sh",
        "0001-Support-arm64-simulator.patch",
        ":libvpx_sources",
    ],
    cmd_bash = 
    """
    set -ex

    # Resolve DEVELOPER_DIR to absolute path
    if [ -n "$${DEVELOPER_DIR:-}" ] && [ "$${DEVELOPER_DIR}" = "$${DEVELOPER_DIR#/}" ]; then
      export DEVELOPER_DIR="$$(cd "$$DEVELOPER_DIR" && pwd -P)"
    fi
    if [ -n "$${DEVELOPER_DIR:-}" ]; then
      export PATH="$$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin:$$PATH"
    fi

    BUILD_ARCH="arm64"
    PLATFORM_HEADER_DIR="arm64-darwin-gcc"
    CLANG_TARGET="arm64-apple-ios13.0"

    BUILD_DIR="$(RULEDIR)/build_$${BUILD_ARCH}"
    rm -rf "$$BUILD_DIR"
    mkdir -p "$$BUILD_DIR"

    YASM_DIR="$$BUILD_DIR/yasm"
    rm -rf "$$YASM_DIR"
    mkdir -p "$$YASM_DIR"
    tar -xf "$(location //third-party/yasm:yasm.tar)" -C "$$YASM_DIR"
    ABS_YASM_DIR="$$(pwd)/$$(dirname $$YASM_DIR)/$$(basename $$YASM_DIR)"

    cp $(location :build-libvpx-bazel.sh) "$$BUILD_DIR/"
    cp $(location :0001-Support-arm64-simulator.patch) "$$BUILD_DIR/"

    SOURCE_PATH="third-party/libvpx/libvpx"

    cp -R "$$SOURCE_PATH" "$$BUILD_DIR/"

    pushd "$$BUILD_DIR/libvpx"
    patch -p1 < ../0001-Support-arm64-simulator.patch
    popd

    mkdir -p "$$BUILD_DIR/Public/libvpx"

    # Create xcodebuild stub for Linux (libvpx configure uses it for version check)
    XCODEBUILD_STUB="$$BUILD_DIR/xcodebuild"
    echo '#!/bin/bash' > "$$XCODEBUILD_STUB"
    echo 'if [ "$$1" = "-version" ]; then echo "Xcode 16.0"; echo "Build version 16A242d"; fi' >> "$$XCODEBUILD_STUB"
    echo 'if [ "$$1" = "-sdk" ]; then xcrun --sdk "$$2" --show-sdk-path 2>/dev/null; fi' >> "$$XCODEBUILD_STUB"
    chmod +x "$$XCODEBUILD_STUB"

    # Patch libvpx configure to use --target instead of -arch for Linux LLVM
    cat > "$$BUILD_DIR/_patch_vpx.py" << 'PYEOF'
import sys
f = sys.argv[1]
with open(f) as fh:
    t = fh.read()
t = t.replace('-arch $${toolchain%%-*}', '--target=arm64-apple-ios13.0')
t = t.replace('-arch $${tgt_isa}', '--target=arm64-apple-ios13.0')
t = t.replace('            CXX="$$($${XCRUN_FIND} clang++)"', '            CXX="$${CXX:-$$($${XCRUN_FIND} clang++)}"')
t = t.replace('            CC="$$($${XCRUN_FIND} clang)"', '            CC="$${CC:-$$($${XCRUN_FIND} clang)}"')
t = t.replace('            AR="$$($${XCRUN_FIND} ar)"', '            AR="$${AR:-$$($${XCRUN_FIND} ar)}"')
t = t.replace('            AS="$$($${XCRUN_FIND} as)"', '            AS="$${AS:-$$($${XCRUN_FIND} as)}"')
t = t.replace('            STRIP="$$($${XCRUN_FIND} strip)"', '            STRIP="$${STRIP:-$$($${XCRUN_FIND} strip)}"')
t = t.replace('            NM="$$($${XCRUN_FIND} nm)"', '            NM="$${NM:-$$($${XCRUN_FIND} nm)}"')
t = t.replace('            RANLIB="$$($${XCRUN_FIND} ranlib)"', '            RANLIB="$${RANLIB:-$$($${XCRUN_FIND} ranlib)}"')
t = t.replace('            LD="$${CXX:-$$($${XCRUN_FIND} ld)}"', '            LD="$${LD:-$${CXX:-$$($${XCRUN_FIND} ld)}}"')
# Disable bitcode (ld64 lacks libxar support)
import re
t = re.sub(r'check_add_[a-z]+flags -fembed-bitcode', 'true', t)
with open(f, 'w') as fh:
    fh.write(t)
PYEOF
    python3 "$$BUILD_DIR/_patch_vpx.py" "$$BUILD_DIR/libvpx/build/make/configure.sh"

    # Set cross-compilation tools
    export CC="$$(xcrun --find clang 2>/dev/null || echo clang) --target=$$CLANG_TARGET"
    export CXX="$$(xcrun --find clang++ 2>/dev/null || echo clang++) --target=$$CLANG_TARGET"
    export LD="$$(xcrun --find clang++ 2>/dev/null || echo clang++) --target=$$CLANG_TARGET"
    export AR="$$(xcrun --find ar 2>/dev/null || echo ar)"
    export AS="$$(xcrun --find as 2>/dev/null || echo as)"

    # Suppress -Werror for overriding-option (--target vs -miphoneos-version-min)
    export CFLAGS="-Wno-error=overriding-option"
    export CXXFLAGS="-Wno-error=overriding-option"

    ABS_BUILD_DIR="$$(pwd)/$$(dirname $$BUILD_DIR)/$$(basename $$BUILD_DIR)"
    PATH="$$ABS_BUILD_DIR:$$PATH:$$ABS_YASM_DIR" bash "$$ABS_BUILD_DIR/build-libvpx-bazel.sh" $$BUILD_ARCH "$$ABS_BUILD_DIR/libvpx" "$$ABS_BUILD_DIR"
    """ +
    "\n".join([
        "cp -f \"$$BUILD_DIR/VPX.framework/Headers/vpx/{}\" \"$(location Public/vpx/{})\"".format(header, header) for header in headers
    ]) +
    "\n" +
    "\n".join([
        "cp -f \"$$BUILD_DIR/VPX.framework/{}\" \"$(location Public/vpx/lib{}.a)\"".format(lib, lib) for lib in libs
    ]) +
    "\n" + "cp -f \"$$BUILD_DIR/VPX.framework/Headers/vpx/$$PLATFORM_HEADER_DIR/vpx_config.h\" \"$(location Public/vpx/vpx_config.h)\"",
    outs = ["Public/vpx/" + x for x in headers] +
    ["Public/vpx/vpx_config.h"] +
    ["Public/vpx/lib{}.a".format(x) for x in libs],
    tools = [
        "//third-party/yasm:yasm.tar",
        "@apple_cross_toolchain//:toolchain_files",
    ],
    visibility = [
        "//visibility:public",
    ]
)

cc_library(
    name = "libvpx_lib",
    srcs = [":Public/vpx/lib" + x + ".a" for x in libs],
)

objc_library(
    name = "vpx",
    module_name = "vpx",
    enable_modules = True,
    hdrs = [":Public/vpx/" + x for x in headers],
    includes = [
        "Public",
    ],
    deps = [
        ":libvpx_lib",
    ],
    visibility = [
        "//visibility:public",
    ],
)
