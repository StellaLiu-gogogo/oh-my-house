import SwiftUI

@main
struct OhMyHouseApp: App {
    @StateObject private var store: LocalHouseholdDataStore

    init() {
        let persistence = PersistenceController.shared
        _store = StateObject(
            wrappedValue: LocalHouseholdDataStore(context: persistence.container.viewContext)
        )
    }

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environmentObject(store)
        }
    }
}

