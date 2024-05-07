//
//  AppState.swift
//  FinderEnhancer
//
//  Created by Eden on 2024/5/6.
//

import SwiftUI

class AppState: ObservableObject {
    @AppStorage("io.lzhlovesjyq.finderenhancer.resizewindow")
    var resizeWindow = false

    @AppStorage("io.lzhlovesjyq.finderenhancer.windowsize")
    var windowSize: CGSize = .zero

    static let shared = AppState()

    private init() {}
}
