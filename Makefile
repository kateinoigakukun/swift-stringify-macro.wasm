SWIFT_SDK_ID ?= DEVELOPMENT-SNAPSHOT-2024-09-26-a-wasm32-unknown-wasi
TOOLCHAIN_BUNDLE_ID ?= org.swift.61202409251a

Sources/StringifyMacros.wasm:
	SWIFT_BUILD_MACRO_WASM=1 TOOLCHAINS=$(TOOLCHAIN_BUNDLE_ID) swift build --swift-sdk $(SWIFT_SDK_ID) --product StringifyMacros -c release -Xswiftc -Osize
	cp -a .build/wasm32-unknown-wasi/release/StringifyMacros.wasm Sources/StringifyMacros.wasm
	command -v wasm-opt && wasm-opt -Os Sources/StringifyMacros.wasm -o Sources/StringifyMacros.wasm || :

Vendor/swift-foundation:
	mkdir -p Vendor
	git clone --branch "swift-DEVELOPMENT-SNAPSHOT-2024-10-08-a" "https://github.com/apple/swift-foundation" "Vendor/swift-foundation"
	git -C ./Vendor/swift-foundation am ./../../Patches/swift-foundation/0001-Add-Wasm-Macro-boilerplate-to-Package.swift.patch

Sources/FoundationMacros.wasm: Vendor/swift-foundation
	SWIFT_BUILD_MACRO_WASM=1 TOOLCHAINS=$(TOOLCHAIN_BUNDLE_ID) swift build --package-path Vendor/swift-foundation --swift-sdk $(SWIFT_SDK_ID) --product FoundationMacros -c release -Xswiftc -Osize
	cp -a Vendor/swift-foundation/.build/wasm32-unknown-wasi/release/FoundationMacros.wasm Sources/FoundationMacros.wasm
