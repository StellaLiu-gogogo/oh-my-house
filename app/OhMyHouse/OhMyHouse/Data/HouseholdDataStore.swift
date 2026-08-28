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

    private func saveAndReload() {
        do {
            try context.save()
            reloadShoppingItems()
        } catch {
            context.rollback()
        }
    }
}
