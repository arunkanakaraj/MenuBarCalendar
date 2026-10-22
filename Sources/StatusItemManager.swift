import AppKit
import SwiftUI
import Combine

final class StatusItemManager: NSObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: Any?
    private var cancellables = Set<AnyCancellable>()
    private var dayTimer: Timer?

    override init() {
        super.init()
        setupStatusItem()
        setupPopover()
        setupEventMonitoring()
        updateStatusItemAppearance()

        // Listen for setting changes
        NotificationCenter.default.publisher(for: .settingsChanged)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateStatusItemAppearance()
                }
            }
            .store(in: &cancellables)

        // Listen for date changes at midnight
        NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateStatusItemAppearance()
                }
            }
            .store(in: &cancellables)

        // Periodic check every 60 seconds to ensure date is always in sync
        dayTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateStatusItemAppearance()
        }
    }

    deinit {
        dayTimer?.invalidate()
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 310, height: 390)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: CalendarView())
    }

    private func setupEventMonitoring() {
        // Close popover when Escape is pressed
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            if event.keyCode == 53 { // ESC key
                if self.popover.isShown {
                    self.closePopover()
                    return nil
                }
            }
            return event
        }
    }

    func updateStatusItemAppearance() {
        guard let button = statusItem.button else { return }

        let settings = SettingsModel.shared
        let now = Date()

        let image = NSImage(systemSymbolName: "calendar", accessibilityDescription: "Calendar")
        image?.isTemplate = true
        button.image = image

        if settings.showDateInMenuBar {
            button.imagePosition = .imageLeft
            if settings.showWeekdayInMenuBar {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE d"
                button.title = " \(formatter.string(from: now))"
            } else {
                let calendar = Calendar.current
                let dayOfMonth = calendar.component(.day, from: now)
                button.title = " \(dayOfMonth)"
            }
        } else {
            button.title = ""
            button.imagePosition = .imageOnly
        }
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        let currentEvent = NSApp.currentEvent

        // If right-clicked, show context menu
        if currentEvent?.type == .rightMouseUp {
            showContextMenu(sender)
            return
        }

        togglePopover(sender)
    }

    private func togglePopover(_ sender: NSStatusBarButton) {
        if popover.isShown {
            closePopover()
        } else {
            showPopover(sender)
        }
    }

    private func showPopover(_ sender: NSStatusBarButton) {
        // Re-anchor to the status item button
        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
        NSApp.activate(ignoringOtherApps: true)
    }

    private func closePopover() {
        popover.performClose(nil)
    }

    private func showContextMenu(_ sender: NSStatusBarButton) {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Open Apple Calendar", action: #selector(openAppleCalendar), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        let dateItem = NSMenuItem(title: "Show Day Number", action: #selector(toggleShowDate), keyEquivalent: "")
        dateItem.state = SettingsModel.shared.showDateInMenuBar ? .on : .off
        menu.addItem(dateItem)

        let weekdayItem = NSMenuItem(title: "Show Weekday", action: #selector(toggleShowWeekday), keyEquivalent: "")
        weekdayItem.state = SettingsModel.shared.showWeekdayInMenuBar ? .on : .off
        menu.addItem(weekdayItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit MenuBarCalendar", action: #selector(quitApp), keyEquivalent: "q"))

        for item in menu.items {
            item.target = self
        }

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil // Restore toggle behavior after click
    }

    @objc private func openAppleCalendar() {
        if let url = URL(string: "ical://"), NSWorkspace.shared.open(url) {
            return
        }
        let appURL = URL(fileURLWithPath: "/System/Applications/Calendar.app")
        NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
    }

    @objc private func toggleShowDate() {
        SettingsModel.shared.showDateInMenuBar.toggle()
        updateStatusItemAppearance()
    }

    @objc private func toggleShowWeekday() {
        SettingsModel.shared.showWeekdayInMenuBar.toggle()
        updateStatusItemAppearance()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
