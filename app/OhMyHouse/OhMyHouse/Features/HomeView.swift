import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(store.text(
                        "愿望清单 → 家庭物品 → 维护",
                        "Wishlist → Inventory → Maintenance"
                    ))
                    .font(.headline)
                }
                Section {
                    NavigationLink {
                        WishlistView()
                    } label: {
                        DomainSummaryCard(
                            title: store.text("愿望清单", "Wishlist"),
                            detail: store.text("\(store.wishlistItems.count) 个想法", "\(store.wishlistItems.count) ideas"),
                            symbol: "heart"
                        )
                    }
                    NavigationLink {
                        InventoryView()
                    } label: {
                        DomainSummaryCard(
                            title: store.text("家庭物品", "Inventory"),
                            detail: store.text("已记录 \(store.inventoryItems.count) 件", "\(store.inventoryItems.count) items recorded"),
                            symbol: "shippingbox"
                        )
                    }
                    NavigationLink {
                        MaintenanceListView()
                    } label: {
                        DomainSummaryCard(
                            title: store.text("维护", "Maintenance"),
                            detail: store.text(
                                "\(store.maintenanceItems.filter { !$0.isCompleted }.count) 项维护计划",
                                "\(store.maintenanceItems.filter { !$0.isCompleted }.count) maintenance plans"
                            ),
                            symbol: "wrench.and.screwdriver"
                        )
                    }
                }
            }
            .navigationTitle(store.text("家", "Home"))
            .appScreenTools(showsMemberSheet: $showsMemberSheet)
        }
    }
}

