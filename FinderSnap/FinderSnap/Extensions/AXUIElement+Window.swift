//
//  AXUIElement+Window.swift
//  FinderSnap
//
//  Created by Eden on 2024/5/6.
//

import Cocoa

// MARK: - Window Type Detection

extension AXUIElement {
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
  static let quickLookSubrole = "Quick Look"
}
