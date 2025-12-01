//
//  AXUIElement+.swift
//  FinderResize
//
//  Created by Eden on 2024/5/6.
//

import Cocoa

// MARK: - Attribute Access

extension AXUIElement {
  func getAttribute<T>(_ attribute: NSAccessibility.Attribute) -> T? {
    var value: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(self, attribute.rawValue as CFString, &value)
    guard result == .success else { return nil }
    return value as? T
  }

  @discardableResult
  func setAttribute(_ attribute: NSAccessibility.Attribute, value: CFTypeRef) -> Bool {
    let result = AXUIElementSetAttributeValue(self, attribute.rawValue as CFString, value)
    return result == .success
  }
}

// MARK: - Common Attributes

extension AXUIElement {
  var axTitle: String? {
    getAttribute(.title)
  }

  var axRole: String? {
    getAttribute(.role)
  }

  var axSubrole: String? {
    getAttribute(.subrole)
  }

  var axWindows: [AXUIElement]? {
    getAttribute(.windows)
  }
}

// MARK: - Window Operations

extension AXUIElement {
  func setSize(_ size: CGSize) {
    var mutableSize = size
    guard let value = AXValueCreate(.cgSize, &mutableSize) else { return }
    setAttribute(.size, value: value)
  }

  func setPosition(_ position: CGPoint) {
    var mutablePosition = position
    guard let value = AXValueCreate(.cgPoint, &mutablePosition) else { return }
    setAttribute(.position, value: value)
  }

  func getSize() -> CGSize? {
    guard let value: AXValue = getAttribute(.size) else { return nil }
    var size = CGSize.zero
    guard AXValueGetValue(value, .cgSize, &size) else { return nil }
    return size
  }

  func getPosition() -> CGPoint? {
    guard let value: AXValue = getAttribute(.position) else { return nil }
    var position = CGPoint.zero
    guard AXValueGetValue(value, .cgPoint, &position) else { return nil }
    return position
  }
}
