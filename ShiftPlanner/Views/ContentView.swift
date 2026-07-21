import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Moody deep dark-blue gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.05, green: 0.05, blue: 0.15), Color(red: 0.1, green: 0.1, blue: 0.25)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

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
