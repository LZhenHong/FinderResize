//
//  MenuBarItemController.swift
//  FinderEnhancer
//
//  Created by Eden on 2023/9/20.
//

import Cocoa
import Combine
import os.log

final class MenuBarItemController {
    static let shared = MenuBarItemController()

    private var subscriptions = Set<AnyCancellable>()
    private var statusItem: NSStatusItem!

    private lazy var settingWindowController: SettingWindowController = {
        let settings: [SettingContentRepresentable] = [
            GeneralSetting(),
            AboutSetting()
        ]
        return SettingWindowController(settings: settings)
    }()

    private init() {}

    func setUp() {
        statusItem = setUpStatusItem()
    }

    private func setUpStatusItem() -> NSStatusItem? {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let btn = statusItem.button else {
            return nil
        }

        statusItem.isVisible = true
        statusItem.behavior = .terminationOnRemoval

        btn.image = NSImage(systemSymbolName: "macwindow.on.rectangle", accessibilityDescription: "FinderEnhancer")
        btn.image?.size = NSSize(width: 18, height: 18)
        btn.image?.isTemplate = true

        btn.target = self
        btn.action = #selector(onStatusBarItemHandle(_:))
        btn.sendAction(on: [.leftMouseUp, .rightMouseUp])

        return statusItem
    }

    @objc private func onStatusBarItemHandle(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        switch event.type {
        case .leftMouseUp:
            showMenu(sender)
        case .rightMouseUp:
            break
        default:
            break
        }
    }

    private func showMenu(_ sender: NSStatusBarButton) {
        let menu = setUpMenu()
        showMenu(menu, for: statusItem)
    }

    private func showMenu(_ menu: NSMenu, for item: NSStatusItem) {
        item.menu = menu
        /// tricks
        item.button?.performClick(nil)
        item.menu = nil
    }

    private func setUpMenu() -> NSMenu {
        let menu = createMenu()
        // https://github.com/onmyway133/blog/issues/428
        menu.autoenablesItems = false
        return menu
    }

    private func createMenu() -> NSMenu {
        NSMenu {
            if !AXUtils.trusted {
                MenuItemBuilder()
                    .title(String(localized: "Open Accessibility Settings"))
                    .onSelect {
                        AXUtils.openAccessibilitySetting()
                    }
                NSMenuItem.separator()
            }
            MenuItemBuilder()
                .title(String(localized: "Launch at Login"))
                .onHighlight(LaunchAtLogin.enabledPulisher.eraseToAnyPublisher())
                .onSelect {
                    LaunchAtLogin.toggle()
                }
            MenuItemBuilder()
                .title(String(localized: "Settings"))
                .shortcuts(",")
                .onSelect {
                    self.settingWindowController.show()
                }
            NSMenuItem.separator()
            MenuItemBuilder()
                .title(String(localized: "Quit"))
                .onSelect {
                    NSApp.terminate(self)
                }
        }
    }

    private func changeMenuBarItemImage(with name: String) {
        guard let btn = statusItem?.button else { return }

        btn.image = NSImage(systemSymbolName: name, accessibilityDescription: "FinderEnhancer")
    }
}
