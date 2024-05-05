//
//  LaunchAtLogin.swift
//  FinderEnhancer
//
//  Created by Eden on 2023/9/26.
//

import Combine
import Foundation
import os.log
import ServiceManagement

enum LaunchAtLogin {
    static let enabledPulisher = CurrentValueSubject<Bool, Never>(isEnabled)

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
            enabledPulisher.send(isEnabled)
        } catch {
            print("Failed to \(isEnabled ? "unregister" : "register") launch at login: \(error)")
        }
    }
}
