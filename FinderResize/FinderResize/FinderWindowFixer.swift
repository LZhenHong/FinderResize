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
    let resizableWindows = newWindows.filter(\.shouldResize)

    for window in resizableWindows {
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

    return windows.allSatisfy { $0.axRole == nil }
  }
}

// MARK: - Screen Position Calculation

private extension FinderWindowFixer {
  static func calculateWindowPosition() -> CGPoint? {
    let targetScreen = resolveTargetScreen()
    let mainScreen = NSScreen.screens.first

    guard let targetScreen, let mainScreen else { return nil }

    let windowSize = AppState.shared.windowSize
    let visibleFrame = targetScreen.visibleFrame.toAccessibilityCoordinates(relativeTo: mainScreen.frame)

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

  static func calculatePositionInFrame(_ frame: CGRect, windowSize: CGSize) -> CGPoint {
    switch AppState.shared.place {
    case .center:
      frame.centerPoint(for: windowSize)
    case .custom:
      frame.originPoint(withOffset: AppState.shared.position)
    }
  }
}

// MARK: - Window Type Detection

private extension AXUIElement {
  /// Determines if this window should be resized.
  /// Excludes special windows like Quick Look and DMG installer windows.
  var shouldResize: Bool {
    let dominated = isQuickLookWindow || isDiskImageWindow
    debugPrint("Window shouldResize: \(!dominated), isQuickLook: \(isQuickLookWindow), isDiskImage: \(isDiskImageWindow)")
    return !dominated
  }

  var isQuickLookWindow: Bool {
    axSubrole == .quickLookSubrole
  }

  /// Checks if this window displays a mounted disk image (DMG).
  var isDiskImageWindow: Bool {
    guard let title = axTitle else {
      debugPrint("isDiskImageWindow: no window title")
      return false
    }

    debugPrint("isDiskImageWindow: window title = \(title)")

    let volumeURL = URL.volume(named: title)

    // Check if this path exists and is a directory
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: volumeURL.path, isDirectory: &isDirectory),
          isDirectory.boolValue
    else {
      debugPrint("isDiskImageWindow: \(volumeURL.path) is not a valid directory")
      return false
    }

    let isDiskImage = volumeURL.isDiskImage
    debugPrint("isDiskImageWindow: isDiskImage = \(isDiskImage)")
    return isDiskImage
  }
}

// MARK: - Constants

private extension String {
  static let finderBundleIdentifier = "com.apple.finder"
  static let quickLookSubrole = "Quick Look"
}
