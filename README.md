# 🗓️ MenuBarCalendar for macOS

A sleek, lightweight, and native macOS menu bar calendar app built with **Swift**, **AppKit**, and **SwiftUI**.

---

## ✨ Features

- **Menu Bar Presence**: Lives neatly in your macOS top menu bar without cluttering the Dock or Cmd+Tab switcher (`LSUIElement = true`).
- **Interactive Calendar View**:
  - Full monthly calendar grid with smooth navigation (`<` Previous, `>` Next, and `Today` quick jump).
  - Prominent highlight for the current day.
  - Interactive day selection with hover highlights.
  - Double-click any day to open Apple Calendar for that date.
- **Date Details & Live Clock**:
  - Displays selected day name and full date (e.g. *Wednesday, October 21, 2026*).
  - Relative time badge (*Today*, *Tomorrow*, *In 5 days*, *Yesterday*).
  - Day of year and week number (*Day 294 of 365 • Week 43*).
  - Live ticking digital clock (seconds precision).
- **Customizable Options**:
  - Toggle **Show Day Number in Menu Bar** (e.g., `[Calendar Icon] 21` vs just the icon).
  - Toggle **Show Weekday in Menu Bar** (e.g., `[Calendar Icon] Wed 21`).
  - Toggle **Start Week on Monday** (or Sunday).
  - Toggle **Launch at Login** (via macOS `SMAppService`).
- **Native Look & Feel**:
  - Uses Apple's modern frosted glass visual effect material (`.ultraThinMaterial`).
  - Dark mode and Light mode adaptive.
  - Automatically updates at midnight (`NSCalendarDayChanged`).
  - Press `ESC` or click outside to dismiss the popover.

---

## 🚀 Quick Start

### 1. Run Directly
The app is already compiled and running in your menu bar. To launch or re-launch it anytime:

```bash
open MenuBarCalendar.app
```

### 2. Install to Applications (Optional)
To copy the app into your `/Applications` folder so it appears in Spotlight and Launchpad:

```bash
./install.sh
```

or using `make`:

```bash
make install
```

---

## 🛠️ Building from Source

To recompile the app bundle:

```bash
./build.sh
```

The script compiles the Swift source files with optimization (`-O`), packages the `.app` bundle structure with `Info.plist` and high-resolution icons (`AppIcon.icns`), and signs the bundle with an ad-hoc signature.

---

## 📁 Project Structure

```
MenuBarCalendar/
├── Sources/
│   ├── main.swift                 # Application entry point
│   ├── AppDelegate.swift          # AppKit delegate & activation policy (.accessory)
│   ├── StatusItemManager.swift    # NSStatusItem, NSPopover & click handling
│   ├── CalendarViewModel.swift    # Calendar logic, grid layout, date formatting
│   ├── CalendarView.swift         # SwiftUI calendar interface & DayCellView
│   ├── SettingsModel.swift        # User preferences backed by UserDefaults
│   └── LaunchAtLogin.swift        # macOS 13+ ServiceManagement SMAppService
├── Resources/
│   ├── Info.plist                 # Bundle metadata with LSUIElement = true
│   └── AppIcon.icns               # High-resolution application icon
├── build.sh                       # One-step build and package script
├── install.sh                     # Install to /Applications
├── Makefile                       # Convenient make targets (build, run, install, clean)
└── README.md
```

---

## 💡 Keyboard Shortcuts & Gestures

- **Click Menu Bar Icon**: Toggle calendar popup.
- **Right-Click Menu Bar Icon**: Quick context menu (Preferences, Open Apple Calendar, Quit).
- **`ESC`**: Close calendar popup.
- **Double Click Any Day**: Opens macOS Calendar.app.
- **`Cmd + Q`**: Quit the application.
