import SwiftUI

struct CalendarStatsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedDate = Date()
    @State private var showingGenerator = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // Месячная цель (Прогресс-бар)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Цель на месяц")
                                    .font(.headline)
                                Spacer()
                                Text("\(String(format: "%.0f", dataManager.thisMonthIncome)) / \(String(format: "%.0f", dataManager.monthlyGoal)) ₽")
                                    .font(.subheadline.bold())
                                    .foregroundColor(dataManager.thisMonthIncome >= dataManager.monthlyGoal ? .green : .primary)
                            }

                            ProgressView(value: min(dataManager.thisMonthIncome / max(dataManager.monthlyGoal, 1), 1))
                                .tint(dataManager.thisMonthIncome >= dataManager.monthlyGoal ? .green : .blue)
                        }
                        .liquidGlass()
                        .padding(.horizontal)

                        // Статистика (плитки)
                        HStack(spacing: 15) {
                            StatBox(title: "За неделю", value: "\(String(format: "%.0f", dataManager.thisWeekIncome)) ₽", icon: "chart.bar.fill", color: .purple)
                            StatBox(title: "Средний доход", value: "\(String(format: "%.0f", dataManager.averageIncomePerShift)) ₽", icon: "sum", color: .orange)
                        }
                        .padding(.horizontal)

                        // Прогноз дохода
                        if dataManager.projectedIncomeForPlannedShifts > 0 {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.yellow)
                                    Text("Прогнозируемый доход (от запланированных)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Text("+\(String(format: "%.0f", dataManager.projectedIncomeForPlannedShifts)) ₽")
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .liquidGlass()
                            .padding(.horizontal)
                        }

                        // Календарь
                        VStack {
                            DatePicker(
                                "Календарь",
                                selection: $selectedDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .tint(.indigo)

                            // Подсказка, если в этот день есть смена
                            if let shift = dataManager.shifts.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                                Divider()
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Смена: \(shift.shiftType.rawValue)")
                                            .font(.headline)
                                        Text(shift.isCompleted ? "Завершена" : "Запланирована")
                                            .font(.caption)
                                            .foregroundColor(shift.isCompleted ? .green : .secondary)
                                    }
                                    Spacer()
                                    Text("\(String(format: "%.0f", shift.finalIncome)) ₽")
                                        .font(.title3.bold())
                                }
                                .padding(.top, 5)
                            } else {
                                Divider()
                                Text("Нет смен в этот день")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 5)
                            }
                        }
                        .liquidGlass()
                        .padding(.horizontal)

                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Статистика")
            .toolbar {
                Button(action: { showingGenerator = true }) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title2)
                }
            }
            .sheet(isPresented: $showingGenerator) {
                ScheduleGeneratorView()
            }
        }
    }
}

struct StatBox: View {
    var title: String
    var value: String
    var icon: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}
