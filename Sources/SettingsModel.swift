import Foundation
import Combine

final class SettingsModel: ObservableObject {
    static let shared = SettingsModel()

    private enum Keys {
        static let showDateInMenuBar = "showDateInMenuBar"
        static let showWeekdayInMenuBar = "showWeekdayInMenuBar"
        static let startWeekOnMonday = "startWeekOnMonday"
        static let showWeekNumbers = "showWeekNumbers"
    }

    @Published var showDateInMenuBar: Bool {
        didSet {
            UserDefaults.standard.set(showDateInMenuBar, forKey: Keys.showDateInMenuBar)
            NotificationCenter.default.post(name: .settingsChanged, object: nil)
        }
    }

    @Published var showWeekdayInMenuBar: Bool {
        didSet {
            UserDefaults.standard.set(showWeekdayInMenuBar, forKey: Keys.showWeekdayInMenuBar)
            NotificationCenter.default.post(name: .settingsChanged, object: nil)
        }
    }

    @Published var startWeekOnMonday: Bool {
        didSet {
            UserDefaults.standard.set(startWeekOnMonday, forKey: Keys.startWeekOnMonday)
            NotificationCenter.default.post(name: .settingsChanged, object: nil)
        }
    }

    @Published var showWeekNumbers: Bool {
        didSet {
            UserDefaults.standard.set(showWeekNumbers, forKey: Keys.showWeekNumbers)
            NotificationCenter.default.post(name: .settingsChanged, object: nil)
        }
    }

    init() {
        let defaults = UserDefaults.standard
        
        // Defaults: Show day number in menu bar = false (icon only by default)
        if defaults.object(forKey: Keys.showDateInMenuBar) == nil {
            self.showDateInMenuBar = false
        } else {
            self.showDateInMenuBar = defaults.bool(forKey: Keys.showDateInMenuBar)
        }

        // Show weekday in menu bar = false
        if defaults.object(forKey: Keys.showWeekdayInMenuBar) == nil {
            self.showWeekdayInMenuBar = false
        } else {
            self.showWeekdayInMenuBar = defaults.bool(forKey: Keys.showWeekdayInMenuBar)
        }

        // Start week on Monday = follows current locale by default
        if defaults.object(forKey: Keys.startWeekOnMonday) == nil {
            self.startWeekOnMonday = Calendar.current.firstWeekday == 2
        } else {
            self.startWeekOnMonday = defaults.bool(forKey: Keys.startWeekOnMonday)
        }

        // Show week numbers = false by default
        if defaults.object(forKey: Keys.showWeekNumbers) == nil {
            self.showWeekNumbers = false
        } else {
            self.showWeekNumbers = defaults.bool(forKey: Keys.showWeekNumbers)
        }
    }
}

extension Notification.Name {
    static let settingsChanged = Notification.Name("MenuBarCalendar.settingsChanged")
    static let openCalendarApp = Notification.Name("MenuBarCalendar.openCalendarApp")
}
