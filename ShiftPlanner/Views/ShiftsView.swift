import SwiftUI
import Combine

struct LiveShiftTimerView: View {
    var shift: Shift
    @EnvironmentObject var dataManager: DataManager
    @State private var elapsedSeconds: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                    .modifier(NeonGlowModifier(color: .green))
                Text("Live Shift")
                    .font(.headline)
                    .foregroundColor(.green)
                Spacer()
                Text(timeString(from: elapsedSeconds))
                    .font(.system(.title3, design: .monospaced).bold())
                    .foregroundColor(.cyan)
            }

            HStack {
                Text("Earned:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("+\(String(format: "%.2f", earnedIncome)) ₽")
                    .font(.title2.bold())
                    .foregroundColor(.green)
                    .modifier(NeonGlowModifier(color: .green, radius: 5))
            }

            Button(action: {
                let durationHours = elapsedSeconds / 3600.0
                dataManager.stopLiveShift(id: shift.id, finalDuration: durationHours, actualIncome: earnedIncome)
            }) {
                Text("Завершить смену")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.6))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.red, lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: Color.green.opacity(0.1), radius: 15, x: 0, y: 0)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.green.opacity(0.5), lineWidth: 1)
        )
        .onReceive(timer) { _ in
            if let start = shift.startTime {
                elapsedSeconds = Date().timeIntervalSince(start)
            }
        }
        .onAppear {
            if let start = shift.startTime {
                elapsedSeconds = Date().timeIntervalSince(start)
            }
        }
    }

    var earnedIncome: Double {
        (elapsedSeconds / 3600.0) * shift.hourlyRate * shift.shiftType.multiplier
    }

    func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02ih %02im %02is", hours, minutes, seconds)
    }
}

struct ShiftsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddShift = false
    @State private var editingShiftId: UUID? = nil

    // States for New/Edit Shift Form
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
                            Text("\(String(format: "%.2f", dataManager.totalIncome)) ₽")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .liquidGlass()
                        .padding(.horizontal)

                        // Live Shift Card
                        if let liveShift = dataManager.shifts.first(where: { $0.isLive }) {
                            LiveShiftTimerView(shift: liveShift)
                                .padding(.horizontal)
                        }

                        // List of shifts
                        ForEach(Array(dataManager.shifts.filter { !$0.isArchived && !$0.isLive }.reversed())) { shift in
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
                                            Text("\(String(format: "%.1f", shift.durationHours)) ч")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("+\(String(format: "%.0f", shift.finalIncome)) ₽")
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
                            .contextMenu {
                                Button(action: {
                                    editingShiftId = shift.id
                                    newShiftDate = shift.date
                                    newShiftType = shift.shiftType
                                    isFixedIncome = shift.isFixedIncome
                                    fixedAmount = String(format: "%.0f", shift.fixedAmount)
                                    newShiftDuration = shift.durationHours
                                    showingAddShift = true
                                }) {
                                    Label("Редактировать", systemImage: "pencil")
                                }
                                Button(action: {
                                    dataManager.archiveShift(id: shift.id)
                                }) {
                                    Label("В архив", systemImage: "archivebox")
                                }
                                Button(role: .destructive, action: {
                                    dataManager.deleteShift(id: shift.id)
                                }) {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Смены")
            .toolbar {
                Button(action: {
                    editingShiftId = nil
                    newShiftDate = Date()
                    newShiftType = .standard
                    isFixedIncome = false
                    fixedAmount = ""
                    newShiftDuration = 8.0
                    showingAddShift = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.cyan.opacity(0.2))
                            .frame(width: 35, height: 35)
                            .modifier(NeonGlowModifier(color: .cyan, radius: 5))
                        Image(systemName: "plus")
                            .font(.title3.bold())
                            .foregroundColor(.cyan)
                    }
                }

                if !dataManager.shifts.contains(where: { $0.isLive }) {
                    Button(action: {
                        dataManager.startLiveShift()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 35, height: 35)
                                .modifier(NeonGlowModifier(color: .green, radius: 5))
                            Image(systemName: "play.fill")
                                .font(.title3.bold())
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            // Sheet for Adding Shift
            .sheet(isPresented: $showingAddShift) {
                NavigationView {
                    ZStack {
                        Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()
                        ScrollView {
                            VStack(spacing: 20) {
                                VStack(spacing: 15) {
                                    DatePicker("Дата", selection: $newShiftDate, displayedComponents: .date)
                                        .foregroundColor(.white)
                                    Picker("Тип смены", selection: $newShiftType) {
                                        ForEach(ShiftType.allCases, id: \.self) { type in
                                            Text(type.rawValue).tag(type)
                                        }
                                    }
                                    .tint(.cyan)
                                }
                                .liquidGlass()
                                .padding(.horizontal)

                                VStack(spacing: 15) {
                                    Toggle("Фиксированная сумма", isOn: $isFixedIncome)
                                        .foregroundColor(.white)
                                        .tint(.cyan)

                                    if isFixedIncome {
                                        TextField("Сумма за смену (₽)", text: $fixedAmount)
                                            .keyboardType(.decimalPad)
                                            .glassTextField()
                                    } else {
                                        Stepper("Длительность: \(String(format: "%.1f", newShiftDuration)) ч", value: $newShiftDuration, in: 1.0...24.0, step: 0.5)
                                            .foregroundColor(.white)
                                    }
                                }
                                .liquidGlass()
                                .padding(.horizontal)

                                Button(action: {
                                    if let id = editingShiftId {
                                        if let index = dataManager.shifts.firstIndex(where: { $0.id == id }) {
                                            var updated = dataManager.shifts[index]
                                            updated.date = newShiftDate
                                            updated.shiftType = newShiftType
                                            updated.isFixedIncome = isFixedIncome
                                            updated.fixedAmount = Double(fixedAmount) ?? 0
                                            updated.durationHours = newShiftDuration
                                            dataManager.updateShift(shift: updated)
                                        }
                                    } else {
                                        let shift = Shift(
                                            date: newShiftDate,
                                            shiftType: newShiftType,
                                            isFixedIncome: isFixedIncome,
                                            fixedAmount: Double(fixedAmount) ?? 0,
                                            durationHours: newShiftDuration,
                                            hourlyRate: dataManager.defaultHourlyRate,
                                            isCompleted: false,
                                            actualIncome: 0,
                                            isArchived: false
                                        )
                                        dataManager.addShift(shift: shift)
                                    }
                                    showingAddShift = false
                                }) {
                                    Text("Сохранить")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.cyan)
                                        .cornerRadius(15)
                                        .modifier(NeonGlowModifier(color: .cyan, radius: 5))
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)
                            }
                            .padding(.vertical)
                        }
                    }
                    .navigationTitle(editingShiftId == nil ? "Новая смена" : "Редактировать смену")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Закрыть") { showingAddShift = false }
                                .foregroundColor(.white)
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
