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
                                Text("\(String(format: "%.0f", dataManager.thisMonthIncome)) / \(String(format: "%.0f", dataManager.monthlyGoal)) \(dataManager.currencySymbol)")
                                    .font(.subheadline.bold())
                                    .foregroundColor(dataManager.thisMonthIncome >= dataManager.monthlyGoal ? .green : .primary)
                            }

                            ProgressView(value: dataManager.monthlyGoalProgress)
                                .tint(dataManager.thisMonthIncome >= dataManager.monthlyGoal ? .green : .blue)
                        }
                        .liquidGlass()
                        .padding(.horizontal)

                        // Статистика (плитки)
                        HStack(spacing: 15) {
                            StatBox(title: "За неделю", value: "\(String(format: "%.0f", dataManager.thisWeekIncome)) \(dataManager.currencySymbol)", icon: "chart.bar.fill", color: .purple)
                            StatBox(title: "Средний доход", value: "\(String(format: "%.0f", dataManager.averageIncomePerShift)) \(dataManager.currencySymbol)", icon: "sum", color: .orange)
                        }
                        .padding(.horizontal)

                        // Индикатор выгорания
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(burnoutColor())
                                Text("Риск выгорания")
                                    .font(.headline)
                                Spacer()
                                Text("\(String(format: "%.0f", dataManager.burnoutRisk * 100))%")
                                    .font(.subheadline.bold())
                                    .foregroundColor(burnoutColor())
                            }

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 10)
                                        .cornerRadius(5)

                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.green, .yellow, .red]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * CGFloat(dataManager.burnoutRisk), height: 10)
                                        .cornerRadius(5)
                                        .modifier(NeonGlowModifier(color: burnoutColor(), radius: 3))
                                }
                            }
                            .frame(height: 10)
                        }
                        .liquidGlass()
                        .padding(.horizontal)

                        // Прогноз дохода
                        if dataManager.projectedIncomeForPlannedShifts > 0 {
                            FluidVesselView(
                                projectedIncome: dataManager.projectedIncomeForPlannedShifts,
                                currentIncome: dataManager.thisMonthIncome,
                                goal: dataManager.monthlyGoal
                            )
                            .padding(.horizontal)
                        }

                        // Календарь
                        CustomCalendarView(selectedDate: $selectedDate)
                            .padding(.horizontal)

                        // Детали выбранного дня
                        if let shift = dataManager.shifts.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) && !$0.isArchived }) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Смена: \(shift.shiftType.rawValue)")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text(shift.isCompleted ? "Завершена" : "Запланирована")
                                            .font(.caption)
                                            .foregroundColor(shift.isCompleted ? .green : .cyan)
                                    }
                                    Spacer()
                                    Text("\(String(format: "%.0f", shift.finalIncome)) \(dataManager.currencySymbol)")
                                        .font(.title2.bold())
                                        .foregroundColor(shift.isCompleted ? .green : .white)
                                }
                            }
                            .liquidGlass()
                            .padding(.horizontal)
                        } else {
                            VStack {
                                Text("Нет смен в этот день")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .liquidGlass()
                            .padding(.horizontal)
                        }

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

    private func burnoutColor() -> Color {
        let risk = dataManager.burnoutRisk
        if risk > 0.7 {
            return .red
        } else if risk > 0.4 {
            return .yellow
        } else {
            return .green
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


struct FluidVesselView: View {
    var projectedIncome: Double
    var currentIncome: Double
    var goal: Double

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .modifier(NeonGlowModifier(color: .yellow, radius: 5))
                Text("Прогноз от AI без ИИ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("+\(String(format: "%.0f", projectedIncome)) \(dataManager.currencySymbol)")
                    .font(.title3.bold())
                    .foregroundColor(.yellow)
                    .modifier(NeonGlowModifier(color: .yellow, radius: 5))
            }

            GeometryReader { geo in
                let totalIncome = currentIncome + projectedIncome
                let fillRatio = CGFloat(goal > 0 ? min(totalIncome / goal, 1.0) : 0)
                let currentRatio = CGFloat(goal > 0 ? min(currentIncome / goal, 1.0) : 0)

                ZStack(alignment: .bottom) {
                    // Background Vessel
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.3))
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.1), lineWidth: 1))

                    // Current Income Liquid
                    RoundedRectangle(cornerRadius: 15)
                        .fill(LinearGradient(colors: [.cyan.opacity(0.6), .blue.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                        .frame(width: geo.size.width * currentRatio, height: geo.size.height)
                        .clipped()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Projected Income Liquid
                    if fillRatio > currentRatio {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(LinearGradient(colors: [.yellow.opacity(0.8), .orange.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: geo.size.width * (fillRatio - currentRatio), height: geo.size.height)
                            .offset(x: geo.size.width * currentRatio)
                            .clipped()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .modifier(NeonGlowModifier(color: .yellow, radius: 4))
                    }

                    // Glass highlight
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(LinearGradient(colors: [.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                }
            }
            .frame(height: 30)
        }
        .liquidGlass()
    }
}