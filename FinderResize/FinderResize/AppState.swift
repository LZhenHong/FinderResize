//
//  AppState.swift
//  FinderEnhancer
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
    var windowSize: CGSize = .zero

    var placeWindow = false
    var place: WindowPlace = .center
    var position: CGPoint = .zero
    var effectFirstWindow = false

    var screen: WindowScreen = .main

    static let shared = AppState()

    private init() {}
}
