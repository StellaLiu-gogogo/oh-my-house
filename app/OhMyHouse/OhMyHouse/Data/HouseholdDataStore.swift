import CoreData
import SwiftUI

enum AppDisplayLanguage: String {
    case chinese
    case english
}

enum ShoppingSource: String, CaseIterable, Identifiable {
    case meals
    case supplies
    case maintenance

    var id: Self { self }
}

@MainActor
protocol HouseholdDataStore: AnyObject {
    var activeHouseholdID: UUID { get }
    func addShoppingItem(title: String, source: ShoppingSource, sourceID: UUID?)
    func togglePurchased(_ item: ShoppingItemEntity)
}

@MainActor
final class LocalHouseholdDataStore: ObservableObject, HouseholdDataStore {
    @Published var displayLanguage: AppDisplayLanguage = .chinese
    @Published var currentMemberName = "Me"
    @Published private(set) var currentMemberID: UUID?
    @Published private(set) var members: [MemberEntity] = []
    @Published private(set) var shoppingItems: [ShoppingItemEntity] = []
    @Published private(set) var meals: [MealPlanItem] = []
    @Published private(set) var recipes: [RecipeItem] = []
    @Published private(set) var chores: [ChoreItem] = []
    @Published private(set) var events: [HouseholdEventItem] = []
    @Published private(set) var wishlistItems: [WishlistItem] = []
    @Published private(set) var inventoryItems: [InventoryItem] = []
    @Published private(set) var maintenanceItems: [MaintenanceItem] = []

    let activeHouseholdID: UUID
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context

        let householdRequest = NSFetchRequest<HouseholdEntity>(entityName: "HouseholdEntity")
        householdRequest.fetchLimit = 1

        if let household = try? context.fetch(householdRequest).first {
            activeHouseholdID = household.id
        } else {
            let household = HouseholdEntity(context: context)
            household.id = UUID()
            household.name = "My Home"
            household.createdAt = Date()
            household.updatedAt = Date()
            activeHouseholdID = household.id

            let member = MemberEntity(context: context)
            member.id = UUID()
            member.householdID = household.id
            member.name = "Me"
            member.colorHex = "4A90E2"
            member.preferredLanguage = "zh-Hans"
            member.createdAt = Date()
            member.updatedAt = Date()
            try? context.save()
        }

