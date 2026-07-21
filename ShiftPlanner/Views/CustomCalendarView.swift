import SwiftUI

struct CustomCalendarView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var selectedDate: Date

    @State private var currentMonth: Date = Date()

    let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

    var body: some View {
        VStack(spacing: 15) {
            // Calendar Header
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }

                Spacer()

                Text(monthYearString(from: currentMonth))
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Spacer()

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)

            // Days of week
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Dates grid
            let daysInMonth = extractDays(for: currentMonth)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(daysInMonth, id: \.self) { dateValue in
                    if let date = dateValue {
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        let hasShift = dataManager.shifts.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: date) && !$0.isArchived })

                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                            .foregroundColor(isSelected ? .black : (hasShift ? .cyan : .white))
                            .frame(width: 35, height: 35)
                            .background(
                                ZStack {
                                    if isSelected {
                                        Circle().fill(Color.white)
                                    } else if hasShift {
                                        Circle()
                                            .fill(Color.cyan.opacity(0.15))
                                            .overlay(Circle().stroke(Color.cyan.opacity(0.5), lineWidth: 1))
                                            .modifier(NeonGlowModifier(color: .cyan, radius: 4))
                                    }
                                }
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
                    } else {
                        Text("")
                            .frame(width: 35, height: 35)
                    }
                }
            }
        }
        .liquidGlass()
    }

    // Helpers
    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }

    private func extractDays(for month: Date) -> [Date?] {
        var days = [Date?]()
        let calendar = Calendar.current

        let components = calendar.dateComponents([.year, .month], from: month)
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return days
        }

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        // Adjust for Monday start (1=Mon, ..., 7=Sun) in standard swift 1=Sun, 2=Mon
        var emptyDays = firstWeekday - 2
        if emptyDays < 0 { emptyDays = 6 }

        for _ in 0..<emptyDays {
            days.append(nil)
        }

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }

        return days
    }
}
