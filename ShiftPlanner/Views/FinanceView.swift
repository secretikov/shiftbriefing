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

    // Animation States
    @State private var activeDraggingId: UUID? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {

                        // Smart Budgeting Central Bubble
                        VStack(spacing: 10) {
                            Text("Свободные средства")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [Color.cyan.opacity(0.4), Color.blue.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 160, height: 160)
                                    .modifier(NeonGlowModifier(color: .cyan, radius: dataManager.remainingBalance > 0 ? 15 : 0))
                                    .overlay(
                                        Circle().stroke(LinearGradient(colors: [.white.opacity(0.6), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                                    )

                                VStack {
                                    Text("\(String(format: "%.0f", dataManager.remainingBalance)) \(dataManager.currencySymbol)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(dataManager.remainingBalance >= 0 ? .white : .red)
                                        .minimumScaleFactor(0.5)
                                        .padding(.horizontal, 10)
                                }
                            }

                            if dataManager.remainingBalance < 0 {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("Нужно еще \(dataManager.shiftsNeededForGoals) смен")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .padding(.top, 20)

                        // Goals/Expenses Categories Grid
                        let priorities = [1, 2, 3]
                        ForEach(priorities, id: \.self) { priority in
                            let items = dataManager.financialItems.filter { $0.priority == priority }
                            if !items.isEmpty {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text(priorityTitle(for: priority))
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding(.horizontal)

                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                        ForEach(items) { item in
                                            FinancialBubbleView(item: item) { updatedItem in
                                                dataManager.updateFinancialItem(item: updatedItem)
                                            } editAction: {
                                                editingItemId = item.id
                                                itemName = item.name
                                                itemAmount = String(format: "%.0f", item.amount)
                                                itemCategory = item.category
                                                itemPriority = item.priority
                                                showingAddFinance = true
                                            } deleteAction: {
                                                dataManager.deleteFinancialItem(id: item.id)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Умный Кошелек")
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
                        .font(.system(size: 24))
                        .foregroundColor(.cyan)
                        .modifier(NeonGlowModifier(color: .cyan, radius: 5))
                }
            }
            .sheet(isPresented: $showingAddFinance) {
                NavigationView {
                    ZStack {
                        Color.clear.ignoresSafeArea()
                        ScrollView {
                            VStack(spacing: 20) {
                                VStack(spacing: 15) {
                                    TextField("Название", text: $itemName)
                                        .glassTextField()
                                    TextField("Сумма (\(dataManager.currencySymbol))", text: $itemAmount)
                                        .keyboardType(.decimalPad)
                                        .glassTextField()
                                }
                                .liquidGlass()
                                .padding(.horizontal)

                                VStack(spacing: 15) {
                                    Picker("Категория", selection: $itemCategory) {
                                        ForEach(FinancialCategory.allCases, id: \.self) { cat in
                                            Text(cat.rawValue).tag(cat)
                                        }
                                    }
                                    .tint(.cyan)

                                    Picker("Приоритет", selection: $itemPriority) {
                                        Text("1 - Высокий").tag(1)
                                        Text("2 - Средний").tag(2)
                                        Text("3 - Низкий").tag(3)
                                    }
                                    .tint(.cyan)
                                }
                                .liquidGlass()
                                .padding(.horizontal)

                                Button(action: {
                                    if let id = editingItemId {
                                        let updated = FinancialItem(id: id, name: itemName, amount: Double(itemAmount) ?? 0, category: itemCategory, priority: itemPriority, isCompleted: false)
                                        dataManager.updateFinancialItem(item: updated)
                                    } else {
                                        dataManager.addFinancialItem(name: itemName, amount: Double(itemAmount) ?? 0, category: itemCategory, priority: itemPriority)
                                    }
                                    showingAddFinance = false
                                }) {
                                    Text("Сохранить")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.cyan)
                                        .cornerRadius(20)
                                        .modifier(NeonGlowModifier(color: .cyan, radius: 5))
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)
                            }
                            .padding(.vertical)
                        }
                    }
                    .navigationTitle(editingItemId == nil ? "Новая цель" : "Редактирование")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Закрыть") { showingAddFinance = false }
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }

    private func priorityTitle(for priority: Int) -> String {
        switch priority {
        case 1: return "Обязательные (Долги / Жизнь)"
        case 2: return "Накопления (Инвестиции / Цели)"
        default: return "Желания (Развлечения / Покупки)"
        }
    }
}

struct FinancialBubbleView: View {
    var item: FinancialItem
    var toggleAction: (FinancialItem) -> Void
    var editAction: () -> Void
    var deleteAction: () -> Void

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: 80, height: 80)

                // Liquid fill simulation
                if item.isCompleted {
                    Circle()
                        .fill(LinearGradient(colors: [bubbleColor().opacity(0.8), bubbleColor().opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                        .modifier(NeonGlowModifier(color: bubbleColor(), radius: 8))
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                                isAnimating = true
                            }
                        }
                }

                Circle()
                    .stroke(LinearGradient(colors: [.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                    .frame(width: 80, height: 80)

                Image(systemName: iconName())
                    .font(.title2)
                    .foregroundColor(item.isCompleted ? .white : bubbleColor().opacity(0.7))
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    var updatedItem = item
                    updatedItem.isCompleted.toggle()
                    toggleAction(updatedItem)
                }
            }

            Text(item.name)
                .font(.caption.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text("\(String(format: "%.0f", item.amount)) \(dataManager.currencySymbol)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
        .contextMenu {
            Button(action: editAction) {
                Label("Редактировать", systemImage: "pencil")
            }
            Button(role: .destructive, action: deleteAction) {
                Label("Удалить", systemImage: "trash")
            }
        }
    }

    private func bubbleColor() -> Color {
        switch item.category {
        case .debt: return .red
        case .investment: return .green
        case .savings: return .blue
        case .expense: return .orange
        }
    }

    private func iconName() -> String {
        switch item.category {
        case .debt: return "exclamationmark.circle"
        case .investment: return "arrow.up.right.circle"
        case .savings: return "safe"
        case .expense: return "cart"
        }
    }
}
