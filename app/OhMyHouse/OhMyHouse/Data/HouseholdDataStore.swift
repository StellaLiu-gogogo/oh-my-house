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
    func addShoppingItem(title: String, source: ShoppingSource)
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
    @Published private(set) var chores: [ChoreItem] = []
    @Published private(set) var events: [HouseholdEventItem] = []

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

    func addShoppingItem(title: String, source: ShoppingSource) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let item = ShoppingItemEntity(context: context)
        item.id = UUID()
        item.householdID = activeHouseholdID
        item.title = trimmed
        item.sourceKind = source.rawValue
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

    func addMeal(
        title: String,
        date: Date,
        slot: String,
        participantIDs: [UUID],
        servings: Int
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = MealPlanItem(
            id: UUID(), title: trimmed, date: date, slot: slot,
            participantIDs: participantIDs, servings: servings
        )
        savePlanningItem(item, title: trimmed, entityName: "MealEntity")
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

    func toggleChore(_ item: ChoreItem) {
        var changed = item
        changed.isCompleted.toggle()
        changed.completedAt = changed.isCompleted ? Date() : nil
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
        chores = fetchPlanningItems(entityName: "ChoreEntity", as: ChoreItem.self)
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        events = fetchPlanningItems(entityName: "HouseholdEventEntity", as: HouseholdEventItem.self)
            .sorted { $0.startDate < $1.startDate }
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

    private func saveAndReload() {
        do {
            try context.save()
            reloadShoppingItems()
        } catch {
            context.rollback()
        }
    }
}
