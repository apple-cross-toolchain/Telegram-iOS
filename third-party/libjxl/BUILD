
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("//build-system/bazel-utils:applecross.bzl", "APPLECROSS_GENRULE_ENV")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

headers = [
    "jxl/codestream_header.h",
    "jxl/cms_interface.h",
    "jxl/color_encoding.h",
    "jxl/decode_cxx.h",
    "jxl/decode.h",
    "jxl/encode_cxx.h",
    "jxl/encode.h",
    "jxl/jxl_export.h",
    "jxl/jxl_threads_export.h",
    "jxl/memory_manager.h",
    "jxl/parallel_runner.h",
    "jxl/stats.h",
    "jxl/types.h",
    "jxl/version.h",
]

libs = [
    "jxl",
]


brotli_libs = [
    "libbrotlicommon",
    "libbrotlidec",
    "libbrotlienc",
]

highway_libs = [
    "libhwy"
]

filegroup(
    name = "libjxl_sources",
    srcs = glob([
        "libjxl/**/*"
    ]),
)

genrule(
    name = "libjxl_build",
    srcs = [
        "build-libjxl-bazel.sh",
        ":libjxl_sources",
    ],
    cmd_bash = APPLECROSS_GENRULE_ENV +
    """
    set -ex

    if [ "$(TARGET_CPU)" == "ios_armv7" ]; then
        BUILD_ARCH="armv7"
    elif [ "$(TARGET_CPU)" == "ios_arm64" ]; then
        BUILD_ARCH="arm64"
    elif [ "$(TARGET_CPU)" == "ios_sim_arm64" ]; then
        BUILD_ARCH="sim_arm64"
    elif [ "$(TARGET_CPU)" == "ios_x86_64" ]; then
        BUILD_ARCH="x86_64"
    elif [ "$(TARGET_CPU)" == "darwin_arm64" ]; then
        BUILD_ARCH="macos_arm64"
    else
        echo "Unsupported architecture $(TARGET_CPU)"
    fi

    BUILD_DIR="$(RULEDIR)/build_$${BUILD_ARCH}"
    rm -rf "$$BUILD_DIR"
    mkdir -p "$$BUILD_DIR"

    CMAKE_DIR="$$(pwd)/$$BUILD_DIR/cmake"
    rm -rf "$$CMAKE_DIR"
    mkdir -p "$$CMAKE_DIR"
    tar -xzf "$(location //build-system/host-tools:cmake_tar_gz)" -C "$$CMAKE_DIR"
    CMAKE_BIN_DIR="$$(dirname "$$(find "$$CMAKE_DIR" -type f -name cmake -perm -u+x | head -n 1)")"

    cp $(location :build-libjxl-bazel.sh) "$$BUILD_DIR/"

    SOURCE_PATH="third-party/libjxl/libjxl"

    cp -R "$$SOURCE_PATH" "$$BUILD_DIR/"

    mkdir -p "$$BUILD_DIR/Public/jxl"

    PATH="$$CMAKE_BIN_DIR:$$PATH" bash $$BUILD_DIR/build-libjxl-bazel.sh $$BUILD_ARCH "$$BUILD_DIR/libjxl" "$$BUILD_DIR"
    """ +
    "\n".join([
        "cp -f \"$$BUILD_DIR/build/lib/include/{}\" \"$(location Public/{})\"".format(header, header) for header in headers
    ]) +
    "\n" +
    "\n".join([
        "cp -f \"$$BUILD_DIR/build/lib/lib{}.a\" \"$(location Public/jxl/lib/lib{}.a)\"".format(lib, lib) for lib in libs
    ]) +
    "\n" +
    "\n".join([
        "cp -f \"$$BUILD_DIR/build/third_party/brotli/{}.a\" \"$(location Public/jxl/lib/{}.a)\"".format(lib, lib) for lib in brotli_libs
    ]) +
    "\n" +
    "\n".join([
        "cp -f \"$$BUILD_DIR/build/third_party/highway/{}.a\" \"$(location Public/jxl/lib/{}.a)\"".format(lib, lib) for lib in highway_libs
    ]),
    outs = ["Public/" + x for x in headers] +
    ["Public/jxl/lib/lib{}.a".format(x) for x in libs] +
    ["Public/jxl/lib/{}.a".format(x) for x in brotli_libs] +
    ["Public/jxl/lib/{}.a".format(x) for x in highway_libs],
    tools = [
        "//build-system/host-tools:apple_cross_files",
        "//build-system/host-tools:cmake_tar_gz",
    ],
    visibility = [
        "//visibility:public",
    ]
)

cc_library(
    name = "jxl_lib",
    srcs = [":Public/jxl/lib/lib" + x + ".a" for x in libs] +
    [":Public/jxl/lib/" + x + ".a" for x in brotli_libs] +
    [":Public/jxl/lib/" + x + ".a" for x in highway_libs],
)

objc_library(
    name = "jxl",
    module_name = "jxl",
    enable_modules = True,
    hdrs = [":Public/" + x for x in headers],
    includes = [
        "Public",
        "Public/jxl",
    ],
    deps = [
        ":jxl_lib",
    ],
    visibility = [
        "//visibility:public",
    ],
)
