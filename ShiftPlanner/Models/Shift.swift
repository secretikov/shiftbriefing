import Foundation

struct Shift: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var durationHours: Double
    var hourlyRate: Double

    var expectedIncome: Double {
        durationHours * hourlyRate
    }
}
