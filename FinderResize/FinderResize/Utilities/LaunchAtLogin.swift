//
//  LaunchAtLogin.swift
//  FinderResize
//
//  Created by Eden on 2023/9/26.
//

import Combine
import Foundation
import ServiceManagement

enum LaunchAtLogin {
  static let enabledPublisher = CurrentValueSubject<Bool, Never>(isEnabled)

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
      enabledPublisher.send(isEnabled)
    } catch {
      debugPrint("Failed to \(isEnabled ? "unregister" : "register") launch at login: \(error)")
    }
  }
}
