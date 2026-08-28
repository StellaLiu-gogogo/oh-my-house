import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section(store.text("餐食", "Meals")) {
                    Text(store.text("今天还没有安排餐食", "No meals planned for today"))
                        .foregroundStyle(.secondary)
                }
                Section(store.text("家务", "Chores")) {
                    Text(store.text("今天没有待完成家务", "No chores due today"))
                        .foregroundStyle(.secondary)
                }
                Section(store.text("家庭维护", "Home")) {
                    Text(store.text("今天没有到期维护", "No maintenance due today"))
                        .foregroundStyle(.secondary)
                }
                Section(store.text("家庭事件", "Events")) {
                    Text(store.text("今天没有家庭事件", "No household events today"))
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(store.text("今天", "Today"))
            .appScreenTools(showsMemberSheet: $showsMemberSheet)
        }
    }
}

