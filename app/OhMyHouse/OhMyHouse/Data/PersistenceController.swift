import CoreData

class HouseholdEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var createdAt: Date
    @NSManaged var updatedAt: Date
}

class MemberEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var householdID: UUID
    @NSManaged var name: String
    @NSManaged var colorHex: String
    @NSManaged var preferredLanguage: String
    @NSManaged var avatarData: Data?
    @NSManaged var createdAt: Date
    @NSManaged var updatedAt: Date
}

class ShoppingItemEntity: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var householdID: UUID
    @NSManaged var title: String
    @NSManaged var translatedTitle: String?
    @NSManaged var sourceKind: String
    @NSManaged var sourceID: UUID?
    @NSManaged var isPurchased: Bool
    @NSManaged var purchasedAt: Date?
    @NSManaged var createdAt: Date
    @NSManaged var updatedAt: Date
    @NSManaged var deletedAt: Date?
}

@MainActor
final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(
            name: "OhMyHouseModel",
            managedObjectModel: Self.makeModel()
        )
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("无法打开 Oh My House 本地数据库：\(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let household = entity(
            name: "HouseholdEntity",
            classType: HouseholdEntity.self,
            properties: commonIdentityProperties(includeHouseholdID: false) + [
                attribute("name", .stringAttributeType, defaultValue: "My Home")
            ]
        )

        let member = entity(
            name: "MemberEntity",
            classType: MemberEntity.self,
            properties: commonIdentityProperties() + [
                attribute("name", .stringAttributeType, defaultValue: "Me"),
                attribute("colorHex", .stringAttributeType, defaultValue: "4A90E2"),
                attribute("preferredLanguage", .stringAttributeType, defaultValue: "zh-Hans"),
                attribute("avatarData", .binaryDataAttributeType, optional: true)
            ]
        )

        let shopping = entity(
            name: "ShoppingItemEntity",
            classType: ShoppingItemEntity.self,
            properties: commonIdentityProperties(includeDeletedAt: true) + [
                attribute("title", .stringAttributeType, defaultValue: ""),
                attribute("translatedTitle", .stringAttributeType, optional: true),
                attribute("sourceKind", .stringAttributeType, defaultValue: "supplies"),
                attribute("sourceID", .UUIDAttributeType, optional: true),
                attribute("isPurchased", .booleanAttributeType, defaultValue: false),
                attribute("purchasedAt", .dateAttributeType, optional: true)
            ]
        )

        let reservedNames = [
            "HomeLocationEntity", "MealEntity", "RecipeEntity", "ChoreEntity",
            "HouseholdEventEntity", "WishlistItemEntity", "InventoryItemEntity",
            "MaintenanceEntity", "TranslationEntity"
        ]
        let reservedEntities = reservedNames.map { name in
            entity(
                name: name,
                className: "NSManagedObject",
                properties: commonIdentityProperties(includeDeletedAt: true) + [
                    attribute("title", .stringAttributeType, defaultValue: ""),
                    attribute("payload", .binaryDataAttributeType, optional: true)
                ]
            )
        }

        model.entities = [household, member, shopping] + reservedEntities
        return model
    }

    private static func commonIdentityProperties(
        includeHouseholdID: Bool = true,
        includeDeletedAt: Bool = false
    ) -> [NSPropertyDescription] {
        var properties: [NSPropertyDescription] = [
            attribute("id", .UUIDAttributeType),
            attribute("createdAt", .dateAttributeType),
            attribute("updatedAt", .dateAttributeType)
        ]
        if includeHouseholdID {
            properties.append(attribute("householdID", .UUIDAttributeType))
        }
        if includeDeletedAt {
            properties.append(attribute("deletedAt", .dateAttributeType, optional: true))
        }
        return properties
    }

    private static func entity(
        name: String,
        classType: NSManagedObject.Type,
        properties: [NSPropertyDescription]
    ) -> NSEntityDescription {
        entity(name: name, className: NSStringFromClass(classType), properties: properties)
    }

    private static func entity(
        name: String,
        className: String,
        properties: [NSPropertyDescription]
    ) -> NSEntityDescription {
        let description = NSEntityDescription()
        description.name = name
        description.managedObjectClassName = className
        description.properties = properties
        return description
    }

    private static func attribute(
        _ name: String,
        _ type: NSAttributeType,
        optional: Bool = false,
        defaultValue: Any? = nil
    ) -> NSAttributeDescription {
        let description = NSAttributeDescription()
        description.name = name
        description.attributeType = type
        description.isOptional = optional
        description.defaultValue = defaultValue
        return description
    }
}

