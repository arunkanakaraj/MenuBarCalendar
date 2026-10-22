import Foundation
import ServiceManagement

final class LaunchAtLogin: ObservableObject {
    static let shared = LaunchAtLogin()

    @Published var isEnabled: Bool = false

    private init() {
        checkStatus()
    }

    func checkStatus() {
        if #available(macOS 13.0, *) {
            isEnabled = (SMAppService.mainApp.status == .enabled)
        }
    }

    func toggle() {
        if #available(macOS 13.0, *) {
            do {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                    isEnabled = false
                } else {
                    try SMAppService.mainApp.register()
                    isEnabled = true
                }
            } catch {
                print("Failed to toggle Launch at Login: \(error)")
                checkStatus()
            }
        }
    }
}
