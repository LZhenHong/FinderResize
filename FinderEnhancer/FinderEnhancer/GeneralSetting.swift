//
//  GeneralSetting.swift
//  FinderEnhancer
//
//  Created by Eden on 2024/5/6.
//

import Cocoa
import SwiftUI

struct GeneralSetting: SettingContentRepresentable {
    var tabViewImage: NSImage? {
        NSImage(systemSymbolName: "gearshape.circle", accessibilityDescription: nil)
    }

    var preferredTitle: String {
        String(localized: "General")
    }
}
