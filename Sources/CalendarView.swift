import SwiftUI
import AppKit

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @ObservedObject private var settings = SettingsModel.shared
    @ObservedObject private var launchAtLogin = LaunchAtLogin.shared

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            // MARK: - Header
            HStack(alignment: .center) {
                Text(viewModel.monthYearString)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Spacer()

                HStack(spacing: 6) {
                    // Previous Month Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.previousMonth()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .semibold))
                            .frame(width: 24, height: 24)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(Color.primary.opacity(0.06))
                    .clipShape(Circle())
                    .help("Previous Month")

                    // "Today" Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.goToToday()
                        }
                    }) {
                        Text("Today")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .padding(.horizontal, 8)
                            .frame(height: 24)
                    }
                    .buttonStyle(.plain)
                    .background(viewModel.isDisplayingCurrentMonth ? Color.accentColor.opacity(0.15) : Color.primary.opacity(0.06))
                    .foregroundColor(viewModel.isDisplayingCurrentMonth ? .accentColor : .primary)
                    .clipShape(Capsule())
                    .help("Go to Today")

                    // Next Month Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.nextMonth()
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .frame(width: 24, height: 24)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(Color.primary.opacity(0.06))
                    .clipShape(Circle())
                    .help("Next Month")

                    // Options / Settings Menu
                    Menu {
                        Button(action: openAppleCalendar) {
                            Label("Open Apple Calendar", systemImage: "calendar")
                        }

                        Divider()

                        Toggle(isOn: $settings.showDateInMenuBar) {
                            Text("Show Day Number in Menu Bar")
                        }

                        Toggle(isOn: $settings.showWeekdayInMenuBar) {
                            Text("Show Weekday in Menu Bar")
                        }

                        Toggle(isOn: $settings.startWeekOnMonday) {
                            Text("Start Week on Monday")
                        }

                        Divider()

                        Button(action: {
                            launchAtLogin.toggle()
                        }) {
                            HStack {
                                Text("Launch at Login")
                                if launchAtLogin.isEnabled {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }

                        Divider()

                        Button(action: {
                            NSApplication.shared.terminate(nil)
                        }) {
                            Label("Quit Calendar", systemImage: "power")
                        }
                        .keyboardShortcut("q", modifiers: .command)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .frame(width: 24, height: 24)
                    }
                    .menuStyle(.borderlessButton)
                    .menuIndicator(.hidden)
                    .frame(width: 24, height: 24)
                    .help("Settings & Options")
                }
            }
            .padding(.horizontal, 4)

            // MARK: - Weekday Names
            HStack(spacing: 4) {
                ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.8))
                        .frame(maxWidth: .infinity)
                }
            }

            // MARK: - Month Grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.daysInGrid) { day in
                    DayCellView(
                        day: day,
                        isSelected: viewModel.isSelected(date: day.date),
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.12)) {
                                viewModel.selectDate(day.date)
                            }
                        },
                        onDoubleClick: {
                            viewModel.selectDate(day.date)
                            openAppleCalendar()
                        }
                    )
                }
            }

            Divider()
                .padding(.vertical, 2)

            // MARK: - Selected Date Info Card & Footer
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(viewModel.selectedDateRelativeString)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.12))
                            .clipShape(Capsule())

                        Text(viewModel.currentTimeString)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    Text(viewModel.selectedDateFullString)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(viewModel.selectedDateStats)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: openAppleCalendar) {
                    VStack(spacing: 3) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 14, weight: .medium))
                        Text("Calendar")
                            .font(.system(size: 9, weight: .medium))
                    }
                    .frame(width: 48, height: 42)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .help("Open Apple Calendar")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.primary.opacity(0.03))
            .cornerRadius(10)
        }
        .padding(14)
        .frame(width: 310)
        .background(.ultraThinMaterial)
    }

    private func openAppleCalendar() {
        if let url = URL(string: "ical://"), NSWorkspace.shared.open(url) {
            return
        }
        let appURL = URL(fileURLWithPath: "/System/Applications/Calendar.app")
        NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
    }
}

// MARK: - Day Cell View

struct DayCellView: View {
    let day: CalendarDay
    let isSelected: Bool
    let onTap: () -> Void
    let onDoubleClick: () -> Void

    @State private var isHovered: Bool = false

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background Highlight
                if day.isToday {
                    Circle()
                        .fill(Color.accentColor)
                } else if isSelected {
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 2)
                        .background(Circle().fill(Color.accentColor.opacity(0.15)))
                } else if isHovered {
                    Circle()
                        .fill(Color.primary.opacity(0.08))
                }

                // Day Number Text
                Text("\(day.dayNumber)")
                    .font(.system(size: 12, weight: day.isToday ? .bold : (day.isCurrentMonth ? .regular : .light), design: .rounded))
                    .foregroundColor(textColor)
            }
            .frame(width: 32, height: 32)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .simultaneousGesture(TapGesture(count: 2).onEnded {
            onDoubleClick()
        })
    }

    private var textColor: Color {
        if day.isToday {
            return .white
        } else if isSelected {
            return .accentColor
        } else if !day.isCurrentMonth {
            return .secondary.opacity(0.35)
        } else {
            return .primary
        }
    }
}
