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

    var view: AnyView {
        GeneralSettingView(state: .shared)
            .frame(width: 400)
            .eraseToAnyView()
    }
}

struct GeneralSettingView: View {
    @ObservedObject var state: AppState

    @State private var accessibilityEnable = AXUtils.trusted

    var requestPermissionView: some View {
        VStack(alignment: .leading) {
            Button("Open Accessibility Settings") {
                AXUtils.openAccessibilitySetting()
            }
        }
    }

    var grantPermissionView: some View {
        Text("Granted.")
            .foregroundColor(.green)
            .bold()
    }

    @ViewBuilder var accessibilityView: some View {
        HStack(alignment: .center) {
            Text("Accessibility access status:")
            if accessibilityEnable {
                grantPermissionView
            } else {
                requestPermissionView
            }
        }
        .padding(.bottom, 3)
        Text("FinderEnhancer requires Accessibility access to resize Finder window.")
            .fixedSize(horizontal: false, vertical: true)
            .settingPropmt()
    }

    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }

    @ViewBuilder var sizeView: some View {
        Toggle("Resize window to:", isOn: state.$resizeWindow)
        HStack {
            EmptyView()
                .frame(width: 13)
            HStack {
                Text("Width")
                    .font(.subheadline)
                TextField("Width", value: state.$windowSize.width, formatter: formatter)
                    .font(.subheadline)
                    .frame(width: 50)
            }
            HStack {
                Text("Height")
                    .font(.subheadline)
                TextField("Height", value: state.$windowSize.height, formatter: formatter)
                    .font(.subheadline)
                    .frame(width: 50)
            }
            .padding(.leading, 20)
        }
        .padding(.top, 1)
    }

    var body: some View {
        VStack(alignment: .leading) {
            accessibilityView

            Divider()

            sizeView
        }
        .padding()
        .onReceive(AXUtils.trustPublisher) { accessibilityEnable = $0 }
    }
}

#Preview {
    GeneralSettingView(state: .shared)
        .frame(width: 400)
}
