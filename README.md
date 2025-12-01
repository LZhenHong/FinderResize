# FinderSnap

<p align="center">
  <img src="FinderResize/FinderResize/Resources/Assets.xcassets/AppIcon.appiconset/128x128.png" alt="FinderSnap Icon" width="128" height="128">
</p>

<p align="center">
  <strong>Automatically resize and position new Finder windows on macOS</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2014.0+-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" alt="Swift">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
</p>

## Features

- Automatically resize new Finder windows to your preferred size
- Position windows at screen center or custom coordinates
- Choose target screen (main display or current display)
- Apply settings only to the first window or all new windows
- Smooth window animations with easeOut effect
- Smart exclusions: Quick Look previews and DMG installer windows are not affected
- Lives in menu bar with minimal resource usage

## Requirements

- macOS 14.0 (Sonoma) or later
- Accessibility permission (prompted on first launch)

## Installation

### Build from Source

```bash
git clone https://github.com/LZhenHong/FinderResize.git
cd FinderResize
xcodebuild -project FinderResize/FinderResize.xcodeproj -scheme FinderResize -configuration Release build
```

The built app will be located in the `build/Release` directory.

## Usage

1. Launch FinderSnap
2. Grant Accessibility permission when prompted (required for window manipulation)
3. Click the menu bar icon to access settings
4. Configure your preferred window size and position
5. New Finder windows will automatically be resized and positioned

## Localization

- English
- 简体中文 (Simplified Chinese)
- 繁體中文 (Traditional Chinese)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [StorageMacro](https://github.com/LZhenHong/StorageMacro) - Swift macro for UserDefaults persistence
- [SettingsKit](https://github.com/LZhenHong/SettingsKit) - SwiftUI settings window framework
