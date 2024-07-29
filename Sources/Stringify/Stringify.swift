@freestanding(expression) public macro stringify<T>(_ expression: T) -> (T, String) =
    #externalMacro(module: "StringifyMacros", type: "StringifyMacro")
