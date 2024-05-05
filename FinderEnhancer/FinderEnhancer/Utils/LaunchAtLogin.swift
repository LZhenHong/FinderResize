//
//  LaunchAtLogin.swift
//  Americano
//
//  Created by Eden on 2023/9/26.
//

import Combine
import Foundation
import os.log
import ServiceManagement

enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func toggle() {
        do {
            if isEnabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            print("Failed to \(isEnabled ? "unregister" : "register") launch at login: \(error)")
        }
    }
}
