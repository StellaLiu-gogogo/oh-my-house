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
    @State private var editingItem: WishlistItem?

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
                    .swipeActions {
                        Button(role: .destructive) { store.deleteWishlistItem(item) } label: {
                            Label(store.text("删除", "Delete"), systemImage: "trash")
                        }
                        Button { editingItem = item } label: {
                            Label(store.text("编辑", "Edit"), systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .contextMenu {
                        Button(store.text("编辑", "Edit")) { editingItem = item }
                        Button(store.text("删除", "Delete"), role: .destructive) { store.deleteWishlistItem(item) }
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
        .sheet(item: $editingItem) { AddWishlistView(item: $0) }
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
    @State private var editingItem: InventoryItem?

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
                .contentShape(Rectangle())
                .onTapGesture { editingItem = item }
                .swipeActions {
                    Button(role: .destructive) { store.deleteInventoryItem(item) } label: {
                        Label(store.text("删除", "Delete"), systemImage: "trash")
                    }
                    Button { editingItem = item } label: {
                        Label(store.text("编辑", "Edit"), systemImage: "pencil")
                    }
                    .tint(.blue)
                }
                .contextMenu {
                    Button(store.text("编辑", "Edit")) { editingItem = item }
                    Button(store.text("删除", "Delete"), role: .destructive) { store.deleteInventoryItem(item) }
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
        .sheet(item: $editingItem) { AddInventoryView(item: $0) }
    }
}

private struct MaintenanceListView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false
    @State private var showsAdd = false
    @State private var editingItem: MaintenanceItem?

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
        .sheet(item: $editingItem) { AddMaintenanceView(item: $0) }
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
        .swipeActions {
            Button(role: .destructive) { store.deleteMaintenance(item) } label: {
                Label(store.text("删除", "Delete"), systemImage: "trash")
            }
            Button { editingItem = item } label: {
                Label(store.text("编辑", "Edit"), systemImage: "pencil")
            }
            .tint(.blue)
        }
        .contextMenu {
            Button(store.text("编辑", "Edit")) { editingItem = item }
            Button(store.text("删除", "Delete"), role: .destructive) { store.deleteMaintenance(item) }
        }
    }
}

private struct AddWishlistView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    let item: WishlistItem?
    @State private var title: String

    init(item: WishlistItem? = nil) {
        self.item = item
        _title = State(initialValue: item?.title ?? "")
    }

    var body: some View {
        NavigationStack {
            Form { TextField(store.text("想买或改善什么？", "What would improve your home?"), text: $title) }
                .navigationTitle(item == nil
                    ? store.text("添加愿望", "Add Wishlist Item")
                    : store.text("编辑愿望", "Edit Wishlist Item"))
                .homeFormToolbar(canSave: !title.trimmed.isEmpty) {
                    if let item { store.updateWishlistItem(item, title: title) }
                    else { store.addWishlistItem(title: title) }
                    dismiss()
                }
        }
    }
}

private struct AddInventoryView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    let item: InventoryItem?
    @State private var title: String
    @State private var room: String

    init(item: InventoryItem? = nil) {
        self.item = item
        _title = State(initialValue: item?.title ?? "")
        _room = State(initialValue: item?.room ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(store.text("物品名称", "Item name"), text: $title)
                TextField(store.text("房间或区域（可选）", "Room or area (optional)"), text: $room)
            }
            .navigationTitle(item == nil
                ? store.text("添加家庭物品", "Add Inventory Item")
                : store.text("编辑家庭物品", "Edit Inventory Item"))
            .homeFormToolbar(canSave: !title.trimmed.isEmpty) {
                if let item { store.updateInventoryItem(item, title: title, room: room) }
                else { store.addInventoryItem(title: title, room: room) }
                dismiss()
            }
        }
    }
}

private struct AddMaintenanceView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    let item: MaintenanceItem?
    @State private var title: String
    @State private var nextDate: Date
    @State private var inventoryID: UUID?
    @State private var recurrence: SimpleRecurrence
    @State private var assigneeIDs: Set<UUID>
    @State private var requiredItem = ""

    init(item: MaintenanceItem? = nil) {
        self.item = item
        _title = State(initialValue: item?.title ?? "")
        _nextDate = State(initialValue: item?.nextDate ?? Date())
        _inventoryID = State(initialValue: item?.inventoryItemID)
        _recurrence = State(initialValue: item.flatMap { SimpleRecurrence(rawValue: $0.recurrence) } ?? .none)
        _assigneeIDs = State(initialValue: Set(item?.assigneeIDs ?? []))
    }

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
            .navigationTitle(item == nil
                ? store.text("添加维护", "Add Maintenance")
                : store.text("编辑维护", "Edit Maintenance"))
            .homeFormToolbar(canSave: !title.trimmed.isEmpty) {
                if let item {
                    store.updateMaintenance(
                        item, title: title, nextDate: nextDate, inventoryItemID: inventoryID,
                        recurrence: recurrence, assigneeIDs: Array(assigneeIDs), requiredItem: requiredItem
                    )
                } else {
                    store.addMaintenance(
                        title: title, nextDate: nextDate, inventoryItemID: inventoryID,
                        recurrence: recurrence, assigneeIDs: Array(assigneeIDs), requiredItem: requiredItem
                    )
                }
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
