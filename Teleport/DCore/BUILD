load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "DCore",
    module_name = "DCore",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    deps = [],
    copts = [
        "-warnings-as-errors",
    ],
    visibility = [
        "//visibility:public",
    ],
)