private struct WishlistView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false
    @State private var showsAdd = false
    @State private var purchasedItem: WishlistItem?

    var body: some View {
        List {
            Section(store.text("想法", "Ideas")) {
                if store.wishlistItems.filter({ $0.status == "idea" }).isEmpty {
                    Text(store.text("还没有愿望", "No ideas yet"))
                        .foregroundStyle(.secondary)
                }
                ForEach(store.wishlistItems.filter { $0.status == "idea" }) { item in
                    HStack {
                        Image(systemName: "heart")
                        Text(item.title)
                        Spacer()
                        Button(store.text("已购买", "Purchased")) {
                            purchasedItem = item
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            let purchased = store.wishlistItems.filter { $0.status == "purchased" }
            if !purchased.isEmpty {
                Section(store.text("已购买", "Purchased")) {
                    ForEach(purchased) { item in
                        Label(item.title, systemImage: item.inventoryItemID == nil ? "checkmark" : "shippingbox")
                    }
                }
            }
        }
        .navigationTitle(store.text("愿望清单", "Wishlist"))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showsAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .appScreenTools(showsMemberSheet: $showsMemberSheet)
        .sheet(isPresented: $showsAdd) { AddWishlistView() }
        .confirmationDialog(
            store.text("要同时添加到家庭物品吗？", "Also add this to Inventory?"),
            isPresented: Binding(
                get: { purchasedItem != nil },
                set: { if !$0 { purchasedItem = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(store.text("添加到家庭物品", "Add to Inventory")) {
                if let purchasedItem { store.markWishlistPurchased(purchasedItem, addToInventory: true) }
                purchasedItem = nil
            }
            Button(store.text("只标记为已购买", "Only mark as purchased")) {
                if let purchasedItem { store.markWishlistPurchased(purchasedItem, addToInventory: false) }
                purchasedItem = nil
            }
            Button(store.text("取消", "Cancel"), role: .cancel) { purchasedItem = nil }
        }
    }
}

private struct InventoryView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false
    @State private var showsAdd = false

    var body: some View {
        List {
            if store.inventoryItems.isEmpty {
                Text(store.text("还没有家庭物品", "No inventory items yet"))
                    .foregroundStyle(.secondary)
            }
            ForEach(store.inventoryItems) { item in
                HStack {
                    Image(systemName: "shippingbox")
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.title)
                        Text(item.room ?? store.text("未指定区域", "No area specified"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if item.sourceWishlistID != nil {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)
                            .accessibilityLabel(store.text("来自愿望清单", "From Wishlist"))
                    }
                }
            }
        }
        .navigationTitle(store.text("家庭物品", "Inventory"))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showsAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .appScreenTools(showsMemberSheet: $showsMemberSheet)
        .sheet(isPresented: $showsAdd) { AddInventoryView() }
    }
}

private struct MaintenanceListView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false
    @State private var showsAdd = false

    var body: some View {
        List {
            Section(store.text("接下来", "Upcoming")) {
                if store.maintenanceItems.filter({ !$0.isCompleted }).isEmpty {
                    Text(store.text("还没有维护计划", "No maintenance plans yet"))
                        .foregroundStyle(.secondary)
                }
                ForEach(store.maintenanceItems.filter { !$0.isCompleted }) { item in
                    maintenanceRow(item)
                }
            }
            let completed = store.maintenanceItems.filter(\.isCompleted)
            if !completed.isEmpty {
                Section(store.text("已完成", "Completed")) {
                    ForEach(completed) { item in maintenanceRow(item) }
                }
            }
        }
        .navigationTitle(store.text("维护", "Maintenance"))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showsAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .appScreenTools(showsMemberSheet: $showsMemberSheet)
        .sheet(isPresented: $showsAdd) { AddMaintenanceView() }
    }

    private func maintenanceRow(_ item: MaintenanceItem) -> some View {
        Button {
            if !item.isCompleted { store.completeMaintenance(item) }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                    HStack {
                        Text(item.nextDate, format: .dateTime.year().month().day())
                        if let inventory = store.inventoryItems.first(where: { $0.id == item.inventoryItemID }) {
                            Text("• \(inventory.title)")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct AddWishlistView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    var body: some View {
        NavigationStack {
            Form { TextField(store.text("想买或改善什么？", "What would improve your home?"), text: $title) }
                .navigationTitle(store.text("添加愿望", "Add Wishlist Item"))
                .homeFormToolbar(canSave: !title.trimmed.isEmpty) {
                    store.addWishlistItem(title: title)
                    dismiss()
                }
        }
    }
}

private struct AddInventoryView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var room = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField(store.text("物品名称", "Item name"), text: $title)
                TextField(store.text("房间或区域（可选）", "Room or area (optional)"), text: $room)
            }
            .navigationTitle(store.text("添加家庭物品", "Add Inventory Item"))
            .homeFormToolbar(canSave: !title.trimmed.isEmpty) {
                store.addInventoryItem(title: title, room: room)
                dismiss()
            }
        }
    }
}

private struct AddMaintenanceView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var nextDate = Date()
    @State private var inventoryID: UUID?
    @State private var recurrence: SimpleRecurrence = .none
    @State private var assigneeIDs = Set<UUID>()
    @State private var requiredItem = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField(store.text("要做什么？", "What needs doing?"), text: $title)
                DatePicker(store.text("下一次日期", "Next date"), selection: $nextDate, displayedComponents: .date)
                Picker(store.text("关联家庭物品", "Related inventory item"), selection: $inventoryID) {
                    Text(store.text("不关联", "None")).tag(UUID?.none)
                    ForEach(store.inventoryItems) { item in
                        Text(item.title).tag(Optional(item.id))
                    }
                }
                Picker(store.text("重复", "Repeat"), selection: $recurrence) {
                    ForEach(SimpleRecurrence.allCases) { item in
                        Text(recurrenceName(item)).tag(item)
                    }
                }
                Section(store.text("负责人（可选）", "People responsible (optional)")) {
                    ForEach(store.members) { member in
                        Button { toggleMember(member.id) } label: {
                            HStack {
                                MemberAvatarView(member: member, size: 30)
                                Text(member.name)
                                Spacer()
                                if assigneeIDs.contains(member.id) { Image(systemName: "checkmark") }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                Section {
                    TextField(store.text("需要购买的用品（可选）", "Item to buy (optional)"), text: $requiredItem)
                } footer: {
                    Text(store.text("填写后会加入统一购物清单，并标记为维护来源。", "This will be added to the shared Shopping List with a Maintenance source."))
                }
            }
            .navigationTitle(store.text("添加维护", "Add Maintenance"))
            .homeFormToolbar(canSave: !title.trimmed.isEmpty) {
                store.addMaintenance(
                    title: title, nextDate: nextDate, inventoryItemID: inventoryID,
                    recurrence: recurrence, assigneeIDs: Array(assigneeIDs), requiredItem: requiredItem
                )
                dismiss()
            }
        }
    }

    private func toggleMember(_ id: UUID) {
        if assigneeIDs.contains(id) { assigneeIDs.remove(id) } else { assigneeIDs.insert(id) }
    }

    private func recurrenceName(_ value: SimpleRecurrence) -> String {
        switch value {
        case .none: store.text("不重复", "Never")
        case .daily: store.text("每天", "Daily")
        case .weekly: store.text("每周", "Weekly")
        case .biweekly: store.text("每两周", "Every two weeks")
        case .monthly: store.text("每月", "Monthly")
        case .yearly: store.text("每年", "Yearly")
        }
    }
}

private struct HomeFormToolbar: ViewModifier {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    let canSave: Bool
    let save: () -> Void

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(store.text("取消", "Cancel")) { dismiss() }
            }
            ToolbarItem(placement: .automatic) {
                Button(store.displayLanguage == .chinese ? "文" : "A") { store.toggleDisplayLanguage() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(store.text("保存", "Save"), action: save).disabled(!canSave)
            }
        }
    }
}

private extension View {
    func homeFormToolbar(canSave: Bool, save: @escaping () -> Void) -> some View {
        modifier(HomeFormToolbar(canSave: canSave, save: save))
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
