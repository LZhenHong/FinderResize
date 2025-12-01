//
//  FinderWindowFixer.swift
//  FinderResize
//
//  Created by Eden on 2024/5/6.
//

import Cocoa

// MARK: - FinderWindowFixer

enum FinderWindowFixer {
  private static var instance: WindowFixer?

  @discardableResult
  static func shared() -> WindowFixer {
    if let instance {
      return instance
    }

    let fixer = WindowFixer(appBundleIdentifier: .finderBundleIdentifier) { newWindows, _, previousWindows in
      handleNewWindows(newWindows, previousWindows: previousWindows)
    }
    instance = fixer
    return fixer
  }
}

// MARK: - Window Event Handling

private extension FinderWindowFixer {
  static func handleNewWindows(_ newWindows: [AXUIElement], previousWindows: [AXUIElement]) {
    let shouldChangePosition = !AppState.shared.effectFirstWindow || hasNoValidWindow(previousWindows)
    let validWindows = newWindows.filter { !$0.isQuickLookWindow }

    for window in validWindows {
      applyWindowSettings(to: window, changePosition: shouldChangePosition)
    }
  }

  static func applyWindowSettings(to window: AXUIElement, changePosition: Bool) {
    resizeWindow(window)

    guard changePosition else { return }

    placeWindow(window)
    // Resize again after positioning to ensure correct size
    resizeWindow(window)
  }
}

// MARK: - Window Operations

private extension FinderWindowFixer {
  static func resizeWindow(_ window: AXUIElement) {
    guard AppState.shared.resizeWindow else { return }

    let size = AppState.shared.windowSize
    window.setSize(size)
  }

  static func placeWindow(_ window: AXUIElement) {
    guard AppState.shared.placeWindow else { return }
    guard let position = calculateWindowPosition() else { return }

    window.setPosition(position)
  }
}

// MARK: - Window Validation

private extension FinderWindowFixer {
  static func hasNoValidWindow(_ windows: [AXUIElement]) -> Bool {
    guard !windows.isEmpty else { return true }

    return windows.allSatisfy { window in
      window.getAttribute(.role) == nil
    }
  }
}

// MARK: - Screen Position Calculation

private extension FinderWindowFixer {
  static func calculateWindowPosition() -> CGPoint? {
    let targetScreen = resolveTargetScreen()
    let mainScreen = NSScreen.screens.first

    guard let targetScreen, let mainScreen else { return nil }

    let windowSize = AppState.shared.windowSize
    let visibleFrame = convertToAccessibilityCoordinates(
      targetScreen.visibleFrame,
      relativeTo: mainScreen.frame
    )

    return calculatePositionInFrame(visibleFrame, windowSize: windowSize)
  }

  static func resolveTargetScreen() -> NSScreen? {
    switch AppState.shared.screen {
    case .main:
      NSScreen.screens.first
    case .current:
      NSScreen.main
    }
  }

  /// Convert screen coordinates to Accessibility API coordinates.
  /// Accessibility API uses top-left origin, while NSScreen uses bottom-left origin.
  static func convertToAccessibilityCoordinates(_ frame: CGRect, relativeTo mainFrame: CGRect) -> CGRect {
    let y = mainFrame.maxY - frame.maxY
    return CGRect(x: frame.minX, y: y, width: frame.width, height: frame.height)
  }

  static func calculatePositionInFrame(_ frame: CGRect, windowSize: CGSize) -> CGPoint {
    switch AppState.shared.place {
    case .center:
      return CGPoint(
        x: frame.midX - windowSize.width * 0.5,
        y: frame.midY - windowSize.height * 0.5
      )

    case .custom:
      let customPosition = AppState.shared.position
      return CGPoint(
        x: frame.minX + customPosition.x,
        y: frame.minY + customPosition.y
      )
    }
  }
}

// MARK: - AXUIElement Helpers

private extension AXUIElement {
  var isQuickLookWindow: Bool {
    let subrole: String? = getAttribute(.subrole)
    return subrole == .quickLookSubrole
  }

  func getAttribute<T>(_ attribute: NSAccessibility.Attribute) -> T? {
    var value: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(self, attribute.rawValue as CFString, &value)
    guard result == .success else { return nil }
    return value as? T
  }

  func setSize(_ size: CGSize) {
    var mutableSize = size
    guard let value = AXValueCreate(.cgSize, &mutableSize) else { return }
    AXUIElementSetAttributeValue(self, NSAccessibility.Attribute.size.rawValue as CFString, value)
  }

  func setPosition(_ position: CGPoint) {
    var mutablePosition = position
    guard let value = AXValueCreate(.cgPoint, &mutablePosition) else { return }
    AXUIElementSetAttributeValue(self, NSAccessibility.Attribute.position.rawValue as CFString, value)
  }
}

// MARK: - Constants

private extension String {
  static let finderBundleIdentifier = "com.apple.finder"
  static let quickLookSubrole = "Quick Look"
}
