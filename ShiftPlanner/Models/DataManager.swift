import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var shifts: [Shift] = []
    @Published var financialItems: [FinancialItem] = []
    @Published var defaultHourlyRate: Double = 1000.0 // Примерная ставка

    var totalExpectedIncome: Double {
        shifts.reduce(0) { $0 + $1.expectedIncome }
    }

    var totalAllocated: Double {
        financialItems.filter { !$0.isCompleted }.reduce(0) { $0 + $1.amount }
    }

    var remainingBalance: Double {
        totalExpectedIncome - totalAllocated
    }

    init() {
        // Добавим тестовые данные для наглядности
        shifts = [
            Shift(date: Date(), durationHours: 8, hourlyRate: 1500),
            Shift(date: Date().addingTimeInterval(86400 * 2), durationHours: 12, hourlyRate: 1500)
        ]

        financialItems = [
            FinancialItem(name: "Квартплата", amount: 10000, category: .expense, priority: 1),
            FinancialItem(name: "Долг Ивану", amount: 5000, category: .debt, priority: 1),
            FinancialItem(name: "Акции", amount: 3000, category: .investment, priority: 2),
            FinancialItem(name: "Отпуск", amount: 8000, category: .savings, priority: 3)
        ]
    }

    func addShift(date: Date, duration: Double) {
        let newShift = Shift(date: date, durationHours: duration, hourlyRate: defaultHourlyRate)
        shifts.append(newShift)
        shifts.sort { $0.date < $1.date }
    }

    func addFinancialItem(name: String, amount: Double, category: FinancialCategory, priority: Int) {
        let newItem = FinancialItem(name: name, amount: amount, category: category, priority: priority)
        financialItems.append(newItem)
        financialItems.sort { $0.priority < $1.priority }
    }
}
