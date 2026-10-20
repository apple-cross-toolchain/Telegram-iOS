load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("//build-system/bazel-utils:applecross.bzl", "APPLECROSS_GENRULE_ENV")

filegroup(
    name = "yasm_sources",
    srcs = glob([
        "yasm-1.3.0/**/*"
    ]),
)

genrule(
    name = "yasm",
    srcs = [
        ":yasm_sources",
    ],
    cmd_bash = APPLECROSS_GENRULE_ENV +
"""
set -x
    core_count=$$(nproc 2>/dev/null || PATH="$$PATH:/usr/sbin" sysctl -n hw.logicalcpu 2>/dev/null || echo 4)
    BUILD_DIR="$(RULEDIR)/build"
    rm -rf "$$BUILD_DIR"
    mkdir -p "$$BUILD_DIR"

    CMAKE_DIR="$$(pwd)/$$BUILD_DIR/cmake"
    rm -rf "$$CMAKE_DIR"
    mkdir -p "$$CMAKE_DIR"
    tar -xf "$(location //build-system/host-tools:cmake_tar_gz)" -C "$$CMAKE_DIR"

    # Find cmake: try system cmake first, then downloaded cmake
    if command -v cmake >/dev/null 2>&1; then
        CMAKE_BIN="cmake"
    elif [ -n "$$(find "$$CMAKE_DIR" -type f -name cmake -perm -u+x | head -n 1)" ]; then
        CMAKE_BIN="$$(find "$$CMAKE_DIR" -type f -name cmake -perm -u+x | head -n 1)"
    else
        echo "cmake not found"
        exit 1
    fi

    SOURCE_PATH="third-party/yasm/yasm-1.3.0"
    cp -R "$$SOURCE_PATH" "$$BUILD_DIR/"

    pushd "$$BUILD_DIR/yasm-1.3.0"
    mkdir build
    cd build
    "$$CMAKE_BIN" .. -DYASM_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DPYTHON_EXECUTABLE="$$(which python3)"
    make -j $$core_count
    popd

    tar -cf "$(location yasm.tar)" -C "$$BUILD_DIR/yasm-1.3.0/build" .
""",
    outs = [
        "yasm.tar",
    ],
    tools = [
        "//build-system/host-tools:cmake_tar_gz",
    ],
    visibility = [
        "//visibility:public",
    ]
)
