import Foundation

struct MealPlanItem: Codable, Identifiable {
    let id: UUID
    var title: String
    var date: Date
    var slot: String
    var participantIDs: [UUID]
    var servings: Int
    var recipeID: UUID? = nil
}

struct RecipeIngredient: Codable, Identifiable {
    let id: UUID
    var name: String
    var quantity: Double?
    var unit: String
}

struct RecipeItem: Codable, Identifiable {
    let id: UUID
    var title: String
    var baseServings: Int
    var ingredients: [RecipeIngredient]
    var instructions: String
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
    var generatedNextID: UUID? = nil
    var rotationIndex: Int? = nil
}

func eventOccurs(_ event: HouseholdEventItem, on date: Date, calendar: Calendar = .current) -> Bool {
    let startDay = calendar.startOfDay(for: event.startDate)
    let targetDay = calendar.startOfDay(for: date)
    guard targetDay >= startDay else { return false }
    let dayDistance = calendar.dateComponents([.day], from: startDay, to: targetDay).day ?? 0
    switch SimpleRecurrence(rawValue: event.recurrence) ?? .none {
    case .none: return calendar.isDate(startDay, inSameDayAs: targetDay)
    case .daily: return true
    case .weekly: return dayDistance.isMultiple(of: 7)
    case .biweekly: return dayDistance.isMultiple(of: 14)
    case .monthly:
        return calendar.component(.day, from: startDay) == calendar.component(.day, from: targetDay)
    case .yearly:
        return calendar.component(.month, from: startDay) == calendar.component(.month, from: targetDay)
            && calendar.component(.day, from: startDay) == calendar.component(.day, from: targetDay)
    }
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
