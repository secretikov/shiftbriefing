import SwiftUI

struct ScheduleGeneratorView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss

    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!

    @State private var workDays = 2
    @State private var restDays = 2

    @State private var shiftType: ShiftType = .standard
    @State private var isFixedIncome = false
    @State private var fixedAmount: String = ""
    @State private var duration: Double = 8.0

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Период")) {
                    DatePicker("Начало", selection: $startDate, displayedComponents: .date)
                    DatePicker("Конец", selection: $endDate, displayedComponents: .date)
                }

                Section(header: Text("График")) {
                    Stepper("Рабочих дней: \(workDays)", value: $workDays, in: 1...7)
                    Stepper("Выходных дней: \(restDays)", value: $restDays, in: 1...7)
                }

                Section(header: Text("Параметры смены")) {
                    Picker("Тип смены", selection: $shiftType) {
                        ForEach(ShiftType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    Toggle("Фиксированная сумма", isOn: $isFixedIncome)

                    if isFixedIncome {
                        TextField("Сумма за смену (₽)", text: $fixedAmount)
                            .keyboardType(.decimalPad)
                    } else {
                        Stepper("Длительность: \(String(format: "%.1f", duration)) ч", value: $duration, in: 1...24, step: 0.5)
                    }
                }
            }
            .navigationTitle("Генерация графика")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сгенерировать") {
                        dataManager.generateSchedule(
                            startDate: startDate,
                            endDate: endDate,
                            workDays: workDays,
                            restDays: restDays,
                            shiftType: shiftType,
                            duration: duration,
                            fixedAmount: Double(fixedAmount) ?? 0,
                            isFixed: isFixedIncome
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}
