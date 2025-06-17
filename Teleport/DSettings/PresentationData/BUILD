load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "DSettingsPresentationData",
    module_name = "DSettingsPresentationData",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    deps = [
        "//submodules/AppBundle:AppBundle",
        "//submodules/TelegramUIPreferences:TelegramUIPreferences",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/TelegramCore:TelegramCore",
    ],
    copts = [
        "-warnings-as-errors",
    ],
    visibility = [
        "//visibility:public",
    ],
)