        loadCurrentMember()
        reloadMembers()
        reloadShoppingItems()
        reloadPlanningItems()
    }

    func text(_ chinese: String, _ english: String) -> String {
        displayLanguage == .chinese ? chinese : english
    }

    func toggleDisplayLanguage() {
        displayLanguage = displayLanguage == .chinese ? .english : .chinese
        if let member = currentMember {
            member.preferredLanguage = displayLanguage == .chinese ? "zh-Hans" : "en"
            member.updatedAt = Date()
            try? context.save()
        }
    }

    var currentMember: MemberEntity? {
        guard let currentMemberID else { return members.first }
        return members.first { $0.id == currentMemberID }
    }

    func addMember(name: String, colorHex: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let member = MemberEntity(context: context)
        member.id = UUID()
        member.householdID = activeHouseholdID
        member.name = trimmed
        member.colorHex = colorHex
        member.preferredLanguage = displayLanguage == .chinese ? "zh-Hans" : "en"
        member.createdAt = Date()
        member.updatedAt = Date()
        try? context.save()
        reloadMembers()
    }

    func selectMember(_ member: MemberEntity) {
        currentMemberID = member.id
        currentMemberName = member.name
        displayLanguage = member.preferredLanguage == "en" ? .english : .chinese
        UserDefaults.standard.set(member.id.uuidString, forKey: "currentMemberID")
    }

    func updateAvatar(for member: MemberEntity, data: Data) {
        member.avatarData = data
        member.updatedAt = Date()
        try? context.save()
        reloadMembers()
    }

    func updateMemberName(_ member: MemberEntity, name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        member.name = trimmed
        member.updatedAt = Date()
        try? context.save()
        if currentMemberID == member.id {
            currentMemberName = trimmed
        }
        reloadMembers()
    }

    func addShoppingItem(title: String, source: ShoppingSource, sourceID: UUID? = nil) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let item = ShoppingItemEntity(context: context)
        item.id = UUID()
        item.householdID = activeHouseholdID
        item.title = trimmed
        item.sourceKind = source.rawValue
        item.sourceID = sourceID
        item.isPurchased = false
        item.createdAt = Date()
        item.updatedAt = Date()
        saveAndReload()
    }

    func togglePurchased(_ item: ShoppingItemEntity) {
        item.isPurchased.toggle()
        item.purchasedAt = item.isPurchased ? Date() : nil
        item.updatedAt = Date()
        saveAndReload()
    }

    func updateShoppingItem(_ item: ShoppingItemEntity, title: String, source: ShoppingSource) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        item.title = trimmed
        item.sourceKind = source.rawValue
        item.updatedAt = Date()
        saveAndReload()
    }

    func deleteShoppingItem(_ item: ShoppingItemEntity) {
        item.deletedAt = Date()
        item.updatedAt = Date()
        saveAndReload()
    }

    @discardableResult
    func addMeal(
        title: String,
        date: Date,
        slot: String,
        participantIDs: [UUID],
        servings: Int,
        recipeID: UUID? = nil
    ) -> UUID? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let item = MealPlanItem(
            id: UUID(), title: trimmed, date: date, slot: slot,
            participantIDs: participantIDs, servings: servings, recipeID: recipeID
        )
        savePlanningItem(item, title: trimmed, entityName: "MealEntity")
        return item.id
    }

    func updateMeal(
        _ item: MealPlanItem,
        title: String,
        date: Date,
        slot: String,
        participantIDs: [UUID],
        servings: Int,
        recipeID: UUID? = nil
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var changed = item
        changed.title = trimmed
        changed.date = date
        changed.slot = slot
        changed.participantIDs = participantIDs
        changed.servings = servings
        changed.recipeID = recipeID
        updatePlanningItem(changed, title: trimmed, entityName: "MealEntity")
    }

    func deleteMeal(_ item: MealPlanItem) {
        deletePlanningItem(id: item.id, entityName: "MealEntity")
    }

    func addRecipe(
        title: String,
        baseServings: Int,
        ingredients: [RecipeIngredient],
        instructions: String,
        photoData: Data?,
        steps: [RecipeStep]
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let recipe = RecipeItem(
            id: UUID(), title: trimmed, baseServings: max(baseServings, 1),
            ingredients: ingredients.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            instructions: instructions.trimmingCharacters(in: .whitespacesAndNewlines),
            photoData: photoData,
            steps: steps.filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        )
        savePlanningItem(recipe, title: trimmed, entityName: "RecipeEntity")
    }

    func updateRecipe(
        _ item: RecipeItem,
        title: String,
        baseServings: Int,
        ingredients: [RecipeIngredient],
        instructions: String,
        photoData: Data?,
        steps: [RecipeStep]
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var changed = item
        changed.title = trimmed
        changed.baseServings = max(baseServings, 1)
        changed.ingredients = ingredients.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        changed.instructions = instructions.trimmingCharacters(in: .whitespacesAndNewlines)
        changed.photoData = photoData
        changed.steps = steps.filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        updatePlanningItem(changed, title: trimmed, entityName: "RecipeEntity")
    }

    func deleteRecipe(_ item: RecipeItem) {
        deletePlanningItem(id: item.id, entityName: "RecipeEntity")
    }

    func addRecipeIngredientsToShopping(
        recipe: RecipeItem,
        mealID: UUID,
        servings: Int,
        ingredientIDs: Set<UUID>
    ) {
        let ratio = Double(max(servings, 1)) / Double(max(recipe.baseServings, 1))
        for ingredient in recipe.ingredients where ingredientIDs.contains(ingredient.id) {
            let amount: String
            if let quantity = ingredient.quantity {
                let scaled = quantity * ratio
                amount = scaled.formatted(.number.precision(.fractionLength(0...2)))
            } else {
                amount = ""
            }
            let title = [amount, ingredient.unit, ingredient.name]
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                .joined(separator: " ")
            addShoppingItem(title: title, source: .meals, sourceID: mealID)
        }
    }

    func addChore(
        title: String,
        dueDate: Date?,
        assignmentMode: ChoreAssignmentMode,
        assigneeIDs: [UUID],
        recurrence: SimpleRecurrence
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = ChoreItem(
            id: UUID(), title: trimmed, dueDate: dueDate,
            assignmentMode: assignmentMode.rawValue, assigneeIDs: assigneeIDs,
            recurrence: recurrence.rawValue, isCompleted: false, completedAt: nil
        )
        savePlanningItem(item, title: trimmed, entityName: "ChoreEntity")
    }

    func updateChore(
        _ item: ChoreItem,
        title: String,
        dueDate: Date?,
        assignmentMode: ChoreAssignmentMode,
        assigneeIDs: [UUID],
        recurrence: SimpleRecurrence
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var changed = item
        changed.title = trimmed
        changed.dueDate = dueDate
        changed.assignmentMode = assignmentMode.rawValue
        changed.assigneeIDs = assigneeIDs
        changed.recurrence = recurrence.rawValue
        if assignmentMode != .rotating { changed.rotationIndex = nil }
        updatePlanningItem(changed, title: trimmed, entityName: "ChoreEntity")
    }

    func deleteChore(_ item: ChoreItem) {
        deletePlanningItem(id: item.id, entityName: "ChoreEntity")
    }

    func toggleChore(_ item: ChoreItem) {
        var changed = item
        if item.isCompleted {
            changed.isCompleted = false
            changed.completedAt = nil
            if let nextID = item.generatedNextID {
                deletePlanningItem(id: nextID, entityName: "ChoreEntity")
                changed.generatedNextID = nil
            }
        } else {
            changed.isCompleted = true
            changed.completedAt = Date()
            let recurrence = SimpleRecurrence(rawValue: item.recurrence) ?? .none
            if recurrence != .none,
               let dueDate = item.dueDate,
               let nextDueDate = nextDate(after: dueDate, recurrence: recurrence) {
                let next = ChoreItem(
                    id: UUID(), title: item.title, dueDate: nextDueDate,
                    assignmentMode: item.assignmentMode, assigneeIDs: item.assigneeIDs,
                    recurrence: item.recurrence, isCompleted: false,
                    completedAt: nil, generatedNextID: nil,
                    rotationIndex: item.assignmentMode == ChoreAssignmentMode.rotating.rawValue && !item.assigneeIDs.isEmpty
                        ? ((item.rotationIndex ?? 0) + 1) % item.assigneeIDs.count
                        : nil
                )
                changed.generatedNextID = next.id
                savePlanningItem(next, title: next.title, entityName: "ChoreEntity")
            }
        }
        updatePlanningItem(changed, title: changed.title, entityName: "ChoreEntity")
    }

    func addEvent(
        title: String,
        startDate: Date,
        endDate: Date?,
        isAllDay: Bool,
        recurrence: SimpleRecurrence,
        reminderDate: Date?,
        reminderText: String?
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = HouseholdEventItem(
            id: UUID(), title: trimmed, startDate: startDate, endDate: endDate,
            isAllDay: isAllDay, recurrence: recurrence.rawValue,
            reminderDate: reminderDate, reminderText: reminderText
        )
        savePlanningItem(item, title: trimmed, entityName: "HouseholdEventEntity")
    }

    func updateEvent(
        _ item: HouseholdEventItem,
        title: String,
        startDate: Date,
        endDate: Date?,
        isAllDay: Bool,
        recurrence: SimpleRecurrence,
        reminderDate: Date?,
        reminderText: String?
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var changed = item
        changed.title = trimmed
        changed.startDate = startDate
        changed.endDate = endDate
        changed.isAllDay = isAllDay
        changed.recurrence = recurrence.rawValue
        changed.reminderDate = reminderDate
        changed.reminderText = reminderText
        updatePlanningItem(changed, title: trimmed, entityName: "HouseholdEventEntity")
    }

    func deleteEvent(_ item: HouseholdEventItem) {
        deletePlanningItem(id: item.id, entityName: "HouseholdEventEntity")
    }

    func addWishlistItem(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = WishlistItem(id: UUID(), title: trimmed, status: "idea", inventoryItemID: nil)
        savePlanningItem(item, title: trimmed, entityName: "WishlistItemEntity")
    }

    func updateWishlistItem(_ item: WishlistItem, title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var changed = item
        changed.title = trimmed
        updatePlanningItem(changed, title: trimmed, entityName: "WishlistItemEntity")
    }

    func deleteWishlistItem(_ item: WishlistItem) {
        deletePlanningItem(id: item.id, entityName: "WishlistItemEntity")
    }

    func markWishlistPurchased(_ item: WishlistItem, addToInventory: Bool) {
        var changed = item
        changed.status = "purchased"
        if addToInventory {
            let inventory = InventoryItem(
                id: UUID(), title: item.title, room: nil, sourceWishlistID: item.id
            )
            changed.inventoryItemID = inventory.id
            savePlanningItem(inventory, title: inventory.title, entityName: "InventoryItemEntity")
        }
        updatePlanningItem(changed, title: changed.title, entityName: "WishlistItemEntity")
    }

    func addInventoryItem(title: String, room: String?) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = InventoryItem(
            id: UUID(), title: trimmed,
            room: room?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            sourceWishlistID: nil
        )
        savePlanningItem(item, title: trimmed, entityName: "InventoryItemEntity")
    }

    func updateInventoryItem(_ item: InventoryItem, title: String, room: String?) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var changed = item
        changed.title = trimmed
        changed.room = room?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        updatePlanningItem(changed, title: trimmed, entityName: "InventoryItemEntity")
    }

    func deleteInventoryItem(_ item: InventoryItem) {
        deletePlanningItem(id: item.id, entityName: "InventoryItemEntity")
    }

    func addMaintenance(
        title: String,
        nextDate: Date,
        inventoryItemID: UUID?,
        recurrence: SimpleRecurrence,
        assigneeIDs: [UUID],
        requiredItem: String?
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = MaintenanceItem(
            id: UUID(), title: trimmed, nextDate: nextDate,
            inventoryItemID: inventoryItemID, recurrence: recurrence.rawValue,
            assigneeIDs: assigneeIDs, completionHistory: [], isCompleted: false
        )
        savePlanningItem(item, title: trimmed, entityName: "MaintenanceEntity")
        if let requiredItem = requiredItem?.trimmingCharacters(in: .whitespacesAndNewlines),
           !requiredItem.isEmpty {
            addShoppingItem(title: requiredItem, source: .maintenance, sourceID: item.id)
        }
    }

    func updateMaintenance(
        _ item: MaintenanceItem,
        title: String,
        nextDate: Date,
        inventoryItemID: UUID?,
        recurrence: SimpleRecurrence,
        assigneeIDs: [UUID],
        requiredItem: String?
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var changed = item
        changed.title = trimmed
        changed.nextDate = nextDate
        changed.inventoryItemID = inventoryItemID
        changed.recurrence = recurrence.rawValue
        changed.assigneeIDs = assigneeIDs
        updatePlanningItem(changed, title: trimmed, entityName: "MaintenanceEntity")
        if let requiredItem = requiredItem?.trimmingCharacters(in: .whitespacesAndNewlines),
           !requiredItem.isEmpty {
            addShoppingItem(title: requiredItem, source: .maintenance, sourceID: item.id)
        }
    }

    func deleteMaintenance(_ item: MaintenanceItem) {
        deletePlanningItem(id: item.id, entityName: "MaintenanceEntity")
    }

    func completeMaintenance(_ item: MaintenanceItem) {
        var changed = item
        changed.completionHistory.append(Date())
        let recurrence = SimpleRecurrence(rawValue: changed.recurrence) ?? .none
        if recurrence == .none {
            changed.isCompleted = true
        } else if let next = nextDate(after: changed.nextDate, recurrence: recurrence) {
            changed.nextDate = next
        }
        updatePlanningItem(changed, title: changed.title, entityName: "MaintenanceEntity")
    }

    func restoreMaintenance(_ item: MaintenanceItem) {
        updatePlanningItem(item, title: item.title, entityName: "MaintenanceEntity")
    }

    func items(for source: ShoppingSource, purchased: Bool = false) -> [ShoppingItemEntity] {
        shoppingItems.filter { $0.sourceKind == source.rawValue && $0.isPurchased == purchased }
    }

    private func loadCurrentMember() {
        let request = NSFetchRequest<MemberEntity>(entityName: "MemberEntity")
        request.predicate = NSPredicate(format: "householdID == %@", activeHouseholdID as CVarArg)
        let savedID = UserDefaults.standard.string(forKey: "currentMemberID").flatMap(UUID.init)
        let fetched = (try? context.fetch(request)) ?? []
        if let member = fetched.first(where: { $0.id == savedID }) ?? fetched.first {
            currentMemberID = member.id
            currentMemberName = member.name
            displayLanguage = member.preferredLanguage == "en" ? .english : .chinese
        }
    }

    private func reloadMembers() {
        let request = NSFetchRequest<MemberEntity>(entityName: "MemberEntity")
        request.predicate = NSPredicate(format: "householdID == %@", activeHouseholdID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        members = (try? context.fetch(request)) ?? []
        if currentMemberID == nil, let first = members.first {
            selectMember(first)
        }
    }

    private func reloadShoppingItems() {
        let request = NSFetchRequest<ShoppingItemEntity>(entityName: "ShoppingItemEntity")
        request.predicate = NSPredicate(
            format: "householdID == %@ AND deletedAt == nil",
            activeHouseholdID as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        shoppingItems = (try? context.fetch(request)) ?? []
    }

    private func reloadPlanningItems() {
        meals = fetchPlanningItems(entityName: "MealEntity", as: MealPlanItem.self)
            .sorted { $0.date < $1.date }
        recipes = fetchPlanningItems(entityName: "RecipeEntity", as: RecipeItem.self)
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        chores = fetchPlanningItems(entityName: "ChoreEntity", as: ChoreItem.self)
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        events = fetchPlanningItems(entityName: "HouseholdEventEntity", as: HouseholdEventItem.self)
            .sorted { $0.startDate < $1.startDate }
        wishlistItems = fetchPlanningItems(entityName: "WishlistItemEntity", as: WishlistItem.self)
        inventoryItems = fetchPlanningItems(entityName: "InventoryItemEntity", as: InventoryItem.self)
        maintenanceItems = fetchPlanningItems(entityName: "MaintenanceEntity", as: MaintenanceItem.self)
            .sorted { $0.nextDate < $1.nextDate }
    }

    private func fetchPlanningItems<Value: Decodable>(
        entityName: String,
        as type: Value.Type
    ) -> [Value] {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(
            format: "householdID == %@ AND deletedAt == nil",
            activeHouseholdID as CVarArg
        )
        return ((try? context.fetch(request)) ?? []).compactMap { object in
            guard let data = object.value(forKey: "payload") as? Data else { return nil }
            return try? JSONDecoder().decode(type, from: data)
        }
    }

    private func savePlanningItem<Value: Encodable & Identifiable>(
        _ value: Value,
        title: String,
        entityName: String
    ) where Value.ID == UUID {
        guard let data = try? JSONEncoder().encode(value) else { return }
        let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        let now = Date()
        object.setValue(value.id, forKey: "id")
        object.setValue(activeHouseholdID, forKey: "householdID")
        object.setValue(title, forKey: "title")
        object.setValue(data, forKey: "payload")
        object.setValue(now, forKey: "createdAt")
        object.setValue(now, forKey: "updatedAt")
        try? context.save()
        reloadPlanningItems()
    }

    private func updatePlanningItem<Value: Encodable & Identifiable>(
        _ value: Value,
        title: String,
        entityName: String
    ) where Value.ID == UUID {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", value.id as CVarArg)
        guard let object = try? context.fetch(request).first,
              let data = try? JSONEncoder().encode(value) else { return }
        object.setValue(title, forKey: "title")
        object.setValue(data, forKey: "payload")
        object.setValue(Date(), forKey: "updatedAt")
        try? context.save()
        reloadPlanningItems()
    }

    private func deletePlanningItem(id: UUID, entityName: String) {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        guard let object = try? context.fetch(request).first else { return }
        object.setValue(Date(), forKey: "deletedAt")
        object.setValue(Date(), forKey: "updatedAt")
        try? context.save()
        reloadPlanningItems()
    }

    private func saveAndReload() {
        do {
            try context.save()
            reloadShoppingItems()
        } catch {
            context.rollback()
        }
    }

    private func nextDate(after date: Date, recurrence: SimpleRecurrence) -> Date? {
        let calendar = Calendar.current
        return switch recurrence {
        case .none: nil
        case .daily: calendar.date(byAdding: .day, value: 1, to: date)
        case .weekly: calendar.date(byAdding: .weekOfYear, value: 1, to: date)
        case .biweekly: calendar.date(byAdding: .weekOfYear, value: 2, to: date)
        case .monthly: calendar.date(byAdding: .month, value: 1, to: date)
        case .yearly: calendar.date(byAdding: .year, value: 1, to: date)
        }
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
