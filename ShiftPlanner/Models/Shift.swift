import Foundation

enum ShiftType: String, Codable, CaseIterable {
    case standard = "Стандарт"
    case night = "Ночь"
    case holiday = "Праздник"

    var multiplier: Double {
        switch self {
        case .standard: return 1.0
        case .night: return 1.5
        case .holiday: return 2.0
        }
    }
}

struct Shift: Identifiable, Codable {
    var id = UUID()
    var date: Date

    // Новые поля
    var shiftType: ShiftType = .standard
    var isFixedIncome: Bool = false
    var fixedAmount: Double = 0.0

    // Поля для почасовой оплаты (если isFixedIncome == false)
    var durationHours: Double
    var hourlyRate: Double

    // Фактический заработок
    var isCompleted: Bool = false
    var actualIncome: Double = 0.0

    var expectedIncome: Double {
        if isFixedIncome {
            return fixedAmount * shiftType.multiplier
        } else {
            return durationHours * hourlyRate * shiftType.multiplier
        }
    }

    var finalIncome: Double {
        return isCompleted ? actualIncome : expectedIncome
    }
}
