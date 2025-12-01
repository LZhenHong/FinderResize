# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FinderResize is a macOS menu bar application that automatically resizes and repositions new Finder windows. It uses the Accessibility API to monitor Finder window creation and apply user-configured size/position settings.

## Build Commands

Build and run using Xcode:
```bash
# Open in Xcode
open FinderResize/FinderResize.xcodeproj

# Build from command line
xcodebuild -project FinderResize/FinderResize.xcodeproj -scheme FinderResize -configuration Debug build

# Build for release
xcodebuild -project FinderResize/FinderResize.xcodeproj -scheme FinderResize -configuration Release build
```

## Architecture

### Core Components

- **main.swift** - Entry point; manually creates NSApplication and AppDelegate
- **AppDelegate.swift** - Initializes accessibility check, menu bar controller, and Finder window fixer
- **WindowFixer.swift** - Generic AXObserver-based window monitor that watches for new windows in any app by bundle ID
- **FinderWindowFixer.swift** - Finder-specific logic that resizes/repositions new windows using settings from AppState
- **AppState.swift** - Singleton holding all user preferences, uses `@storage` macro for persistence
- **MenuBarItemController.swift** - Menu bar status item and dropdown menu
- **AXUtils.swift** - Accessibility permission checking and status publishing via Combine

### Key Patterns

- Uses macOS Accessibility API (`AXUIElement`, `AXObserver`) to detect and modify Finder windows
- Settings persistence via [StorageMacro](https://github.com/LZhenHong/StorageMacro) Swift package (`@storage` macro wraps UserDefaults)
- Menu bar app (LSUIElement = YES) with no dock icon
- Settings window built with SwiftUI using [SettingsKit](https://github.com/LZhenHong/SettingsKit) (`SettingsPane` protocol, `SettingsWindowController`)

### Utils Directory

- **MenuBuilder.swift**, **MenuItemBuilder.swift** - DSL for building NSMenu with result builders
- **LaunchAtLogin.swift** - Launch at login functionality using SMAppService

## Requirements

- macOS 14.0+ (deployment target)
- Accessibility permission required (prompts user on first launch)
- Swift 5.0

## Localization

Supports English, Simplified Chinese (zh-Hans), and Traditional Chinese (zh-Hant). Uses String(localized:) for localized strings.
