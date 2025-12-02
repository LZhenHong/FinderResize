//
//  AppState.swift
//  FinderSnap
//
//  Created by Eden on 2024/5/6.
//

import Storage
import SwiftUI

@storage
class AppState: ObservableObject {
  enum WindowPlace: Int {
    case center, custom
  }

  enum WindowScreen: Int {
    case main, current
  }

  var resizeWindow = false
  var windowSize: CGSize = .init(width: 1200, height: 800)

  var placeWindow = false
  var place: WindowPlace = .center
  var position: CGPoint = .zero
  var effectFirstWindow = false

  var screen: WindowScreen = .main

  var disableAnimation = false
  var animationDuration: Double = 0.25

  static let shared = AppState()

  private init() {}
}
