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

                        // Custom Header
                        HStack {
                            Text("Статистика")
                                .font(.custom("Inter-Regular", size: 20, relativeTo: .title3))
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: { showingGenerator = true }) {
                                Text("+ дни работы")
                                    .font(.custom("Inter-Regular", size: 16, relativeTo: .body))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // Статистика (плитки)
                        HStack(spacing: 15) {
                            StatBox(title: "За неделю", value: "\(String(format: "%.0f", dataManager.thisWeekIncome)) \(dataManager.currencySymbol)")
                            StatBox(title: "Средний доход", value: "\(String(format: "%.0f", dataManager.averageIncomePerShift)) \(dataManager.currencySymbol)")
                        }
                        .padding(.horizontal)

                        // Календарь Header
                        HStack {
                            Text(currentMonthYear())
                                .font(.custom("Inter-Regular", size: 24, relativeTo: .title2))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal)

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
            .navigationBarHidden(true)
            .sheet(isPresented: $showingGenerator) {
                ScheduleGeneratorView()
            }
        }
    }

    private func currentMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date()).capitalized
    }
}

struct StatBox: View {
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.custom("Inter-Regular", size: 16, relativeTo: .body))
                    .foregroundColor(.white)
                Text(value)
                    .font(.custom("Inter-Regular", size: 24, relativeTo: .title2))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .padding(24)
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
    @EnvironmentObject var dataManager: DataManager

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