```
$ ruby ./Benchmarks/Standalone/generate-macro-message.rb
$ hyperfine "cat Benchmarks/Standalone/input.executable.bin | .build/debug/StringifyMacros-tool" \
    "cat Benchmarks/Standalone/input.swift-plugin-server.bin | PATH_TO/swift-PR-73031-1547.xctoolchain/usr/bin/swift-plugin-server"
```
