//
//  FinderWindowFixer.swift
//  FinderResize
//
//  Created by Eden on 2024/5/6.
//

import Cocoa

func sharedFinderWindowFixer() -> WindowFixer {
  if let fixer = finderWindowFixer {
    return fixer
  }
  finderWindowFixer = WindowFixer(appBundleIdentifier: .finderBundleIdentifier) { new, _, pre in
    resizeNewFinderWindow(new, needChangeWindowPosition: !AppState.shared.effectFirstWindow || hasNoValidWindow(pre))
  }
  return finderWindowFixer!
}

private func hasNoValidWindow(_ windows: [AXUIElement]) -> Bool {
  guard !windows.isEmpty else {
    return true
  }

  for window in windows {
    var attribute: CFTypeRef?
    let error = AXUIElementCopyAttributeValue(window, NSAccessibility.Attribute.role.rawValue as CFString, &attribute)
    if error != .invalidUIElement {
      return false
    }
  }
  return true
}

private var finderWindowFixer: WindowFixer?

private func resizeNewFinderWindow(_ elements: [AXUIElement], needChangeWindowPosition: Bool) {
  for element in elements.filter({ !isQuickLookWindow($0) }) {
    resizeWindow(element)
    guard needChangeWindowPosition else { return }
    placeWindow(element)
    resizeWindow(element)
  }
}

private func isQuickLookWindow(_ window: AXUIElement) -> Bool {
  var subrole: CFTypeRef?
  let result = AXUIElementCopyAttributeValue(window,
                                             NSAccessibility.Attribute.subrole.rawValue as CFString,
                                             &subrole)
  guard result == .success, let subrole = subrole as? String else {
    return false
  }
  return subrole == "Quick Look"
}

private func resizeWindow(_ window: AXUIElement) {
  guard AppState.shared.resizeWindow else { return }

  var size = CGSize(width: AppState.shared.windowSize.width, height: AppState.shared.windowSize.height)
  guard let sizeValue = AXValueCreate(.cgSize, &size) else { return }

  AXUIElementSetAttributeValue(window,
                               NSAccessibility.Attribute.size.rawValue as CFString,
                               sizeValue)
}

private func placeWindow(_ window: AXUIElement) {
  guard AppState.shared.placeWindow else { return }

  var targetScreen: NSScreen?
  switch AppState.shared.screen {
  case .main:
    targetScreen = .screens.first
  case .current:
    targetScreen = .main
  }

  let mainScreen: NSScreen? = .screens.first

  guard let targetScreen, let mainScreen else { return }

  let size = AppState.shared.windowSize
  var point: CGPoint = .zero

  let mainFrame = mainScreen.frame
  let targetVisibleFrame = targetScreen.visibleFrame

  let y = mainFrame.maxY - targetVisibleFrame.maxY
  let resizeFrame = CGRect(x: targetVisibleFrame.minX, y: y, width: targetVisibleFrame.width, height: targetVisibleFrame.height)

  switch AppState.shared.place {
  case .center:
    point.x = resizeFrame.midX - size.width * 0.5
    point.y = resizeFrame.midY - size.height * 0.5

  case .custom:
    point.x = resizeFrame.minX + AppState.shared.position.x
    point.y = resizeFrame.minY + AppState.shared.position.y
  }

  guard let pointValue = AXValueCreate(.cgPoint, &point) else { return }

  AXUIElementSetAttributeValue(window,
                               NSAccessibility.Attribute.position.rawValue as CFString,
                               pointValue)
}

extension String {
  static let finderBundleIdentifier = "com.apple.finder"
}
