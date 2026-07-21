import SwiftUI

struct FinanceView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddFinance = false

    // States for Adding/Editing Financial Item
    @State private var editingItemId: UUID? = nil
    @State private var itemName: String = ""
    @State private var itemAmount: String = ""
    @State private var itemCategory: FinancialCategory = .expense
    @State private var itemPriority: Int = 1

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

                            ProgressView(value: dataManager.financeAllocationProgress)
                                .tint(dataManager.remainingBalance >= 0 ? .green : .red)

                            if dataManager.remainingBalance < 0 {
                                HStack {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.orange)
                                    Text("Осталось отработать смен: \(dataManager.shiftsNeededForGoals)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
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

                                            Button(action: {
                                                var updated = item
                                                updated.isCompleted.toggle()
                                                dataManager.updateFinancialItem(item: updated)
                                            }) {
                                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(item.isCompleted ? .green : .gray)
                                            }
                                        }
                                        .liquidGlass()
                                        .padding(.horizontal)
                                        .contextMenu {
                                            Button(action: {
                                                editingItemId = item.id
                                                itemName = item.name
                                                itemAmount = String(format: "%.0f", item.amount)
                                                itemCategory = item.category
                                                itemPriority = item.priority
                                                showingAddFinance = true
                                            }) {
                                                Label("Редактировать", systemImage: "pencil")
                                            }
                                            Button(role: .destructive, action: {
                                                dataManager.deleteFinancialItem(id: item.id)
                                            }) {
                                                Label("Удалить", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Распределение")
            .toolbar {
                Button(action: {
                    editingItemId = nil
                    itemName = ""
                    itemAmount = ""
                    itemCategory = .expense
                    itemPriority = 1
                    showingAddFinance = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .sheet(isPresented: $showingAddFinance) {
                NavigationView {
                    Form {
                        TextField("Название", text: $itemName)
                        TextField("Сумма (₽)", text: $itemAmount)
                            .keyboardType(.decimalPad)

                        Picker("Категория", selection: $itemCategory) {
                            ForEach(FinancialCategory.allCases, id: \.self) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }

                        Picker("Приоритет (1-Высокий)", selection: $itemPriority) {
                            ForEach(1...3, id: \.self) { prio in
                                Text("\(prio)").tag(prio)
                            }
                        }
                    }
                    .navigationTitle(editingItemId == nil ? "Новая цель" : "Редактирование")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Отмена") { showingAddFinance = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Сохранить") {
                                if let id = editingItemId {
                                    let updated = FinancialItem(id: id, name: itemName, amount: Double(itemAmount) ?? 0, category: itemCategory, priority: itemPriority, isCompleted: false)
                                    dataManager.updateFinancialItem(item: updated)
                                } else {
                                    dataManager.addFinancialItem(name: itemName, amount: Double(itemAmount) ?? 0, category: itemCategory, priority: itemPriority)
                                }
                                showingAddFinance = false
                            }
                        }
                    }
                }
            }
        }
    }
}
