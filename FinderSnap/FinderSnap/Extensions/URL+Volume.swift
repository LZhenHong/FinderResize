//
//  URL+Volume.swift
//  FinderSnap
//
//  Created by Eden on 2024/5/6.
//

import Foundation

// MARK: - Volume Detection

extension URL {
  /// Checks if this URL points to a read-only volume.
  var isReadOnlyVolume: Bool {
    do {
      let resourceValues = try resourceValues(forKeys: [.volumeIsReadOnlyKey])
      return resourceValues.volumeIsReadOnly ?? false
    } catch {
      return false
    }
  }

  /// Checks if this URL points to the startup disk.
  var isStartupDisk: Bool {
    guard isFileURL else { return false }

    let fileManager = FileManager.default
    do {
      let rootDevice = try fileManager.attributesOfFileSystem(forPath: "/")[.systemNumber] as? Int
      let volumeDevice = try fileManager.attributesOfFileSystem(forPath: path)[.systemNumber] as? Int
      return rootDevice == volumeDevice
    } catch {
      return false
    }
  }

  /// Checks if this URL points to a mounted disk image (DMG).
  /// A disk image is identified as a read-only volume under /Volumes/ that is not the startup disk.
  var isDiskImage: Bool {
    guard isFileURL,
          path.hasPrefix("/Volumes/"),
          !isStartupDisk
    else {
      return false
    }

    return isReadOnlyVolume
  }
}

// MARK: - Volume Path Construction

extension URL {
  /// Creates a URL pointing to a volume with the given name.
  /// - Parameter name: The volume name (e.g., "Install App")
  /// - Returns: URL pointing to /Volumes/{name}
  static func volume(named name: String) -> URL {
    URL(fileURLWithPath: "/Volumes/\(name)")
  }
}
