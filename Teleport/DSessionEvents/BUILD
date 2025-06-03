load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "DSessionEvents",
    module_name = "DSessionEvents",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    deps = [
        "//Teleport/DClient:DNetwork",
    ],
    copts = [
        "-warnings-as-errors",
    ],
    visibility = [
        "//visibility:public",
    ],
)
