//
//  GeneralSetting.swift
//  FinderResize
//
//  Created by Eden on 2024/5/6.
//

import Cocoa
import SettingsKit
import SwiftUI

struct GeneralSettingPane: SettingsPane {
  var tabViewImage: NSImage? {
    NSImage(systemSymbolName: "gearshape.circle", accessibilityDescription: nil)
  }

  var preferredTitle: String {
    String(localized: "General")
  }

  var view: some View {
    GeneralSettingView(state: .shared)
      .frame(width: 400)
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
    Text("FinderResize requires Accessibility access to change Finder's window frame.")
      .fixedSize(horizontal: false, vertical: true)
      .settingPropmt()
  }

  private static let sizeFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimum = 100
    formatter.maximum = 10000
    return formatter
  }()

  private static let zeroFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimum = 0
    formatter.maximum = 10000
    return formatter
  }()

  @ViewBuilder var sizeView: some View {
    Toggle("Resize window to:", isOn: $state.resizeWindow)
    HStack {
      HStack {
        Text("Width")
          .font(.subheadline)
        TextField("Width", value: $state.windowSize.width, formatter: Self.sizeFormatter)
          .font(.subheadline)
          .frame(width: 50)
      }
      HStack {
        Text("Height")
          .font(.subheadline)
        TextField("Height", value: $state.windowSize.height, formatter: Self.sizeFormatter)
          .font(.subheadline)
          .frame(width: 50)
      }
    }
    .padding(.top, 1)
    .padding(.leading, 20)
  }

  @ViewBuilder var positionView: some View {
    Toggle("Move window to:", isOn: $state.placeWindow)
    Picker(selection: $state.place, label: EmptyView()) {
      Text("Center")
        .tag(AppState.WindowPlace.center)
      HStack {
        Text("Custom")
        HStack {
          HStack {
            Text("X")
              .font(.subheadline)
            TextField("X", value: $state.position.x, formatter: Self.zeroFormatter)
              .font(.subheadline)
              .frame(width: 50)
          }
          HStack {
            Text("Y")
              .font(.subheadline)
            TextField("Y", value: $state.position.y, formatter: Self.zeroFormatter)
              .font(.subheadline)
              .frame(width: 50)
          }
        }
        .padding(.leading, 10)
      }
      .tag(AppState.WindowPlace.custom)
    }
    .pickerStyle(.radioGroup)
    .padding(.leading, 12)
  }

  @ViewBuilder var screenView: some View {
    Picker(selection: $state.screen, label: Text("Place window to:")) {
      Text("Main Screen")
        .tag(AppState.WindowScreen.main)
      Text("Active Screen")
        .tag(AppState.WindowScreen.current)
    }
    .pickerStyle(.radioGroup)
    .padding(.leading, 12)
  }

  @ViewBuilder var onlyEffectFirstTimeView: some View {
    Toggle("Only effect to first Finder's window.", isOn: $state.effectFirstWindow)
  }

  var body: some View {
    VStack(alignment: .leading) {
      accessibilityView
      Divider()
      sizeView
      Divider()
      positionView
      onlyEffectFirstTimeView
      Divider()
      screenView
    }
    .padding()
    .onReceive(AXUtils.trustPublisher) { accessibilityEnable = $0 }
  }
}

#Preview {
  GeneralSettingView(state: .shared)
    .frame(width: 400)
}
