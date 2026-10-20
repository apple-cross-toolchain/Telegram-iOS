
load("//build-system/bazel-utils:applecross.bzl", "APPLECROSS_GENRULE_ENV")

genrule(
    name = "flatc",
    srcs = [
        "@flatbuffers_zip//file",
    ],
    cmd_bash = APPLECROSS_GENRULE_ENV +
"""
set -x
    core_count=$$(getconf _NPROCESSORS_ONLN)
    BUILD_DIR="$(RULEDIR)/build"
    rm -rf "$$BUILD_DIR"
    mkdir -p "$$BUILD_DIR"

    CMAKE_DIR="$$(pwd)/$$BUILD_DIR/cmake"
    rm -rf "$$CMAKE_DIR"
    mkdir -p "$$CMAKE_DIR"
    tar -xf "$(location //build-system/host-tools:cmake_tar_gz)" -C "$$CMAKE_DIR"
    CMAKE_BIN_DIR="$$(dirname "$$(find "$$CMAKE_DIR" -type f -name cmake -perm -u+x | head -n 1)")"

    unzip -q "$(location @flatbuffers_zip//file)" -d "$$BUILD_DIR"
    pushd "$$BUILD_DIR/flatbuffers-24.12.23"
    mkdir build
    cd build
    PATH="$$CMAKE_BIN_DIR:$$PATH" cmake .. -DCMAKE_BUILD_TYPE=Release -DFLATBUFFERS_BUILD_TESTS=0 -DFLATBUFFERS_INSTALL=0 -DFLATBUFFERS_BUILD_FLATLIB=0 -DFLATBUFFERS_STATIC_FLATC=0
    make -j $$core_count
    popd

    cp "$$BUILD_DIR/flatbuffers-24.12.23/build/flatc" "$(location flatc_bin)"
""",
    outs = [
        "flatc_bin",
    ],
    tools = [
        "//build-system/host-tools:cmake_tar_gz",
    ],
    visibility = [
        "//visibility:public",
    ]
)
