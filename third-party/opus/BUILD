load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

headers = [
    "opus.h",
    "opus_defines.h",
    "opus_multistream.h",
    "opus_projection.h",
    "opus_types.h",
]

libs = [
    "opus",
]

genrule(
    name = "opus_build",
    srcs = [
        "build-opus-bazel.sh",
        "opus-1.5.1.tar.gz",
    ],
    cmd_bash = 
    """
    set -ex

    BUILD_ARCH="arm64"

    BUILD_DIR="$(RULEDIR)/build_$${BUILD_ARCH}"
    rm -rf "$$BUILD_DIR"
    mkdir -p "$$BUILD_DIR"

    cp $(location :build-opus-bazel.sh) "$$BUILD_DIR/"
    cp $(location :opus-1.5.1.tar.gz) "$$BUILD_DIR/"

    mkdir -p "$$BUILD_DIR/Public/opus"

    bash $$BUILD_DIR/build-opus-bazel.sh $$BUILD_ARCH "$$BUILD_DIR" opus-1.5.1.tar.gz
    """ +
    "\n".join([
        "cp -f \"$$BUILD_DIR/built/include/opus/{}\" \"$(location Public/opus/{})\"".format(header, header) for header in headers
    ]) +
    "\n" +
    "\n".join([
        "cp -f \"$$BUILD_DIR/built/lib/lib{}.a\" \"$(location Public/opus/lib/lib{}.a)\"".format(lib, lib) for lib in libs
    ]),
    outs = ["Public/opus/" + x for x in headers] +
    ["Public/opus/lib/lib{}.a".format(x) for x in libs],
    tools = [
        "@apple_cross_toolchain//:toolchain_files",
    ],
    visibility = [
        "//visibility:public",
    ]
)

cc_library(
    name = "opus_lib",
    srcs = [":Public/opus/lib/lib" + x + ".a" for x in libs],
)

cc_library(
    name = "opus_cc",
    hdrs = [":Public/opus/" + x for x in headers],
    includes = [
        "Public",
    ],
    deps = [
        ":opus_lib",
    ],
    visibility = [
        "//visibility:public",
    ],
)

objc_library(
    name = "opus",
    module_name = "opus",
    enable_modules = True,
    hdrs = [":Public/opus/" + x for x in headers],
    includes = [
        "Public",
    ],
    deps = [
        ":opus_lib",
    ],
    visibility = [
        "//visibility:public",
    ],
)
