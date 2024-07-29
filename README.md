# swift-stringify-macro.wasm

This repository provides a simple demonstration package for the [WebAssembly-based Swift macro plugin](https://github.com/swiftlang/swift/pull/73031) effort.

## Using the Pre-Built Macro Plugin

1. **Download and Install the Toolchain**
   Download the toolchain built from the [PR](https://github.com/swiftlang/swift/pull/73031) branch.
    - **macOS:** [Download Toolchain](https://ci.swift.org/job/swift-PR-toolchain-macos/1390/artifact/branch-main/swift-PR-73031-1390-osx.tar.gz)

2. **Build the Package with the Toolchain**
   Replace `path_to_toolchain` with the actual path to the downloaded toolchain.
    ```sh
    $ PATH_TO_TOOLCHAIN=path_to_toolchain/swift-PR-73031-1390.xctoolchain
    # Note: We need SWIFT_PLUGIN_SERVER_PATH until we have SwiftPM integration
    $ SWIFT_PLUGIN_SERVER_PATH=$PATH_TO_TOOLCHAIN/usr/bin/swift-plugin-server \
      $PATH_TO_TOOLCHAIN/usr/bin/swift build --product Example
    ```

3. **Run the Built Executable**
   After building, you can run the executable.
    ```sh
    $ .build/debug/Example
    (2, "1 + 1")
    (5, "2 + 3")
    ```

## Building the WebAssembly Macro Plugin from Source

1. **Install the Swift Toolchain**
   Download and install the `swift-DEVELOPMENT-SNAPSHOT-2024-07-08-a` toolchain from [swift.org](https://swift.org/download/#snapshots).

2. **Install the Swift WebAssembly SDK**
    ```sh
    $ swift sdk install https://github.com/swiftwasm/swift/releases/download/swift-wasm-DEVELOPMENT-SNAPSHOT-2024-07-09-a/swift-wasm-DEVELOPMENT-SNAPSHOT-2024-07-09-a-wasm32-unknown-wasi.artifactbundle.zip
    ```

3. **Build the Plugin**
    ```sh
    $ make Sources/StringifyMacros.wasm
    ```

## Future Directions

### Distributing WebAssembly Macro Plugins as "Artifact Bundles"

TBD

```swift
// Package.swift
let package = Package(
    name: "swift-stringify-macro.wasm",
    products: [
        .library(name: "Stringify", targets: ["Stringify"]),
    ],
    targets: [
        .target(name: "Stringify", dependencies: ["StringifyMacros"]),
    ]
)

if let tag = Context.gitInformation?.currentTag, Context.environment["LOCAL_DEVELOPMENT"] == nil {
    // Use the pre-built plugin
    package.targets.append(
        .binaryTarget(
            name: "StringifyMacros",
            url: "https://github.com/kateinoigakukun/swift-stringify-macro.wasm/releases/download/\(tag)/StringifyMacros.artifactbundle.zip",
            checksum: "sha256:..."
        )
    )
} else {
    // For local development or non-tagged state, build the plugin from source
    package.dependencies.append(.package(url: "https://github.com/swiftlang/swift-syntax", branch: "main"))
    package.targets.append(
        .macro(
            name: "StringifyMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        )
    )
}
```

### Steps to Achieve This

- Add a new artifact bundle type for distributing macro plugins (initially for WebAssembly plugins, with potential future support for native plugins).
- Update SwiftPM to support the new `-load-plugin` option.
- Add a way to build and package macro plugins as artifact bundles.

This approach leverages existing SwiftPM concepts, should be relatively straightforward extension of the existing SwiftPM concepts.
