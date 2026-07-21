import SwiftUI

struct ShiftsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddShift = false

    // States for New Shift Form
    @State private var newShiftDate = Date()
    @State private var newShiftType: ShiftType = .standard
    @State private var isFixedIncome = false
    @State private var fixedAmount: String = ""
    @State private var newShiftDuration: Double = 8.0

    // States for Completing Shift
    @State private var showingCompleteShift = false
    @State private var selectedShiftId: UUID? = nil
    @State private var actualIncomeInput: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Summary card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Общий доход")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("\(dataManager.totalIncome, specifier: "%.2f") ₽")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .liquidGlass()
                        .padding(.horizontal)

                        // List of shifts
                        ForEach(dataManager.shifts) { shift in
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(shift.date, style: .date)
                                        .font(.headline)

                                    HStack {
                                        Text(shift.shiftType.rawValue)
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.indigo.opacity(0.2))
                                            .cornerRadius(5)

                                        if !shift.isFixedIncome {
                                            Text("\(shift.durationHours, specifier: "%.1f") ч")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("+\(shift.finalIncome, specifier: "%.0f") ₽")
                                        .font(.title3.bold())
                                        .foregroundColor(shift.isCompleted ? .green : .primary)

                                    if !shift.isCompleted {
                                        Button(action: {
                                            selectedShiftId = shift.id
                                            actualIncomeInput = String(format: "%.0f", shift.expectedIncome)
                                            showingCompleteShift = true
                                        }) {
                                            Text("Завершить")
                                                .font(.caption.bold())
                                                .padding(6)
                                                .background(Color.green.opacity(0.2))
                                                .foregroundColor(.green)
                                                .cornerRadius(8)
                                        }
                                    } else {
                                        Text("✓ Выплачено")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .liquidGlass()
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Смены")
            .toolbar {
                Button(action: { showingAddShift = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            // Sheet for Adding Shift
            .sheet(isPresented: $showingAddShift) {
                NavigationView {
                    Form {
                        DatePicker("Дата", selection: $newShiftDate, displayedComponents: .date)
                        Picker("Тип смены", selection: $newShiftType) {
                            ForEach(ShiftType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }

                        Toggle("Фиксированная сумма", isOn: $isFixedIncome)

                        if isFixedIncome {
                            TextField("Сумма за смену (₽)", text: $fixedAmount)
                                .keyboardType(.decimalPad)
                        } else {
                            Stepper("Длительность: \(newShiftDuration, specifier: "%.1f") ч", value: $newShiftDuration, in: 1...24, step: 0.5)
                        }
                    }
                    .navigationTitle("Новая смена")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Отмена") { showingAddShift = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Сохранить") {
                                let shift = Shift(
                                    date: newShiftDate,
                                    shiftType: newShiftType,
                                    isFixedIncome: isFixedIncome,
                                    fixedAmount: Double(fixedAmount) ?? 0,
                                    durationHours: newShiftDuration,
                                    hourlyRate: dataManager.defaultHourlyRate,
                                    isCompleted: false,
                                    actualIncome: 0
                                )
                                dataManager.addShift(shift: shift)
                                showingAddShift = false
                            }
                        }
                    }
                }
            }
            // Alert for Completing Shift
            .alert("Фактический доход", isPresented: $showingCompleteShift) {
                TextField("Сумма", text: $actualIncomeInput)
                    .keyboardType(.decimalPad)
                Button("Отмена", role: .cancel) { }
                Button("Сохранить") {
                    if let id = selectedShiftId, let actual = Double(actualIncomeInput) {
                        dataManager.markShiftCompleted(id: id, actualIncome: actual)
                    }
                }
            } message: {
                Text("Введите сколько вы реально получили за эту смену.")
            }
        }
    }
}
