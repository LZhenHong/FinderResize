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
    guard let targetFrame = calculateTargetFrame(changePosition: changePosition) else {
      // Only resize if no position change needed
      if AppState.shared.resizeWindow {
        window.setSize(AppState.shared.windowSize)
      }
      return
    }

    animateWindow(window, to: targetFrame)
  }
}

// MARK: - Frame Calculation

private extension FinderWindowFixer {
  static func calculateTargetFrame(changePosition: Bool) -> CGRect? {
    let state = AppState.shared

    guard changePosition, state.placeWindow else {
      return nil
    }

    guard let position = calculateWindowPosition() else {
      return nil
    }

    let size = state.resizeWindow ? state.windowSize : nil

    // If we have both position and size, return full frame
    if let size {
      return CGRect(origin: position, size: size)
    }

    return nil
  }

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

// MARK: - Window Animation

private extension FinderWindowFixer {
  static func animateWindow(_ window: AXUIElement, to targetFrame: CGRect) {
    // Check if animation is disabled
    if AppState.shared.disableAnimation {
      window.setPosition(targetFrame.origin)
      window.setSize(targetFrame.size)
      return
    }

    guard let currentPosition = window.getPosition(),
          let currentSize = window.getSize()
    else {
      // Fallback: set directly without animation
      window.setPosition(targetFrame.origin)
      window.setSize(targetFrame.size)
      return
    }

    let startFrame = CGRect(origin: currentPosition, size: currentSize)
    let animator = WindowAnimator(window: window, from: startFrame, to: targetFrame)
    animator.start()
  }
}

// MARK: - Window Validation

private extension FinderWindowFixer {
  static func hasNoValidWindow(_ windows: [AXUIElement]) -> Bool {
    guard !windows.isEmpty else { return true }

    return windows.allSatisfy { $0.axRole == nil }
  }
}

// MARK: - Constants

private extension String {
  static let finderBundleIdentifier = "com.apple.finder"
}
