package(default_visibility = ["//visibility:public"])

platform(
    name = "linux_x86_64",
    constraint_values = [
        "@llvm//constraints/libc:gnu.2.28",
    ],
    exec_properties = {
        "container-image": "docker://gcr.io/flame-public/rbe-ubuntu24-04@sha256:f7db0d4791247f032fdb4451b7c3ba90e567923a341cc6dc43abfc283436791a",
    },
    parents = ["@rules_applecross//platforms:linux_x86_64"],
)
