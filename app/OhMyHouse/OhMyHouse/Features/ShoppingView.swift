import SwiftUI

struct ShoppingView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false
    @State private var showsAddItem = false
    @State private var filter = ShoppingFilter.all
    @State private var editingItem: ShoppingItemEntity?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(store.text("查看", "Show"), selection: $filter) {
                        Text(store.text("全部", "All")).tag(ShoppingFilter.all)
                        Text(store.text("食材", "Grocery")).tag(ShoppingFilter.meals)
                        Text(store.text("用品", "Supplies")).tag(ShoppingFilter.supplies)
                        Text(store.text("维护", "Maintenance")).tag(ShoppingFilter.maintenance)
                    }
                    .pickerStyle(.segmented)
                }

                if filter == .all || filter == .meals {
                    shoppingSection(.meals, store.text("餐食 / 食材", "Meals / Grocery"))
                }
                if filter == .all || filter == .supplies {
                    shoppingSection(.supplies, store.text("家庭用品", "Household Supplies"))
                }
                if filter == .all || filter == .maintenance {
                    shoppingSection(.maintenance, store.text("维护用品", "Maintenance Items"))
                }

                let purchased = store.shoppingItems.filter {
                    $0.isPurchased && (filter == .all || $0.sourceKind == filter.rawValue)
                }
                if !purchased.isEmpty {
                    Section(store.text("已购买", "Purchased")) {
                        ForEach(purchased) { item in
                            shoppingRow(item)
                        }
                    }
                }
            }
            .navigationTitle(store.text("购物", "Shopping"))
            .appScreenTools(showsMemberSheet: $showsMemberSheet)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showsAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(store.text("添加购物项目", "Add shopping item"))
                }
            }
            .sheet(isPresented: $showsAddItem) {
                ShoppingItemFormView()
            }
            .sheet(item: $editingItem) { item in
                ShoppingItemFormView(item: item)
            }
        }
    }

    @ViewBuilder
    private func shoppingSection(_ source: ShoppingSource, _ title: String) -> some View {
        let items = store.items(for: source)
        Section(title) {
            if items.isEmpty {
                Text(store.text("暂无项目", "No items"))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items) { item in
                    shoppingRow(item)
                }
            }
        }
    }

    private func shoppingRow(_ item: ShoppingItemEntity) -> some View {
        Button {
            store.togglePurchased(item)
        } label: {
            HStack {
                Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                Text(item.title)
                    .strikethrough(item.isPurchased)
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                store.deleteShoppingItem(item)
            } label: {
                Label(store.text("删除", "Delete"), systemImage: "trash")
            }
            Button {
                editingItem = item
            } label: {
                Label(store.text("编辑", "Edit"), systemImage: "pencil")
            }
            .tint(.blue)
        }
        .contextMenu {
            Button(store.text("编辑", "Edit")) { editingItem = item }
            Button(store.text("删除", "Delete"), role: .destructive) {
                store.deleteShoppingItem(item)
            }
        }
    }
}

private enum ShoppingFilter: String, Identifiable {
    case all
    case meals
    case supplies
    case maintenance

    var id: Self { self }
}

private struct ShoppingItemFormView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    let item: ShoppingItemEntity?
    @State private var title: String
    @State private var source: ShoppingSource

    init(item: ShoppingItemEntity? = nil) {
        self.item = item
        _title = State(initialValue: item?.title ?? "")
        _source = State(initialValue: item.flatMap { ShoppingSource(rawValue: $0.sourceKind) } ?? .meals)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(store.text("需要购买什么？", "What do you need?"), text: $title)
                Picker(store.text("来源", "Source"), selection: $source) {
                    Text(store.text("餐食 / 食材", "Meals / Grocery")).tag(ShoppingSource.meals)
                    Text(store.text("家庭用品", "Household Supplies")).tag(ShoppingSource.supplies)
                    Text(store.text("维护用品", "Maintenance Items")).tag(ShoppingSource.maintenance)
                }
            }
            .navigationTitle(item == nil
                ? store.text("添加购物项目", "Add Shopping Item")
                : store.text("编辑购物项目", "Edit Shopping Item"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.text("取消", "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .automatic) {
                    Button(store.displayLanguage == .chinese ? "文" : "A") {
                        store.toggleDisplayLanguage()
                    }
                    .accessibilityLabel(store.text("切换为英文", "Switch to Chinese"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(item == nil ? store.text("添加", "Add") : store.text("保存", "Save")) {
                        if let item {
                            store.updateShoppingItem(item, title: title, source: source)
                        } else {
                            store.addShoppingItem(title: title, source: source)
                        }
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
