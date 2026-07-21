import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var shifts: [Shift] = []
    @Published var financialItems: [FinancialItem] = []

    @Published var defaultHourlyRate: Double = 1000.0 // Примерная ставка
    @Published var monthlyGoal: Double = 100_000.0 // Цель заработка на месяц

    var totalIncome: Double {
        shifts.reduce(0) { $0 + $1.finalIncome }
    }

    var totalAllocated: Double {
        financialItems.filter { !$0.isCompleted }.reduce(0) { $0 + $1.amount }
    }

    var remainingBalance: Double {
        totalIncome - totalAllocated
    }

    // Статистика
    var completedShiftsCount: Int {
        shifts.filter { $0.isCompleted }.count
    }

    var averageIncomePerShift: Double {
        let completed = shifts.filter { $0.isCompleted }
        guard !completed.isEmpty else { return 0 }
        let total = completed.reduce(0) { $0 + $1.actualIncome }
        return total / Double(completed.count)
    }

    // Статистика за текущую неделю
    var thisWeekIncome: Double {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Понедельник
        let now = Date()

        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!

        return shifts.filter { $0.date >= startOfWeek && $0.date < endOfWeek }.reduce(0) { $0 + $1.finalIncome }
    }

    // Статистика за текущий месяц
    var thisMonthIncome: Double {
        let calendar = Calendar.current
        let now = Date()

        let components = calendar.dateComponents([.year, .month], from: now)
        let startOfMonth = calendar.date(from: components)!
        let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!

        return shifts.filter { $0.date >= startOfMonth && $0.date < startOfNextMonth }.reduce(0) { $0 + $1.finalIncome }
    }

    init() {
        loadData()

        if shifts.isEmpty && financialItems.isEmpty {
            // Тестовые данные, если сохранений нет
            let pastDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
            shifts = [
                Shift(date: pastDate, isFixedIncome: false, durationHours: 8, hourlyRate: 1500, isCompleted: true, actualIncome: 12500),
                Shift(date: Date().addingTimeInterval(86400 * 1), shiftType: .night, isFixedIncome: true, fixedAmount: 5000, durationHours: 0, hourlyRate: 0),
                Shift(date: Date().addingTimeInterval(86400 * 3), durationHours: 12, hourlyRate: 1500)
            ]

            financialItems = [
                FinancialItem(name: "Квартплата", amount: 15000, category: .expense, priority: 1),
                FinancialItem(name: "Долг", amount: 5000, category: .debt, priority: 1),
                FinancialItem(name: "ETF", amount: 4000, category: .investment, priority: 2),
                FinancialItem(name: "Новый iPhone", amount: 20000, category: .savings, priority: 3)
            ]
            saveData()
        }
    }

    // Сохранение и загрузка
    private func saveData() {
        if let encodedShifts = try? JSONEncoder().encode(shifts) {
            UserDefaults.standard.set(encodedShifts, forKey: "saved_shifts")
        }
        if let encodedItems = try? JSONEncoder().encode(financialItems) {
            UserDefaults.standard.set(encodedItems, forKey: "saved_financial_items")
        }
    }

    private func loadData() {
        if let savedShiftsData = UserDefaults.standard.data(forKey: "saved_shifts"),
           let decodedShifts = try? JSONDecoder().decode([Shift].self, from: savedShiftsData) {
            shifts = decodedShifts
        }
        if let savedItemsData = UserDefaults.standard.data(forKey: "saved_financial_items"),
           let decodedItems = try? JSONDecoder().decode([FinancialItem].self, from: savedItemsData) {
            financialItems = decodedItems
        }
    }

    func addShift(shift: Shift) {
        shifts.append(shift)
        shifts.sort { $0.date < $1.date }
        saveData()
    }

    func markShiftCompleted(id: UUID, actualIncome: Double) {
        if let index = shifts.firstIndex(where: { $0.id == id }) {
            shifts[index].isCompleted = true
            shifts[index].actualIncome = actualIncome
            saveData()
        }
    }

    func addFinancialItem(name: String, amount: Double, category: FinancialCategory, priority: Int) {
        let newItem = FinancialItem(name: name, amount: amount, category: category, priority: priority)
        financialItems.append(newItem)
        financialItems.sort { $0.priority < $1.priority }
        saveData()
    }
}
