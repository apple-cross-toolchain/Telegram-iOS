package(default_visibility = ["//visibility:public"])

config_setting(
    name = "linux_x86_64",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
)

config_setting(
    name = "linux_arm64",
    constraint_values = [
        "@platforms//cpu:arm64",
        "@platforms//os:linux",
    ],
)

alias(
    name = "cmake_tar_gz",
    actual = select({
        ":linux_x86_64": "@cmake_linux_x86_64_tar_gz//file",
        "//conditions:default": "@cmake_tar_gz//file",
    }),
)

alias(
    name = "ninja_zip",
    actual = select({
        ":linux_x86_64": "@ninja-linux_zip//file",
        "//conditions:default": "@ninja-mac_zip//file",
    }),
)

alias(
    name = "wasi_sdk_clang",
    actual = select({
        ":linux_x86_64": "@wasi_sdk_linux_x86_64//:bin/clang++",
        ":linux_arm64": "@wasi_sdk_linux//:bin/clang++",
        "//conditions:default": "@wasi_sdk_macos//:bin/clang++",
    }),
)

alias(
    name = "wasi_sdk_files",
    actual = select({
        ":linux_x86_64": "@wasi_sdk_linux_x86_64//:all_files",
        ":linux_arm64": "@wasi_sdk_linux//:all_files",
        "//conditions:default": "@wasi_sdk_macos//:all_files",
    }),
)

filegroup(
    name = "apple_cross_files",
    srcs = [
        "@apple_cross_toolchain//:Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Info.plist",
        "@apple_cross_toolchain//:Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Info.plist",
        "@apple_cross_toolchain//:Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/ToolchainInfo.plist",
        "@apple_cross_toolchain//:Xcode.app/Contents/version.plist",
        "@apple_cross_toolchain//:clang_resource_files",
        "@apple_cross_toolchain//:link_tool_files",
        "@apple_cross_toolchain//:ported_tools",
        "@apple_cross_toolchain//:sdk_iphoneos",
        "@apple_cross_toolchain//:sdk_iphonesimulator",
    ],
)
