load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

filegroup(
    name = "DChatAssets",
    srcs = glob(["Resources/Images.xcassets/**"]),
    visibility = ["//visibility:public"],
)

swift_library(
    name = "DChat",
    module_name = "DChat",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    deps = [
        "//Teleport/TPStrings:TPStrings",
        
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/Display:Display",
        "//submodules/ComponentFlow:ComponentFlow",
        "//submodules/TelegramCore:TelegramCore",
        "//submodules/Postbox:Postbox",
        "//submodules/AccountContext:AccountContext",
        "//submodules/AppBundle:AppBundle",
        "//submodules/TelegramUIPreferences",
        "//submodules/ChatInterfaceState:ChatInterfaceState",
        "//submodules/Pasteboard:Pasteboard",
        "//submodules/ChatPresentationInterfaceState:ChatPresentationInterfaceState"
    ],
    copts = [
        "-warnings-as-errors",
    ],
    visibility = [
        "//visibility:public",
    ],
)
