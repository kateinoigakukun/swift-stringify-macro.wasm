Sources/StringifyMacros.wasm:
	SWIFT_BUILD_MACRO_WASM=1 TOOLCHAINS=org.swift.59202407081a swift build --swift-sdk DEVELOPMENT-SNAPSHOT-2024-07-09-a-wasm32-unknown-wasi --product StringifyMacros -c release -Xswiftc -Osize
	cp -a .build/wasm32-unknown-wasi/release/StringifyMacros.wasm Sources/StringifyMacros.wasm
	command -v wasm-opt && wasm-opt -Os Sources/StringifyMacros.wasm -o Sources/StringifyMacros.wasm || :

