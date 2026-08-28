import Foundation

struct MealPlanItem: Codable, Identifiable {
    let id: UUID
    var title: String
    var date: Date
    var slot: String
    var participantIDs: [UUID]
    var servings: Int
}

struct ChoreItem: Codable, Identifiable {
    let id: UUID
    var title: String
    var dueDate: Date?
    var assignmentMode: String
    var assigneeIDs: [UUID]
    var recurrence: String
    var isCompleted: Bool
    var completedAt: Date?
}

struct HouseholdEventItem: Codable, Identifiable {
    let id: UUID
    var title: String
    var startDate: Date
    var endDate: Date?
    var isAllDay: Bool
    var recurrence: String
    var reminderDate: Date?
    var reminderText: String?
}

enum ChoreAssignmentMode: String, CaseIterable, Identifiable {
    case unassigned
    case one
    case shared
    case rotating

    var id: Self { self }
}

enum SimpleRecurrence: String, CaseIterable, Identifiable {
    case none
    case daily
    case weekly
    case biweekly
    case monthly
    case yearly

    var id: Self { self }
}

struct WishlistItem: Codable, Identifiable {
    let id: UUID
    var title: String
    var status: String
    var inventoryItemID: UUID?
}

struct InventoryItem: Codable, Identifiable {
    let id: UUID
    var title: String
    var room: String?
    var sourceWishlistID: UUID?
}

struct MaintenanceItem: Codable, Identifiable {
    let id: UUID
    var title: String
    var nextDate: Date
    var inventoryItemID: UUID?
    var recurrence: String
    var assigneeIDs: [UUID]
    var completionHistory: [Date]
    var isCompleted: Bool
}
