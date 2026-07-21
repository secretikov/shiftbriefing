import SwiftUI

enum ScheduleMode {
    case cyclic
    case weekdays
}

struct ScheduleGeneratorView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss

    @State private var mode: ScheduleMode = .cyclic
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!

    @State private var workDays = 2
    @State private var restDays = 2

    @State private var selectedWeekdays: Set<Int> = [2, 3, 4, 5, 6] // По умолчанию Пн-Пт

    @State private var shiftType: ShiftType = .standard
    @State private var isFixedIncome = false
    @State private var fixedAmount: String = ""
    @State private var duration: Double = 8.0

    let daysMap = [2: "Пн", 3: "Вт", 4: "Ср", 5: "Чт", 6: "Пт", 7: "Сб", 1: "Вс"]

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Picker("Режим", selection: $mode) {
                            Text("Циклично").tag(ScheduleMode.cyclic)
                            Text("По дням недели").tag(ScheduleMode.weekdays)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        VStack(spacing: 15) {
                            DatePicker("Начало", selection: $startDate, displayedComponents: .date)
                                .foregroundColor(.white)
                            DatePicker("Конец", selection: $endDate, displayedComponents: .date)
                                .foregroundColor(.white)
                        }
                        .liquidGlass()
                        .padding(.horizontal)

                        if mode == .cyclic {
                            VStack(spacing: 15) {
                                Stepper("Рабочих дней: \(workDays)", value: $workDays, in: 1...7)
                                    .foregroundColor(.white)
                                Stepper("Выходных дней: \(restDays)", value: $restDays, in: 1...7)
                                    .foregroundColor(.white)
                            }
                            .liquidGlass()
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 15) {
                                Text("Рабочие дни недели")
                                    .foregroundColor(.white)
                                HStack {
                                    ForEach([2, 3, 4, 5, 6, 7, 1], id: \.self) { day in
                                        let isSelected = selectedWeekdays.contains(day)
                                        Text(daysMap[day]!)
                                            .font(.caption.bold())
                                            .foregroundColor(isSelected ? .black : .white)
                                            .frame(width: 35, height: 35)
                                            .background(isSelected ? Color.cyan : Color.white.opacity(0.1))
                                            .clipShape(Circle())
                                            .onTapGesture {
                                                if isSelected {
                                                    selectedWeekdays.remove(day)
                                                } else {
                                                    selectedWeekdays.insert(day)
                                                }
                                            }
                                    }
                                }
                            }
                            .liquidGlass()
                            .padding(.horizontal)
                        }

                        VStack(spacing: 15) {
                            Picker("Тип смены", selection: $shiftType) {
                                ForEach(ShiftType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .tint(.cyan)

                            Toggle("Фиксированная сумма", isOn: $isFixedIncome)
                                .foregroundColor(.white)
                                .tint(.cyan)

                            if isFixedIncome {
                                TextField("Сумма за смену (₽)", text: $fixedAmount)
                                    .keyboardType(.decimalPad)
                                    .glassTextField()
                            } else {
                                Stepper("Длительность: \(String(format: "%.1f", duration)) ч", value: $duration, in: 1.0...24.0, step: 0.5)
                                    .foregroundColor(.white)
                            }
                        }
                        .liquidGlass()
                        .padding(.horizontal)

                        Button(action: {
                            if mode == .cyclic {
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
                            } else {
                                dataManager.generateScheduleByWeekdays(
                                    startDate: startDate,
                                    endDate: endDate,
                                    weekdays: selectedWeekdays,
                                    shiftType: shiftType,
                                    duration: duration,
                                    fixedAmount: Double(fixedAmount) ?? 0,
                                    isFixed: isFixedIncome
                                )
                            }
                            dismiss()
                        }) {
                            Text("Сгенерировать")
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
            .navigationTitle("Генерация")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}
