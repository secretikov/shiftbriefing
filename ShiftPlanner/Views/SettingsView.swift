import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager

    @State private var nameInput: String = ""
    @State private var rateInput: String = ""
    @State private var goalInput: String = ""

    @State private var showSavedAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {

                        // Карточка профиля и ранга
                        VStack(spacing: 15) {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .font(.system(size: 60))
                                .foregroundColor(.cyan)
                                .modifier(NeonGlowModifier(color: .cyan, radius: 5))

                            Text(dataManager.userName.isEmpty ? "Пользователь" : dataManager.userName)
                                .font(.title2.bold())
                                .foregroundColor(.white)

                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.yellow)
                                Text("Текущий ранг:")
                                    .foregroundColor(.secondary)
                                Text(dataManager.userRank)
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                    .modifier(NeonGlowModifier(color: .yellow, radius: 3))
                            }

                            Text("Всего заработано: \(String(format: "%.0f", dataManager.totalIncome)) ₽")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .liquidGlass()
                        .padding(.horizontal)

                        // Настройки
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Настройки")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Имя")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Имя", text: $nameInput)
                                    .glassTextField()
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Стандартная ставка в час (₽)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Ставка", text: $rateInput)
                                    .keyboardType(.decimalPad)
                                    .glassTextField()
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Финансовая цель на месяц (₽)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Цель", text: $goalInput)
                                    .keyboardType(.decimalPad)
                                    .glassTextField()
                            }

                            Button(action: saveSettings) {
                                Text("Сохранить изменения")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(15)
                                    .modifier(NeonGlowModifier(color: .green, radius: 5))
                            }
                            .padding(.top, 10)
                        }
                        .liquidGlass()
                        .padding(.horizontal)

                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Профиль")
            .onAppear {
                nameInput = dataManager.userName
                rateInput = String(format: "%.0f", dataManager.defaultHourlyRate)
                goalInput = String(format: "%.0f", dataManager.monthlyGoal)
            }
            .alert("Сохранено", isPresented: $showSavedAlert) {
                Button("ОК", role: .cancel) { }
            } message: {
                Text("Ваши настройки успешно обновлены.")
            }
        }
    }

    private func saveSettings() {
        dataManager.userName = nameInput
        if let rate = Double(rateInput) {
            dataManager.defaultHourlyRate = rate
        }
        if let goal = Double(goalInput) {
            dataManager.monthlyGoal = goal
        }
        showSavedAlert = true
    }
}
