load(
    "@build_bazel_rules_apple//apple:apple.bzl",
    "apple_static_xcframework_import"
)

apple_static_xcframework_import(
    name = "MyTrackerSDK",
    xcframework_imports = glob([
        "MyTrackerSDK.xcframework/**"
    ]),
    visibility = ["//visibility:public"]
)