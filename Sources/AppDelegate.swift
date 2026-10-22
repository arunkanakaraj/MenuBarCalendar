import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemManager: StatusItemManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Run purely as an accessory (menu bar only, no Dock icon)
        NSApp.setActivationPolicy(.accessory)

        // Initialize status bar manager
        statusItemManager = StatusItemManager()
    }

    func applicationWillTerminate(_ notification: Notification) {
        statusItemManager = nil
    }
}
