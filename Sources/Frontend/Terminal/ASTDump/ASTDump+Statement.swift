/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import AST
import Bocho

extension Statement {
  var ttyDump: String {
    switch self {
    case let ttyAstDumpRepresentable as TTYASTDumpRepresentable:
      return ttyAstDumpRepresentable.ttyDump
    default:
      return "(" +
        "unknown" +
        ")" +
        " " +
        "<range>\(sourceRange.ttyDescription)</range>"
    }
  }
}

extension BreakStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("break_stmt", sourceRange)
    let body = labelName.map { ["label_name: `\($0)`".indented] } ?? []
    return ([head] + body).joined(separator: "\n")
  }
}

extension CompilerControlStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("compiler_ctrl_stmt", sourceRange)
    var body = String.indent
    switch kind {
    case .if(let condition):
      body += "kind: `if`, condition: `\(condition)`"
    case .elseif(let condition):
      body += "kind: `elseif`, condition: `\(condition)`"
    case .else:
      body += "kind: `else`"
    case .endif:
      body += "kind: `endif`"
    case let .sourceLocation(fileName, lineNumber):
      body += "kind: `source_location`"
      if let fileName = fileName, let lineNumber = lineNumber {
        body += ", file_name: `\(fileName)`, line_number: `\(lineNumber)`"
      }
    }
    return "\(head)\n\(body)"
  }
}

extension ContinueStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("continue_stmt", sourceRange)
    let body = labelName.map { ["label_name: `\($0)`".indented] } ?? []
    return ([head] + body).joined(separator: "\n")
  }
}

extension DeferStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("defer_stmt", sourceRange)
    let body = codeBlock.ttyDump.indented
    return "\(head)\n\(body)"
  }
}

extension DoStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("do_stmt", sourceRange)
    let body = codeBlock.ttyDump.indented
    var catches = "catches:".indented
    if catchClauses.isEmpty {
      catches += " &lt;empty&gt;"
    }
    for (index, catchClause) in catchClauses.enumerated() {
      catches += "\n"
      catches += "\(index): ".indented
      switch (catchClause.pattern, catchClause.whereExpression) {
      case (nil, nil):
        catches += "&lt;catch_all&gt;"
      case (let pattern?, nil):
        catches += "pattern: `\(pattern.textDescription)`"
      case (nil, let expr?):
        catches += "where: `\(expr.ttyDump)`"
      case let (pattern?, expr?):
        catches += "pattern: `\(pattern.textDescription)`, where: `\(expr.ttyDump)`"
      }
      catches += "\n"
      catches += catchClause.codeBlock.ttyDump.indented.indented
    }
    return "\(head)\n\(body)\n\(catches)"
  }
}

extension FallthroughStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("fallthrough_stmt", sourceRange)
  }
}

extension ForInStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    var dumps: [String] = []

    let head = dump("for_stmt", sourceRange)
    dumps.append(head)
    if item.isCaseMatching {
      dumps.append("case_matching: `true`".indented)
    }
    dumps.append("pattern: `\(item.matchingPattern.textDescription)`".indented)
    dumps.append("collection: \(collection.ttyDump)".indented)
    if let whereClause = item.whereClause {
      dumps.append("where: \(whereClause.ttyDump)".indented)
    }
    let body = codeBlock.ttyDump.indented
    dumps.append(body)
    return dumps.joined(separator: "\n")
  }
}

extension GuardStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("guard_stmt", sourceRange)
    let conditions = dump(conditionList).indented
    let body = codeBlock.ttyDump.indented
    return "\(head)\n\(conditions)\n\(body)"
  }
}

extension IfStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("if_stmt", sourceRange)
    let conditions = dump(conditionList).indented
    let body = codeBlock.ttyDump.indented
    let neck = "\(head)\n\(conditions)\n\(body)"

    guard let elseClause = elseClause else {
      return neck
    }
    switch elseClause {
    case .else(let codeBlock):
      return "\(neck)\n" +
        "else:\n\(codeBlock.ttyDump)".indented
    case .elseif(let ifStmt):
      return "\(neck)\n" +
        "elseif:\n\(ifStmt.ttyDump)".indented
    }
  }
}

extension LabeledStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("labeled_stmt", sourceRange)
    let neck = "label_name: `\(labelName)`".indented
    let body = statement.ttyDump.indented
    return "\(head)\n\(neck)\n\(body)"
  }
}

extension RepeatWhileStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("repeat_stmt", sourceRange)
    let condition = "condition: \(conditionExpression.ttyDump)".indented
    let body = codeBlock.ttyDump.indented
    return "\(head)\n\(body)\n\(condition)"
  }
}

extension ReturnStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("return_stmt", sourceRange)
    guard let returnExpr = expression else {
      return head
    }
    let body = returnExpr.ttyDump.indented
    return "\(head)\n\(body)"
  }
}

extension SwitchStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("switch_stmt", sourceRange)
    var body = expression.ttyDump.indented
    body += "\n"
    body += "cases:".indented
    if cases.isEmpty {
      body += " &lt;empty&gt;"
    }
    for (index, eachCase) in cases.enumerated() {
      body += "\n"
      body += "\(index): ".indented
      switch eachCase {
      case let .case(items, stmts):
        body += "kind: `case`"
        body += "\n"
        body += "items:".indented.indented
        if items.isEmpty {
          body += " &lt;empty&gt;" // TODO: can this really happen?
        }
        for (itemIndex, item) in items.enumerated() {
          body += "\n"
          body += "\(itemIndex): pattern: `\(item.pattern)`".indented.indented
          if let whereExpr = item.whereExpression {
            body += "\n"
            body += "where: \(whereExpr.ttyDump)".indented.indented.indented
          }
        }
        body += "\n"
        body += stmts.map({ $0.ttyDump }).joined(separator: "\n").indented.indented
      case .default(let stmts):
        body += "kind: `default`"
        body += "\n"
        body += stmts.map({ $0.ttyDump }).joined(separator: "\n").indented.indented
      }
    }
    return "\(head)\n\(body)"
  }
}

extension ThrowStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("throw_stmt", sourceRange)
    let body = expression.ttyDump.indented
    return "\(head)\n\(body)"
  }
}

extension WhileStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("while_stmt", sourceRange)
    let conditions = dump(conditionList).indented
    let body = codeBlock.ttyDump.indented
    return "\(head)\n\(conditions)\n\(body)"
  }
}
