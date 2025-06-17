load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

filegroup(
    name = "DSettingsAssets",
    srcs = glob(["Resources/Images.xcassets/**"]),
    visibility = ["//visibility:public"],
)

swift_library(
    name = "DSettings",
    module_name = "DSettings",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    deps = [
        "//Teleport/TPStrings:TPStrings",
        "//Teleport/DClient:DNetwork",
        "//submodules/AppBundle:AppBundle",
        "//submodules/SSignalKit/SSignalKit:SSignalKit",
        "//submodules/LegacyComponents:LegacyComponents",
        "//submodules/RMIntro:RMIntro",
        "//submodules/TelegramUIPreferences:TelegramUIPreferences",
        "//submodules/AccountContext:AccountContext",
    ],
    copts = [
        "-warnings-as-errors",
    ],
    visibility = [
        "//visibility:public",
    ],
)
