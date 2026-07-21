import SwiftUI

struct FinanceView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Balance Card
                        VStack(spacing: 15) {
                            HStack {
                                Text("Остаток средств")
                                    .font(.headline)
                                Spacer()
                                Text("\(String(format: "%.2f", dataManager.remainingBalance)) ₽")
                                    .font(.title2.bold())
                                    .foregroundColor(dataManager.remainingBalance >= 0 ? .primary : .red)
                            }

                            ProgressView(value: min(max(dataManager.totalAllocated / max(dataManager.totalIncome, 1), 0), 1))
                                .tint(dataManager.remainingBalance >= 0 ? .green : .red)
                        }
                        .liquidGlass()
                        .padding(.horizontal)

                        // Goals/Expenses List grouped by priority
                        ForEach(1...3, id: \.self) { priority in
                            let items = dataManager.financialItems.filter { $0.priority == priority }
                            if !items.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Приоритет \(priority)")
                                        .font(.headline)
                                        .padding(.horizontal)

                                    ForEach(items) { item in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(item.name)
                                                    .font(.subheadline.bold())
                                                Text(item.category.rawValue)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text("-\(String(format: "%.0f", item.amount)) ₽")
                                                .foregroundColor(item.category == .debt ? .red : .primary)

                                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(item.isCompleted ? .green : .gray)
                                        }
                                        .liquidGlass()
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Распределение")
        }
    }
}
