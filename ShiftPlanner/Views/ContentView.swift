import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Premium Moody Deep Dark-Blue Mesh Gradient Background
            ZStack {
                Color(red: 0.03, green: 0.04, blue: 0.08).ignoresSafeArea() // Deepest space black

                RadialGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 0.4, blue: 0.6).opacity(0.4), .clear]), center: .topLeading, startRadius: 100, endRadius: 600)
                    .ignoresSafeArea()

                RadialGradient(gradient: Gradient(colors: [Color(red: 0.4, green: 0.0, blue: 0.6).opacity(0.3), .clear]), center: .bottomTrailing, startRadius: 100, endRadius: 500)
                    .ignoresSafeArea()

                RadialGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 0.8, blue: 0.4).opacity(0.15), .clear]), center: .center, startRadius: 50, endRadius: 400)
                    .ignoresSafeArea()
            }

            TabView {
                ShiftsView()
                    .tabItem {
                        Label("Смены", systemImage: "list.bullet.clipboard")
                    }

                CalendarStatsView()
                    .tabItem {
                        Label("Статистика", systemImage: "calendar")
                    }

                FinanceView()
                    .tabItem {
                        Label("Финансы", systemImage: "rublesign.circle")
                    }
            }
            .tint(.indigo)
        }
    }
}
