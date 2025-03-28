//
//  AboutSetting.swift
//  FinderResize
//
//  Created by Eden on 2024/5/6.
//

import Cocoa
import SwiftUI

struct AboutSetting: SettingContentRepresentable {
  var tabViewImage: NSImage? {
    NSImage(systemSymbolName: "info.circle", accessibilityDescription: nil)
  }

  var preferredTitle: String {
    String(localized: "About")
  }

  var view: AnyView {
    AboutSettingView()
      .eraseToAnyView()
  }
}

struct AboutSettingView: View {
  var displayVersion: String {
    "\(Bundle.main.appVersion ?? "1.0.0") (\(Bundle.main.buildVersion ?? "1"))"
  }

  var body: some View {
    VStack {
      Image(nsImage: NSApp.applicationIconImage)
      Text(Bundle.main.appName ?? "FinderResize")
        .font(.title)
        .fontWeight(.bold)
      Text("Version: \(displayVersion)")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .padding(.top, 10)
    .padding(.bottom, 20)
    .frame(width: 400)
  }
}
