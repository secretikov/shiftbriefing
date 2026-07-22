import SwiftUI

struct ContentView: View {
    @AppStorage("isOnboardingComplete") var isOnboardingComplete: Bool = false
    @State private var gradientRotation: Double = 0.0

    var body: some View {
        if !isOnboardingComplete {
            OnboardingView()
        } else {
            ZStack {
                // Premium Moody Deep Dark-Blue Mesh Gradient Background
                ZStack {
                    Color(red: 0.03, green: 0.04, blue: 0.08).ignoresSafeArea() // Deepest space black

                    RadialGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 0.4, blue: 0.6).opacity(0.5), .clear]), center: .topLeading, startRadius: 100, endRadius: 600)
                        .ignoresSafeArea()
                        .hueRotation(.degrees(gradientRotation))

                    RadialGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.4), Color.blue.opacity(0.1), .clear]), center: .topTrailing, startRadius: 0, endRadius: 600)
                        .ignoresSafeArea()

                    RadialGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 0.8, blue: 0.4).opacity(0.2), .clear]), center: .center, startRadius: 50, endRadius: 400)
                        .ignoresSafeArea()
                        .hueRotation(.degrees(gradientRotation / 2))
                }
                .onAppear {
                    withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
                        gradientRotation = 45.0
                    }
                }

                TabView {
                    ShiftsView()
                        .tabItem {
                            Label("Смены", systemImage: "list.bullet.clipboard")
                        }

                    CalendarStatsView()
                        .tabItem {
                            Label("Календарь", systemImage: "calendar")
                        }

                    FinanceView()
                        .tabItem {
                            Label("Финансы", systemImage: "rublesign.circle")
                        }

                    SettingsView()
                        .tabItem {
                            Label("Профиль", systemImage: "person.circle")
                        }
                }
                .tint(.cyan)
            }
        }
    }
}
