load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

headers = [
    "turbojpeg.h",
    "jpeglib.h",
    "jmorecfg.h",
]

libs = [
    "jpeg",
    "turbojpeg"
]

filegroup(
    name = "mozjpeg_sources",
    srcs = glob([
        "mozjpeg/**/*"
    ]),
)

genrule(
    name = "mozjpeg_build",
    srcs = [
        "build-mozjpeg-bazel.sh",
        ":mozjpeg_sources",
        "@cmake_tar_gz//file",
    ],
    cmd_bash = 
    """
    set -ex

    BUILD_ARCH="arm64"

    BUILD_DIR="$(RULEDIR)/build_$${BUILD_ARCH}"
    rm -rf "$$BUILD_DIR"
    mkdir -p "$$BUILD_DIR"

    CMAKE_DIR="$$(pwd)/$$BUILD_DIR/cmake"
    rm -rf "$$CMAKE_DIR"
    mkdir -p "$$CMAKE_DIR"
    tar -xzf "$(location @cmake_tar_gz//file)" -C "$$CMAKE_DIR"

    cp $(location :build-mozjpeg-bazel.sh) "$$BUILD_DIR/"

    SOURCE_PATH="third-party/mozjpeg/mozjpeg"

    cp -R "$$SOURCE_PATH" "$$BUILD_DIR/"

    mkdir -p "$$BUILD_DIR/Public/mozjpeg"

    PATH="$$CMAKE_DIR/cmake-4.1.2-linux-x86_64/bin:$$PATH" bash $$BUILD_DIR/build-mozjpeg-bazel.sh $$BUILD_ARCH "$$BUILD_DIR/mozjpeg" "$$BUILD_DIR"
    """ +
    "\n".join([
        "cp -f \"$$BUILD_DIR/mozjpeg/{}\" \"$(location Public/mozjpeg/{})\"".format(header, header) for header in headers
    ]) +
    "\n" +
    "\n".join([
        "cp -f \"$$BUILD_DIR/build/lib{}.a\" \"$(location Public/mozjpeg/lib/lib{}.a)\"".format(lib, lib) for lib in libs
    ]) +
    "\n" + "cp -f \"$$BUILD_DIR/build/jconfig.h\" \"$(location Public/mozjpeg/jconfig.h)\"",
    outs = ["Public/mozjpeg/" + x for x in headers] +
    ["Public/mozjpeg/jconfig.h"] +
    ["Public/mozjpeg/lib/lib{}.a".format(x) for x in libs],
    tools = [
        "@apple_cross_toolchain//:toolchain_files",
    ],
    visibility = [
        "//visibility:public",
    ]
)

cc_library(
    name = "mozjpeg_lib",
    srcs = [":Public/mozjpeg/lib/lib" + x + ".a" for x in libs],
)

objc_library(
    name = "mozjpeg",
    module_name = "mozjpeg",
    enable_modules = True,
    hdrs = [":Public/mozjpeg/" + x for x in headers] + [":Public/mozjpeg/jconfig.h"],
    includes = [
        "Public",
    ],
    deps = [
        ":mozjpeg_lib",
    ],
    visibility = [
        "//visibility:public",
    ],
)
