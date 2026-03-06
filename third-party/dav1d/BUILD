load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

generated_headers = [
    "vcs_version.h",
]

headers = [
    "compat/msvc/stdatomic.h",
    "compat/gcc/stdatomic.h",
    "compat/getopt.h",
    "common/dump.h",
    "common/frame.h",
    "common/bitdepth.h",
    "common/attributes.h",
    "common/validate.h",
    "common/intops.h",
    "dav1d/picture.h",
    "dav1d/version.h",
    "dav1d/data.h",
    "dav1d/headers.h",
    "dav1d/common.h",
    "dav1d/dav1d.h",
]

libs = [
    "dav1d",
]

filegroup(
    name = "dav1d_sources",
    srcs = glob([
        "dav1d/**/*"
    ]),
)

genrule(
    name = "dav1d_build",
    srcs = [
        "build-dav1d-bazel.sh",
        "arm64-iPhoneSimulator.meson",
        ":dav1d_sources",
        "@meson_tar_gz//file",
        "@ninja-linux_zip//file",
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

    BUILD_DIR="$(RULEDIR)/build_$${BUILD_ARCH}"
    rm -rf "$$BUILD_DIR"
    mkdir -p "$$BUILD_DIR"

    MESON_DIR="$$(pwd)/$$BUILD_DIR/meson"
    rm -rf "$$MESON_DIR"
    mkdir -p "$$MESON_DIR"
    tar -xzf "$(location @meson_tar_gz//file)" -C "$$MESON_DIR"

    NINJA_DIR="$$(pwd)/$$BUILD_DIR/ninja"
    rm -rf "$$NINJA_DIR"
    mkdir -p "$$NINJA_DIR"
    unzip "$(location @ninja-linux_zip//file)" -d "$$NINJA_DIR"

    cp $(location :build-dav1d-bazel.sh) "$$BUILD_DIR/"
    cp $(location :arm64-iPhoneSimulator.meson) "$$BUILD_DIR/"

    SOURCE_PATH="third-party/dav1d/dav1d"

    cp -R "$$SOURCE_PATH" "$$BUILD_DIR/"

    mkdir -p "$$BUILD_DIR/Public/dav1d"
    mkdir -p "$$BUILD_DIR/Public/compat"
    mkdir -p "$$BUILD_DIR/Public/common"

    # Patch the meson crossfile to use the correct SDK path and cross-compiler.
    XCODE_DEV_DIR="$${DEVELOPER_DIR:?DEVELOPER_DIR must be set}"
    if [ "$$XCODE_DEV_DIR" = "$${XCODE_DEV_DIR#/}" ]; then
      XCODE_DEV_DIR="$$(cd "$$XCODE_DEV_DIR" && pwd -P)"
    fi
    TOOLCHAIN_BIN="$$XCODE_DEV_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin"
    export PATH="$$TOOLCHAIN_BIN:$$PATH"
    CROSS_CLANG="$$(xcrun --find clang 2>/dev/null || echo "$$TOOLCHAIN_BIN/clang")"
    CROSS_CLANGPP="$$(xcrun --find clang++ 2>/dev/null || echo "$$TOOLCHAIN_BIN/clang++")"
    CROSS_AR="$$(xcrun --find ar 2>/dev/null || echo ar)"
    CROSS_STRIP="$$(xcrun --find strip 2>/dev/null || echo strip)"
    CROSSFILE="$$BUILD_DIR/dav1d/package/crossfiles/arm64-iPhoneOS.meson"
    sed -i "s|/Applications/Xcode.app/Contents/Developer|$$XCODE_DEV_DIR|g" "$$CROSSFILE"
    # Replace bare compiler names with cross-compiler full paths in crossfile
    cat > "$$BUILD_DIR/_patch_crossfile.py" << 'PYEOF'
import sys
f, cc, cxx, ar, strip_tool = sys.argv[1:6]
with open(f) as fh:
    t = fh.read()
for old, new in [
    ("c = ['clang'", "c = ['" + cc + "'"),
    ("cpp = ['clang++'", "cpp = ['" + cxx + "'"),
    ("objc = ['clang'", "objc = ['" + cc + "'"),
    ("objcpp = ['clang++'", "objcpp = ['" + cxx + "'"),
    ("ar = 'ar'", "ar = '" + ar + "'"),
    ("strip = 'strip'", "strip = '" + strip_tool + "'"),
    ("'-arch', 'arm64'", "'--target=arm64-apple-ios13.0'"),
]:
    t = t.replace(old, new)
with open(f, 'w') as fh:
    fh.write(t)
PYEOF
    python3 "$$BUILD_DIR/_patch_crossfile.py" "$$CROSSFILE" "$$CROSS_CLANG" "$$CROSS_CLANGPP" "$$CROSS_AR" "$$CROSS_STRIP"

    PATH="$$PATH:$$MESON_DIR/meson-1.6.0:$$NINJA_DIR" bash $$BUILD_DIR/build-dav1d-bazel.sh $$BUILD_ARCH "$$BUILD_DIR"
    """ +
    "\n".join([
        "cp -f \"$$BUILD_DIR/dav1d/build/include/{}\" \"$(location Public/{})\"".format(header, header) for header in generated_headers
    ]) +
    "\n" +
    "\n".join([
        "cp -f \"$$BUILD_DIR/dav1d/include/{}\" \"$(location Public/{})\"".format(header, header) for header in headers
    ]) +
    "\n" +
    "\n".join([
        "cp -f \"$$BUILD_DIR/dav1d/build/src/lib{}.a\" \"$(location Public/dav1d/lib/lib{}.a)\"".format(lib, lib) for lib in libs
    ]),
    outs = ["Public/" + x for x in generated_headers] +
    ["Public/" + x for x in headers] +
    ["Public/dav1d/lib/lib{}.a".format(x) for x in libs],
    tools = [
        "@apple_cross_toolchain//:toolchain_files",
    ],
    visibility = [
        "//visibility:public",
    ]
)

cc_library(
    name = "dav1d_lib",
    srcs = [":Public/dav1d/lib/lib" + x + ".a" for x in libs]
)

objc_library(
    name = "dav1d",
    module_name = "dav1d",
    enable_modules = True,
    hdrs = [":Public/" + x for x in generated_headers],
    includes = [
        "Public",
    ],
    deps = [
        ":dav1d_lib",
    ],
    visibility = [
        "//visibility:public",
    ],
)

