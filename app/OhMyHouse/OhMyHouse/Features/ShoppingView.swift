import SwiftUI

struct ShoppingView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false
    @State private var showsAddItem = false

    var body: some View {
        NavigationStack {
            List {
                shoppingSection(.meals, store.text("餐食 / 食材", "Meals / Grocery"))
                shoppingSection(.supplies, store.text("家庭用品", "Household Supplies"))
                shoppingSection(.maintenance, store.text("维护用品", "Maintenance Items"))

                let purchased = store.shoppingItems.filter(\.isPurchased)
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
                AddShoppingItemView()
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
    }
}

private struct AddShoppingItemView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var source = ShoppingSource.supplies

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
            .navigationTitle(store.text("添加购物项目", "Add Shopping Item"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.text("取消", "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.text("添加", "Add")) {
                        store.addShoppingItem(title: title, source: source)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
