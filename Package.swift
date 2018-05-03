// swift-tools-version:4.0

/*
   Copyright 2015-2017 Ryuichi Laboratories and the Yanagiba project contributors

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

import PackageDescription

let package = Package(
  name: "swift-ast",
  products: [
    .executable(
      name: "swift-ast",
      targets: [
        "swift-ast",
      ]
    ),
    .library(
      name: "SwiftAST",
      targets: [
        "Source",
        "Diagnostic",
        "AST",
        "Lexer",
        "Parser",
        "Sema",
      ]
    ),
    .library(
      name: "SwiftAST+Tooling",
      targets: [
        "Source",
        "Diagnostic",
        "AST",
        "Lexer",
        "Parser",
        "Sema",
        "Tooling",
      ]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/yanagiba/bocho",
      .exact("0.1.2")
    ),
  ],
  targets: [
    .target(
      name: "Source",
      dependencies: [
        "Bocho",
      ]
    ),
    .target(
      name: "Diagnostic",
      dependencies: [
        "Source",
      ]
    ),
    .target(
      name: "AST",
      dependencies: [
        "Source",
        "Diagnostic",
      ]
    ),
    .target(
      name: "Lexer",
      dependencies: [
        "Source",
        "Diagnostic",
      ]
    ),
    .target(
      name: "Parser",
      dependencies: [
        "Source",
        "Diagnostic",
        "AST",
        "Lexer",
      ]
    ),
    .target(
      name: "Sema",
      dependencies: [
        "Source",
        "AST",
      ]
    ),
    .target(
      name: "Tooling",
      dependencies: [
        "Parser",
        "Sema",
      ]
    ),
    .target(
      name: "Frontend",
      dependencies: [
        "Tooling",
        "Bocho",
      ]
    ),
    .target(
      name: "swift-ast",
      dependencies: [
        "Frontend",
      ]
    ),

    // MARK: Tests

    .testTarget(
      name: "CanaryTests"
    ),
    .testTarget(
      name: "SourceTests",
      dependencies: [
        "Source",
      ]
    ),
    .testTarget(
      name: "DiagnosticTests",
      dependencies: [
        "Diagnostic",
      ]
    ),
    .testTarget(
      name: "ASTTests",
      dependencies: [
        "AST",
      ]
    ),
    .testTarget(
      name: "ASTVisitorTests",
      dependencies: [
        "AST",
      ]
    ),
    .testTarget(
      name: "LexerTests",
      dependencies: [
        "Lexer",
      ]
    ),
    .testTarget(
      name: "ParserTests",
      dependencies: [
        "Parser",
      ]
    ),
    .testTarget(
      name: "SemaTests",
      dependencies: [
        "Sema",
      ]
    ),
    .testTarget(
      name: "IntegrationTests",
      dependencies: [
        "Frontend",
      ]
    ),
  ],
  swiftLanguageVersions: [4]
)
