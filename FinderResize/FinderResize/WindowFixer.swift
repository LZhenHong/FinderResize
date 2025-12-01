//
//  WindowFixer.swift
//  FinderResize
//
//  Created by Eden on 2024/5/9.
//

import Cocoa

typealias WindowChangeListener = ([AXUIElement], [AXUIElement], [AXUIElement]) -> Void

class WindowFixer {
  private var observer: AXObserver!
  private var app: AXUIElement!
  private var windowElements: [AXUIElement] = []

  let appBundleIdentifier: String
  let onWindowChanged: WindowChangeListener

  init(appBundleIdentifier: String, onNewWindow: @escaping WindowChangeListener) {
    self.appBundleIdentifier = appBundleIdentifier
    onWindowChanged = onNewWindow

    setUp()
  }

  private func setUp() {
    setUpListener()
    setUpAXObserver()
  }

  private func setUpListener() {
    NSWorkspace.shared.notificationCenter.addObserver(self,
                                                      selector: #selector(onApplicationWillLaunch(_:)),
                                                      name: NSWorkspace.willLaunchApplicationNotification,
                                                      object: nil)
  }

  @objc private func onApplicationWillLaunch(_ info: Notification) {
    guard let app = info.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
          app.bundleIdentifier == appBundleIdentifier
    else {
      return
    }
    addAXObserver(for: app)
  }

  private func setUpAXObserver() {
    let apps = NSRunningApplication.runningApplications(withBundleIdentifier: appBundleIdentifier)
    guard !apps.isEmpty,
          let app = apps.first(where: { $0.bundleIdentifier == appBundleIdentifier })
    else {
      return
    }
    addAXObserver(for: app)
  }

  private func addAXObserver(for app: NSRunningApplication) {
    /// Remove observer if exsits
    removeObserver()

    let pid = app.processIdentifier
    debugPrint("Finder application pid: \(pid)")
    self.app = AXUIElementCreateApplication(pid)

    let createError = AXObserverCreate(pid, { _, _, _, refcon in
      guard let ref = refcon else { return }
      let this = Unmanaged<WindowFixer>.fromOpaque(ref).takeUnretainedValue()
      this.handleNewWindows()
    }, &observer)

    guard createError == .success, let observer else { return }

    let this = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
    let addError = AXObserverAddNotification(observer,
                                             self.app,
                                             kAXWindowCreatedNotification as CFString,
                                             this)
    guard addError == .success else { return }

    CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(observer), .defaultMode)
    windowElements = fetchLatestWindowElements()
  }

  private func handleNewWindows() {
    let latestWindowElements = fetchLatestWindowElements()
    let newWindowElements = latestWindowElements.filter { !windowElements.contains($0) }
    guard !newWindowElements.isEmpty else { return }

    onWindowChanged(newWindowElements, latestWindowElements, windowElements)
    windowElements = latestWindowElements
  }

  private func fetchLatestWindowElements() -> [AXUIElement] {
    var value: AnyObject?
    let error = AXUIElementCopyAttributeValue(app,
                                              NSAccessibility.Attribute.windows.rawValue as CFString,
                                              &value)
    guard error == .success,
          let windows = value as? [AXUIElement]
    else {
      debugPrint("Cant find windows for finder: \(error)")
      return []
    }

    return windows
  }

  private func removeObserver() {
    guard let observer, let app else { return }

    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(observer), .defaultMode)
    AXObserverRemoveNotification(observer, app, kAXWindowCreatedNotification as CFString)
    self.observer = nil
    self.app = nil
    windowElements = []
  }

  deinit {
    NSWorkspace.shared.notificationCenter.removeObserver(self)
  }
}
