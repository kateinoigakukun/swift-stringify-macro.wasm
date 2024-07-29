// swift-tools-version: 5.10

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "swift-stringify-macro.wasm",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "Stringify", targets: ["Stringify"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", branch: "main"),
    ],
    targets: [
        .executableTarget(name: "Example", dependencies: ["Stringify"]),
        .target(name: "Stringify", dependencies: ["StringifyMacros"]),
        .macro(
            name: "StringifyMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
    ]
)

if Context.environment["SWIFT_BUILD_MACRO_WASM"] != nil {
    // Ad-hoc build hack for building macro targets as WebAssembly executables
    for (index, target) in package.targets.enumerated() {
        guard case .macro = target.type else { continue }
        package.targets[index] = .executableTarget(name: target.name, dependencies: target.dependencies)
    }
} else if let swiftPluginServerPath = Context.environment["SWIFT_PLUGIN_SERVER_PATH"] {
    // Ad-hoc build hack for loading WebAssembly executables placed in `Sources/<target>.wasm`
    // as Swift compiler plugins

    func dependencyName(_ dependency: Target.Dependency) -> String? {
        switch dependency {
        case let .targetItem(name: name, condition: _),
            let .byNameItem(name: name, condition: _):
            return name
        default:
            return nil
        }
    }
    
    // Find targets that (transitively) depend on macro targets
    var dependents = [String: [Target]]()
    for target in package.targets {
        for dependency in target.dependencies {
            if let name = dependencyName(dependency) {
                dependents[name, default: []].append(target)
            }
        }
    }

    func transitivelyDependentTargets(of targetName: String) -> [Target] {
        var visited = Set<String>()
        var result = [Target]()
        var queue = [targetName]
        while let current = queue.popLast() {
            guard let currentDependents = dependents[current] else { continue }
            for dependent in currentDependents {
                if visited.insert(dependent.name).inserted {
                    result.append(dependent)
                    queue.append(dependent.name)
                }
            }
        }
        return result
    }

    let macroTargets = package.targets.reduce(into: [String: Target]()) { result, target in
        if case .macro = target.type {
            result[target.name] = target
        }
    }

    for macroTarget in macroTargets.values {
        let wasmPath = Context.packageDirectory + "/" + (macroTarget.path ?? "Sources/\(macroTarget.name)") + ".wasm"

        for target in transitivelyDependentTargets(of: macroTarget.name) {
            var swiftSettings = target.swiftSettings ?? []

            swiftSettings.append(.unsafeFlags([
                "-Xfrontend", "-load-plugin",
                "-Xfrontend", "\(wasmPath)#\(swiftPluginServerPath)#\(macroTarget.name)",
            ]))
            target.swiftSettings = swiftSettings
            // Remove the macro target from the dependencies
            target.dependencies.removeAll { dependency in
                dependencyName(dependency) == macroTarget.name
            }
        }
    }
}
