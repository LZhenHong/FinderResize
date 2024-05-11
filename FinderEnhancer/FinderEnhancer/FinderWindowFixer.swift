//
//  FinderWindowFixer.swift
//  FinderEnhancer
//
//  Created by Eden on 2024/5/6.
//

import Cocoa

func sharedFinderWindowFixer() -> WindowFixer {
    if let fixer = finderWindowFixer {
        return fixer
    }
    finderWindowFixer = WindowFixer(appBundleIdentifier: .finderBundleIdentifier) { resizeNewFinderWindow($0) }
    return finderWindowFixer!
}

private var finderWindowFixer: WindowFixer?

private func resizeNewFinderWindow(_ elements: [AXUIElement]) {
    for element in elements {
        resizeWindow(element)
        replaceWindow(element)
        resizeWindow(element)
    }
}

private func resizeWindow(_ window: AXUIElement) {
    guard AppState.shared.resizeWindow else { return }

    var size = CGSize(width: AppState.shared.windowSize.width, height: AppState.shared.windowSize.height)
    guard let sizeValue = AXValueCreate(.cgSize, &size) else { return }

    AXUIElementSetAttributeValue(window,
                                 NSAccessibility.Attribute.size.rawValue as CFString,
                                 sizeValue)
}

private func replaceWindow(_ window: AXUIElement) {
    guard AppState.shared.replaceWindow else { return }

    var screen: NSScreen?
    switch AppState.shared.screen {
    case .main:
        screen = .screens.first
    case .current:
        screen = .main
    }

    guard let screen else { return }

    let size = AppState.shared.windowSize
    var point: CGPoint = .zero
    let frame = screen.visibleFrame
    switch AppState.shared.place {
    case .center:
        point.x = frame.midX - size.width * 0.5
        point.y = frame.midY - size.height * 0.5
    case .custom:
        point.x = frame.minX + AppState.shared.position.x
        point.y = frame.minY + AppState.shared.position.y
    }

    guard let pointValue = AXValueCreate(.cgPoint, &point) else { return }

    AXUIElementSetAttributeValue(window,
                                 NSAccessibility.Attribute.position.rawValue as CFString,
                                 pointValue)
}

extension String {
    static let finderBundleIdentifier = "com.apple.finder"
}
