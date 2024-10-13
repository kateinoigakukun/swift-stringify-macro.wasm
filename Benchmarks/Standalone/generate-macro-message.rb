def write_message_sequence(out, messages)
  messages.each do |message|
    bytes = message.bytesize
    out.write([bytes].pack('Q<'))
    out.write(message)
  end
end

def main
  sources_dir = File.expand_path(File.join(__dir__, '../../Sources'))

  handshake_messages = [
    %Q({"getCapability":{"capability":{"protocolVersion":7}}}),
  ]
  expand_request_messages = [
    %Q({"expandFreestandingMacro":{"discriminator":"$s7Example0015mainswift_tzEGbfMX2_6_33_B384B672EB89465DCC67528E23350CF9Ll9stringifyfMf_","lexicalContext":[],"macro":{"moduleName":"StringifyMacros","name":"stringify","typeName":"StringifyMacro"},"macroRole":"expression","syntax":{"kind":"expression","location":{"column":7,"fileID":"Example/main.swift","fileName":"#{File.join(sources_dir, "Sources/Example/main.swift")}","line":3,"offset":24},"source":"#stringify(1 + 1)"}}}),
    %Q({"expandFreestandingMacro":{"discriminator":"$s7Example0015mainswift_tzEGbfMX3_6_33_B384B672EB89465DCC67528E23350CF9Ll9stringifyfMf0_","lexicalContext":[],"macro":{"moduleName":"StringifyMacros","name":"stringify","typeName":"StringifyMacro"},"macroRole":"expression","syntax":{"kind":"expression","location":{"column":7,"fileID":"Example/main.swift","fileName":"#{File.join(sources_dir, "Sources/Example/main.swift")}","line":4,"offset":49},"source":"#stringify(2 + 3)"}}}),
  ]

  File.open(File.join(__dir__, 'input.swift-plugin-server.bin'), 'wb') do |out|
    messages = handshake_messages + [
      %Q({"loadPluginLibrary":{"libraryPath":"#{File.join(sources_dir, "StringifyMacros.wasm")}","moduleName":"StringifyMacros"}}),
    ] + expand_request_messages
    write_message_sequence(out, messages)
  end

  File.open(File.join(__dir__, 'input.executable.bin'), 'wb') do |out|
    messages = handshake_messages + expand_request_messages
    write_message_sequence(out, messages)
  end
end

if __FILE__ == $0
  main
end
