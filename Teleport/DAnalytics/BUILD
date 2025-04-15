load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "DAnalytics",
    module_name = "DAnalytics",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    deps = [
        "//submodules/BuildConfig:BuildConfig",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "@MyTrackerSDK//:MyTrackerSDK"
    ],
    copts = [
        "-warnings-as-errors",
    ],
    visibility = [
        "//visibility:public",
    ],
)
