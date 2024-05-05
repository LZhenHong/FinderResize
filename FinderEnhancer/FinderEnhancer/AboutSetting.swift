//
//  AboutSetting.swift
//  FinderEnhancer
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
}
