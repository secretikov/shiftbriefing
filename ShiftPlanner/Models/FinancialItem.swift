import Foundation

enum FinancialCategory: String, Codable, CaseIterable {
    case expense = "Траты"
    case debt = "Долги"
    case investment = "Вложения"
    case savings = "Накопления"
}

struct FinancialItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Double
    var category: FinancialCategory
    var priority: Int // 1 (High) to 3 (Low)
    var isCompleted: Bool = false
}
