import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var dataManager: DataManager
    @AppStorage("isOnboardingComplete") var isOnboardingComplete: Bool = false

    @State private var nameInput: String = ""
    @State private var rateInput: String = ""
    @State private var goalInput: String = ""

    @State private var step: Int = 1

    var body: some View {
        ZStack {
            Color(red: 0.03, green: 0.04, blue: 0.08).ignoresSafeArea()

            RadialGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.4), .clear]), center: .topLeading, startRadius: 100, endRadius: 600)
                .ignoresSafeArea()

            RadialGradient(gradient: Gradient(colors: [Color.purple.opacity(0.3), .clear]), center: .bottomTrailing, startRadius: 50, endRadius: 500)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Image(systemName: step == 1 ? "person.crop.circle.badge.plus" : (step == 2 ? "banknote" : "star.circle.fill"))
                    .font(.system(size: 80))
                    .foregroundColor(.cyan)
                    .modifier(NeonGlowModifier(color: .cyan, radius: 10))

                Text(step == 1 ? "Добро пожаловать!" : (step == 2 ? "Ставка за час" : "Финансовая цель"))
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(step == 1 ? "Как к вам обращаться?" : (step == 2 ? "Сколько вы получаете за час работы в среднем?" : "Какую сумму вы хотите заработать за месяц?"))
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                VStack {
                    if step == 1 {
                        TextField("Ваше имя", text: $nameInput)
                            .glassTextField()
                            .padding(.horizontal)
                    } else if step == 2 {
                        TextField("Например: 1000", text: $rateInput)
                            .keyboardType(.decimalPad)
                            .glassTextField()
                            .padding(.horizontal)
                    } else {
                        TextField("Например: 150000", text: $goalInput)
                            .keyboardType(.decimalPad)
                            .glassTextField()
                            .padding(.horizontal)
                    }
                }
                .liquidGlass(cornerRadius: 15, padding: 20)
                .padding(.horizontal, 20)

                Spacer()

                Button(action: nextStep) {
                    Text(step == 3 ? "Начать" : "Далее")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan)
                        .cornerRadius(15)
                        .modifier(NeonGlowModifier(color: .cyan, radius: 5))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .animation(.easeInOut, value: step)
    }

    private func nextStep() {
        if step == 1 {
            dataManager.userName = nameInput.isEmpty ? "Пользователь" : nameInput
            step = 2
        } else if step == 2 {
            if let rate = Double(rateInput), rate > 0 {
                dataManager.defaultHourlyRate = rate
            }
            step = 3
        } else if step == 3 {
            if let goal = Double(goalInput), goal > 0 {
                dataManager.monthlyGoal = goal
            }
            isOnboardingComplete = true
        }
    }
}
