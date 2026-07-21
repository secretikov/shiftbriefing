import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var shifts: [Shift] = []
    @Published var financialItems: [FinancialItem] = []

    @Published var defaultHourlyRate: Double = 1000.0 {
        didSet { UserDefaults.standard.set(defaultHourlyRate, forKey: "saved_hourlyRate") }
    }
    @Published var monthlyGoal: Double = 100_000.0 {
        didSet { UserDefaults.standard.set(monthlyGoal, forKey: "saved_monthlyGoal") }
    }
    @Published var userName: String = "" {
        didSet { UserDefaults.standard.set(userName, forKey: "saved_userName") }
    }

    var totalIncome: Double {
        shifts.filter { !$0.isArchived }.reduce(0) { $0 + $1.finalIncome }
    }

    var totalAllocated: Double {
        financialItems.filter { !$0.isCompleted }.reduce(0) { $0 + $1.amount }
    }

    var remainingBalance: Double {
        totalIncome - totalAllocated
    }

    // Статистика
    var completedShiftsCount: Int {
        shifts.filter { $0.isCompleted && !$0.isArchived }.count
    }

    var averageIncomePerShift: Double {
        let completed = shifts.filter { $0.isCompleted && !$0.isArchived }
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

        return shifts.filter { $0.date >= startOfWeek && $0.date < endOfWeek && !$0.isArchived }.reduce(0) { $0 + $1.finalIncome }
    }

    // Статистика за текущий месяц
    var thisMonthIncome: Double {
        let calendar = Calendar.current
        let now = Date()

        let components = calendar.dateComponents([.year, .month], from: now)
        let startOfMonth = calendar.date(from: components)!
        let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!

        return shifts.filter { $0.date >= startOfMonth && $0.date < startOfNextMonth && !$0.isArchived }.reduce(0) { $0 + $1.finalIncome }
    }

    init() {
        self.defaultHourlyRate = UserDefaults.standard.double(forKey: "saved_hourlyRate") == 0 ? 1000.0 : UserDefaults.standard.double(forKey: "saved_hourlyRate")
        self.monthlyGoal = UserDefaults.standard.double(forKey: "saved_monthlyGoal") == 0 ? 100000.0 : UserDefaults.standard.double(forKey: "saved_monthlyGoal")
        self.userName = UserDefaults.standard.string(forKey: "saved_userName") ?? ""
        loadData()
    }

    // Геймификация
    var userRank: String {
        let earned = totalIncome
        if earned >= 1_000_000 {
            return "Олигарх"
        } else if earned >= 500_000 {
            return "Босс"
        } else if earned >= 100_000 {
            return "Профи"
        } else if earned >= 50_000 {
            return "Трудяга"
        } else {
            return "Новичок"
        }
    }

    // Логика прогнозирования
    var projectedIncomeForPlannedShifts: Double {
        shifts.filter { !$0.isCompleted && !$0.isArchived && !$0.isLive }.reduce(0) { $0 + $1.expectedIncome }
    }

    var monthlyGoalProgress: Double {
        let safeGoal = max(monthlyGoal, 1.0)
        let progress = thisMonthIncome / safeGoal
        return min(max(progress, 0.0), 1.0)
    }

    var financeAllocationProgress: Double {
        let safeAllocated = max(totalAllocated, 1.0)
        let progress = totalIncome / safeAllocated
        return min(max(progress, 0.0), 1.0)
    }

    var burnoutRisk: Double {
        // Простой расчет риска выгорания на основе часов за последние 7 дней (макс 60 часов)
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!

        let recentHours = shifts.filter { $0.date >= weekAgo && $0.date <= now && !$0.isArchived && !$0.isFixedIncome }.reduce(0) { $0 + $1.durationHours }
        return min(max(recentHours / 60.0, 0), 1.0)
    }

    // Live режим
    func startLiveShift() {
        let liveShift = Shift(
            date: Date(),
            durationHours: 0,
            hourlyRate: defaultHourlyRate,
            isLive: true,
            startTime: Date()
        )
        shifts.append(liveShift)
        shifts.sort { $0.date < $1.date }
        saveData()
    }

    func stopLiveShift(id: UUID, finalDuration: Double, actualIncome: Double) {
        if let index = shifts.firstIndex(where: { $0.id == id }) {
            shifts[index].isLive = false
            shifts[index].durationHours = finalDuration
            shifts[index].isCompleted = true
            shifts[index].actualIncome = actualIncome
            saveData()
        }
    }

    var shiftsNeededForGoals: Int {
        let remainingGoalsAmount = max(0, totalAllocated - totalIncome)
        let avgIncome = averageIncomePerShift > 0 ? averageIncomePerShift : (defaultHourlyRate * 8) // если нет завершенных смен, берем 8 часов по дефолту
        return Int(ceil(remainingGoalsAmount / avgIncome))
    }

    // Генератор графика (Цикличный)
    func generateSchedule(startDate: Date, endDate: Date, workDays: Int, restDays: Int, shiftType: ShiftType, duration: Double, fixedAmount: Double, isFixed: Bool) {
        var currentDate = startDate
        var cycleCounter = 0
        let calendar = Calendar.current

        while currentDate <= endDate {
            if cycleCounter < workDays {
                // Добавляем рабочий день
                let newShift = Shift(
                    date: currentDate,
                    shiftType: shiftType,
                    isFixedIncome: isFixed,
                    fixedAmount: fixedAmount,
                    durationHours: duration,
                    hourlyRate: defaultHourlyRate,
                    isCompleted: false,
                    actualIncome: 0,
                    isArchived: false
                )
                shifts.append(newShift)
            }

            cycleCounter += 1
            if cycleCounter >= (workDays + restDays) {
                cycleCounter = 0
            }

            // Переходим к следующему дню
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        shifts.sort { $0.date < $1.date }
        saveData()
    }

    // Генератор графика (По дням недели)
    // weekdays: массив чисел от 1 до 7 (где 1 - Воскресенье, 2 - Понедельник, ..., 7 - Суббота)
    func generateScheduleByWeekdays(startDate: Date, endDate: Date, weekdays: Set<Int>, shiftType: ShiftType, duration: Double, fixedAmount: Double, isFixed: Bool) {
        var currentDate = startDate
        let calendar = Calendar.current

        while currentDate <= endDate {
            let weekday = calendar.component(.weekday, from: currentDate)

            if weekdays.contains(weekday) {
                let newShift = Shift(
                    date: currentDate,
                    shiftType: shiftType,
                    isFixedIncome: isFixed,
                    fixedAmount: fixedAmount,
                    durationHours: duration,
                    hourlyRate: defaultHourlyRate,
                    isCompleted: false,
                    actualIncome: 0,
                    isArchived: false
                )
                shifts.append(newShift)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        shifts.sort { $0.date < $1.date }
        saveData()
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

    func updateShift(shift: Shift) {
        if let index = shifts.firstIndex(where: { $0.id == shift.id }) {
            shifts[index] = shift
            shifts.sort { $0.date < $1.date }
            saveData()
        }
    }

    func deleteShift(id: UUID) {
        shifts.removeAll { $0.id == id }
        saveData()
    }

    func archiveShift(id: UUID) {
        if let index = shifts.firstIndex(where: { $0.id == id }) {
            shifts[index].isArchived = true
            saveData()
        }
    }

    func markShiftCompleted(id: UUID, actualIncome: Double) {
        if let index = shifts.firstIndex(where: { $0.id == id }) {
            shifts[index].isCompleted = true
            shifts[index].actualIncome = actualIncome
            saveData()
        }
    }

    // CRUD FinancialItems

    func addFinancialItem(name: String, amount: Double, category: FinancialCategory, priority: Int) {
        let newItem = FinancialItem(name: name, amount: amount, category: category, priority: priority)
        financialItems.append(newItem)
        financialItems.sort { $0.priority < $1.priority }
        saveData()
    }

    func updateFinancialItem(item: FinancialItem) {
        if let index = financialItems.firstIndex(where: { $0.id == item.id }) {
            financialItems[index] = item
            financialItems.sort { $0.priority < $1.priority }
            saveData()
        }
    }

    func deleteFinancialItem(id: UUID) {
        financialItems.removeAll { $0.id == id }
        saveData()
    }
}
