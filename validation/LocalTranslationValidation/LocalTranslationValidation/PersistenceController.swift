import CoreData

final class ValidationItem: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var originalText: String
    @NSManaged var translatedText: String?
    @NSManaged var createdAt: Date
}

@MainActor
final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(
            name: "ValidationModel",
            managedObjectModel: Self.makeModel()
        )

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("无法打开本地测试数据库：\(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "ValidationItem"
        entity.managedObjectClassName = NSStringFromClass(ValidationItem.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let originalText = NSAttributeDescription()
        originalText.name = "originalText"
        originalText.attributeType = .stringAttributeType
        originalText.isOptional = false

        let translatedText = NSAttributeDescription()
        translatedText.name = "translatedText"
        translatedText.attributeType = .stringAttributeType
        translatedText.isOptional = true

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        entity.properties = [id, originalText, translatedText, createdAt]
        model.entities = [entity]
        return model
    }

    static func runRoundTripCheck() throws -> Bool {
        let storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("omh-local-store-check-\(UUID().uuidString).sqlite")
        defer {
            try? FileManager.default.removeItem(at: storeURL)
            try? FileManager.default.removeItem(atPath: storeURL.path + "-shm")
            try? FileManager.default.removeItem(atPath: storeURL.path + "-wal")
        }

        let firstCoordinator = NSPersistentStoreCoordinator(managedObjectModel: makeModel())
        let firstStore = try firstCoordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL
        )
        let firstContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        firstContext.persistentStoreCoordinator = firstCoordinator

        let item = ValidationItem(context: firstContext)
        item.id = UUID()
        item.originalText = "本地保存测试"
        item.translatedText = "Local persistence test"
        item.createdAt = Date()
        try firstContext.save()
        try firstCoordinator.remove(firstStore)

        let secondCoordinator = NSPersistentStoreCoordinator(managedObjectModel: makeModel())
        _ = try secondCoordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL
        )
        let secondContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        secondContext.persistentStoreCoordinator = secondCoordinator

        let request = NSFetchRequest<ValidationItem>(entityName: "ValidationItem")
        let reopenedItems = try secondContext.fetch(request)
        return reopenedItems.count == 1 && reopenedItems.first?.originalText == "本地保存测试"
    }
}
