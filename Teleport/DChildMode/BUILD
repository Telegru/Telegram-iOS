load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "DChildMode",
    module_name = "DChildMode",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    deps = [
        "//submodules/BuildConfig:BuildConfig",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/TelegramCore:TelegramCore",
        "//Teleport/DClient:DNetwork",
        "//Teleport/DSessionEvents:DSessionEvents",
    ],
    copts = [
        "-warnings-as-errors",
    ],
    visibility = [
        "//visibility:public",
    ],
)
