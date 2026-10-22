import Foundation
import Combine
import SwiftUI

struct CalendarDay: Identifiable, Hashable {
    let id: String
    let date: Date
    let dayNumber: Int
    let isCurrentMonth: Bool
    let isToday: Bool
}

final class CalendarViewModel: ObservableObject {
    @Published var displayMonth: Date
    @Published var selectedDate: Date
    @Published var today: Date
    @Published var currentTimeString: String = ""

    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?

    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = SettingsModel.shared.startWeekOnMonday ? 2 : 1
        return cal
    }

    init() {
        let now = Date()
        self.today = now
        self.selectedDate = now
        self.displayMonth = now

        updateClock()
        startTimer()

        // Listen for system date changes (e.g., at midnight)
        NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.handleDayChanged()
                }
            }
            .store(in: &cancellables)

        // Listen for setting changes (like first day of week)
        NotificationCenter.default.publisher(for: .settingsChanged)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        timer?.invalidate()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateClock()
        }
    }

    private func updateClock() {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        currentTimeString = formatter.string(from: Date())
    }

    func handleDayChanged() {
        let now = Date()
        self.today = now
        if calendar.isDate(selectedDate, inSameDayAs: today) {
            self.selectedDate = now
        }
        self.objectWillChange.send()
    }

    // MARK: - Navigation

    func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: displayMonth) {
            displayMonth = newDate
        }
    }

    func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: displayMonth) {
            displayMonth = newDate
        }
    }

    func goToToday() {
        let now = Date()
        displayMonth = now
        selectedDate = now
    }

    func selectDate(_ date: Date) {
        selectedDate = date
        // If clicking a day from previous/next month, update displayMonth to match
        if !calendar.isDate(date, equalTo: displayMonth, toGranularity: .month) {
            displayMonth = date
        }
    }

    var isDisplayingCurrentMonth: Bool {
        calendar.isDate(displayMonth, equalTo: today, toGranularity: .month)
    }

    // MARK: - Weekdays Header

    var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let firstWeekdayIndex = calendar.firstWeekday - 1
        return Array(symbols[firstWeekdayIndex..<symbols.count] + symbols[0..<firstWeekdayIndex])
    }

    // MARK: - Month Grid Calculation

    var daysInGrid: [CalendarDay] {
        var days: [CalendarDay] = []

        // Start of current displayed month
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        let startOfGrid = monthFirstWeek.start

        // Generate 42 days (6 weeks x 7 days) to ensure uniform height and no layout jumps
        for i in 0..<42 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfGrid) {
                let isCurrent = calendar.isDate(date, equalTo: displayMonth, toGranularity: .month)
                let isToday = calendar.isDate(date, inSameDayAs: today)
                let dayNumber = calendar.component(.day, from: date)

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let id = formatter.string(from: date)

                days.append(CalendarDay(
                    id: id,
                    date: date,
                    dayNumber: dayNumber,
                    isCurrentMonth: isCurrent,
                    isToday: isToday
                ))
            }
        }

        return days
    }

    // MARK: - Formatted Strings

    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayMonth)
    }

    var selectedDateFullString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: selectedDate)
    }

    var selectedDateRelativeString: String {
        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: today)
        let startOfSelected = cal.startOfDay(for: selectedDate)

        let components = cal.dateComponents([.day], from: startOfToday, to: startOfSelected)
        guard let dayDifference = components.day else { return "" }

        if dayDifference == 0 {
            return "Today"
        } else if dayDifference == 1 {
            return "Tomorrow"
        } else if dayDifference == -1 {
            return "Yesterday"
        } else if dayDifference > 1 {
            return "In \(dayDifference) days"
        } else {
            return "\(abs(dayDifference)) days ago"
        }
    }

    var selectedDateStats: String {
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: selectedDate) ?? 0
        let totalDaysInYear = calendar.range(of: .day, in: .year, for: selectedDate)?.count ?? 365
        let weekOfYear = calendar.component(.weekOfYear, from: selectedDate)

        return "Day \(dayOfYear) of \(totalDaysInYear) • Week \(weekOfYear)"
    }

    func isSelected(date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    func isWeekend(date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7 // 1 = Sunday, 7 = Saturday
    }
}
