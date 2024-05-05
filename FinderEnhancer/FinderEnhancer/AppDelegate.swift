//
//  AppDelegate.swift
//  FinderEnhancer
//
//  Created by Eden on 2024/5/5.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        MenuBarItemController.shared.setUp()
    }
}
