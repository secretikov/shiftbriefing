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
                            DynamicAvatarView(rank: dataManager.userRank)
                                .padding(.top, 10)
                                .padding(.bottom, 5)

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


struct DynamicAvatarView: View {
    var rank: String
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background glow based on rank
            Circle()
                .fill(glowColor().opacity(0.3))
                .frame(width: avatarSize() + 20, height: avatarSize() + 20)
                .modifier(NeonGlowModifier(color: glowColor(), radius: glowRadius()))
                .scaleEffect(isAnimating ? 1.05 : 0.95)

            // Inner complex shapes for higher ranks
            if rank != "Новичок" && rank != "Работяга" {
                Circle()
                    .stroke(LinearGradient(colors: [glowColor(), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                    .frame(width: avatarSize() + 10, height: avatarSize() + 10)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            }

            if rank == "Магнат" || rank == "Властелин смен" {
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .frame(width: avatarSize() + 30, height: avatarSize() + 30)
                    .foregroundColor(glowColor())
                    .rotationEffect(Angle(degrees: isAnimating ? -360 : 0))
            }

            // Core Avatar
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.6))
                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))

                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: avatarSize() * 0.5, weight: .light))
                    .foregroundColor(glowColor())
            }
            .frame(width: avatarSize(), height: avatarSize())
        }
        .onAppear {
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }

    private func avatarSize() -> CGFloat {
        return 100
    }

    private func glowColor() -> Color {
        switch rank {
        case "Новичок": return .cyan
        case "Работяга": return .blue
        case "Опытный": return .purple
        case "Мастер": return .orange
        case "Магнат": return .yellow
        case "Властелин смен": return .red
        default: return .cyan
        }
    }

    private func glowRadius() -> CGFloat {
        switch rank {
        case "Новичок", "Работяга": return 10
        case "Опытный", "Мастер": return 15
        case "Магнат", "Властелин смен": return 25
        default: return 10
        }
    }
}
