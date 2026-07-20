import SwiftUI

struct ShiftsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddShift = false
    @State private var newShiftDate = Date()
    @State private var newShiftDuration: Double = 8.0

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Summary card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Ожидаемый доход")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("\(dataManager.totalExpectedIncome, specifier: "%.2f") ₽")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .liquidGlass()
                        .padding(.horizontal)

                        // List of shifts
                        ForEach(dataManager.shifts) { shift in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(shift.date, style: .date)
                                        .font(.headline)
                                    Text("\(shift.durationHours, specifier: "%.1f") ч")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("+\(shift.expectedIncome, specifier: "%.0f") ₽")
                                    .font(.title3.bold())
                                    .foregroundColor(.green)
                            }
                            .liquidGlass()
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Планер смен")
            .toolbar {
                Button(action: { showingAddShift = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .sheet(isPresented: $showingAddShift) {
                NavigationView {
                    Form {
                        DatePicker("Дата", selection: $newShiftDate, displayedComponents: .date)
                        Stepper("Длительность: \(newShiftDuration, specifier: "%.1f") ч", value: $newShiftDuration, in: 1...24, step: 0.5)
                    }
                    .navigationTitle("Новая смена")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Отмена") { showingAddShift = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Сохранить") {
                                dataManager.addShift(date: newShiftDate, duration: newShiftDuration)
                                showingAddShift = false
                            }
                        }
                    }
                }
            }
        }
    }
}
