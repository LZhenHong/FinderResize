//
//  AppDelegate.swift
//  FinderEnhancer
//
//  Created by Eden on 2024/5/5.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AXUtils.checkIsTrusted()

        WindowFixer.shared.setUp()
        MenuBarItemController.shared.setUp()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        let trusted = AXUtils.trusted
        debugPrint("ax is trusted: \(trusted)")
        guard trusted != AXUtils.trustPublisher.value else { return }
        AXUtils.trustPublisher.send(trusted)
    }
}
