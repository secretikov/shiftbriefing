import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
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
