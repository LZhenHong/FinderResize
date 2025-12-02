//
//  MenuBuilder.swift
//  FinderSnap
//
//  Created by Eden on 2023/9/24.
//

import AppKit

@resultBuilder
enum MenuBuilder {
  // MARK: - Build Block

  static func buildBlock(_ components: [NSMenuItem]...) -> [NSMenuItem] {
    components.flatMap { $0 }
  }

  // MARK: - Build Expression

  static func buildExpression(_ expression: MenuItemBuilder) -> [NSMenuItem] {
    [expression.build()]
  }

  static func buildExpression(_ expression: NSMenuItem) -> [NSMenuItem] {
    [expression]
  }

  static func buildExpression(_ expression: [NSMenuItem]) -> [NSMenuItem] {
    expression
  }

  // MARK: - Control Flow

  static func buildOptional(_ component: [NSMenuItem]?) -> [NSMenuItem] {
    component ?? []
  }

  static func buildEither(first component: [NSMenuItem]) -> [NSMenuItem] {
    component
  }

  static func buildEither(second component: [NSMenuItem]) -> [NSMenuItem] {
    component
  }

  static func buildArray(_ components: [[NSMenuItem]]) -> [NSMenuItem] {
    components.flatMap { $0 }
  }
}

extension NSMenu {
  convenience init(@MenuBuilder _ builder: () -> [NSMenuItem]) {
    self.init()
    items = builder()
  }
}
