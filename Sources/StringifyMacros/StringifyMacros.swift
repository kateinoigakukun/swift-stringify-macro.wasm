import SwiftSyntax
import SwiftSyntaxMacros
import SwiftCompilerPlugin

public enum StringifyMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) -> ExprSyntax {
    guard let argument = node.arguments.first?.expression else {
      fatalError("compiler bug: the macro does not have any arguments")
    }

    return "(\(argument), \(literal: argument.description))"
  }
}

@main struct StringifyMacros: CompilerPlugin {
    var providingMacros: [any Macro.Type] {
        return [StringifyMacro.self]
    }
}
