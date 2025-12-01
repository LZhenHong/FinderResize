//
//  CGRect+Accessibility.swift
//  FinderResize
//
//  Created by Eden on 2024/5/6.
//

import Foundation

// MARK: - Coordinate Conversion

extension CGRect {
  /// Converts this rect from NSScreen coordinates to Accessibility API coordinates.
  ///
  /// NSScreen uses bottom-left origin, while Accessibility API uses top-left origin.
  /// This conversion is necessary when working with AXUIElement position attributes.
  ///
  /// - Parameter mainScreenFrame: The frame of the main screen (used as reference for Y-axis conversion)
  /// - Returns: A new rect with coordinates suitable for Accessibility API
  func toAccessibilityCoordinates(relativeTo mainScreenFrame: CGRect) -> CGRect {
    let y = mainScreenFrame.maxY - maxY
    return CGRect(x: minX, y: y, width: width, height: height)
  }
}

// MARK: - Position Calculation

extension CGRect {
  /// Calculates the origin point to center a window of the given size within this rect.
  /// - Parameter size: The size of the window to center
  /// - Returns: The origin point for centering the window
  func centerPoint(for size: CGSize) -> CGPoint {
    CGPoint(
      x: midX - size.width * 0.5,
      y: midY - size.height * 0.5
    )
  }

  /// Calculates the origin point for placing a window at a custom offset within this rect.
  /// - Parameter offset: The offset from the rect's origin
  /// - Returns: The origin point with the offset applied
  func originPoint(withOffset offset: CGPoint) -> CGPoint {
    CGPoint(
      x: minX + offset.x,
      y: minY + offset.y
    )
  }
}
