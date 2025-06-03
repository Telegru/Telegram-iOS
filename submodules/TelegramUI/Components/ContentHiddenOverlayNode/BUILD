load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "ContentHiddenOverlayNode",
    module_name = "ContentHiddenOverlayNode",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/Display",
        "//submodules/AsyncDisplayKit",
        "//submodules/TelegramUIPreferences",
        "//submodules/TelegramPresentationData",
        "//Teleport/TPStrings:TPStrings"
    ],
    visibility = [
        "//visibility:public",
    ],
)
