//
//  WindowFixer.swift
//  FinderEnhancer
//
//  Created by Eden on 2024/5/6.
//

import Cocoa

extension String {
    static let finderBundleIdentifier = "com.apple.finder"
}

class WindowFixer {
    static let shared = WindowFixer()

    private var observer: AXObserver!
    private var finderApp: AXUIElement!
    private var finderWindowElements: [AXUIElement] = []

    func setUp() {
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
              app.bundleIdentifier == .finderBundleIdentifier
        else {
            return
        }
        addAXObserver(with: app)
    }

    private func setUpAXObserver() {
        let finderApps = NSRunningApplication.runningApplications(withBundleIdentifier: .finderBundleIdentifier)
        guard !finderApps.isEmpty,
              let finderApp = finderApps.first(where: { $0.bundleIdentifier == .finderBundleIdentifier })
        else {
            return
        }
        addAXObserver(with: finderApp)
    }

    private func addAXObserver(with finderApp: NSRunningApplication) {
        /// Remove observer if exsits
        removeObserver()

        let pid = finderApp.processIdentifier
        debugPrint("Finder applicaiton pid: \(pid)")
        self.finderApp = AXUIElementCreateApplication(pid)

        let createError = AXObserverCreate(pid, { _, _, _, refcon in
            guard let ref = refcon else { return }
            let this = Unmanaged<WindowFixer>.fromOpaque(ref).takeUnretainedValue()
            this.resizeNewFinderWindow()
        }, &observer)

        guard createError == .success, let observer else {
            return
        }

        let this = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let addError = AXObserverAddNotification(observer,
                                                 self.finderApp,
                                                 kAXWindowCreatedNotification as CFString,
                                                 this)
        guard addError == .success else {
            return
        }

        CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(observer), .defaultMode)
        finderWindowElements = fetchLatestFinderWindowInfos()
    }

    private func resizeNewFinderWindow() {
        let latestWindowElements = fetchLatestFinderWindowInfos()
        let newWindowElements = latestWindowElements.filter { !finderWindowElements.contains($0) }
        guard !newWindowElements.isEmpty else {
            return
        }

        for newWindowElement in newWindowElements {
            /// TODO: make size can be configured.
            var size = CGSize(width: 1200, height: 800)
            guard let sizeValue = AXValueCreate(.cgSize, &size) else {
                continue
            }
            AXUIElementSetAttributeValue(newWindowElement, NSAccessibility.Attribute.size.rawValue as CFString, sizeValue)
        }
        finderWindowElements = latestWindowElements
    }

    private func fetchLatestFinderWindowInfos() -> [AXUIElement] {
        var value: AnyObject?
        let error = AXUIElementCopyAttributeValue(finderApp,
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
        guard let observer, let finderApp else { return }

        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(observer), .defaultMode)
        AXObserverRemoveNotification(observer, finderApp, kAXWindowCreatedNotification as CFString)
        self.observer = nil
        self.finderApp = nil
        finderWindowElements = []
    }

    private init() {}

    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
}
