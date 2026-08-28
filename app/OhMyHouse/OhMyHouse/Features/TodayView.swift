import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false
    @State private var showsAddMeal = false
    @State private var recentlyCompletedChore: ChoreItem?
    @State private var recentlyCompletedMaintenance: MaintenanceItem?

    private var todayMeals: [MealPlanItem] {
        store.meals.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var todayChores: [ChoreItem] {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return store.chores.filter { item in
            guard let dueDate = item.dueDate else { return false }
            return !item.isCompleted && dueDate < end
        }
    }

    private var todayEvents: [HouseholdEventItem] {
        store.events.filter {
            eventOccurs($0, on: Date()) ||
            ($0.reminderDate.map(Calendar.current.isDateInToday) ?? false)
        }
    }

    private var todayMaintenance: [MaintenanceItem] {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return store.maintenanceItems.filter { !$0.isCompleted && $0.nextDate < end }
    }

    var body: some View {
        NavigationStack {
            List {
                Section(store.text("餐食", "Meals")) {
                    if todayMeals.isEmpty {
                        Button {
                            showsAddMeal = true
                        } label: {
                            Label(
                                store.text("今天还没有安排餐食", "No meals planned for today"),
                                systemImage: "plus.circle"
                            )
                        }
                    } else {
                        ForEach(todayMeals.prefix(3)) { meal in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(meal.title)
                                Text(meal.slot == "lunch" ? store.text("午餐", "Lunch") : store.text("晚餐", "Dinner"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Button {
                            showsAddMeal = true
                        } label: {
                            Label(store.text("再添加一餐", "Add another meal"), systemImage: "plus.circle")
                        }
                    }
                }

                if !todayChores.isEmpty {
                    Section(store.text("家务", "Chores")) {
                        ForEach(todayChores.prefix(3)) { chore in
                            Button {
                                recentlyCompletedChore = chore
                                store.toggleChore(chore)
                            } label: {
                                Label(chore.title, systemImage: "circle")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !todayMaintenance.isEmpty {
                    Section(store.text("家庭维护", "Home Maintenance")) {
                        ForEach(todayMaintenance.prefix(3)) { item in
                            Button {
                                recentlyCompletedMaintenance = item
                                store.completeMaintenance(item)
                            } label: {
                                Label(item.title, systemImage: "circle")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !todayEvents.isEmpty {
                    Section(store.text("家庭事件", "Events")) {
                        ForEach(todayEvents.prefix(3)) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                if !event.isAllDay {
                                    Text(event.startDate, style: .time)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                if let recentlyCompletedChore {
                    Section {
                        HStack {
                            Text(store.text("已完成：", "Completed: ") + recentlyCompletedChore.title)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button(store.text("撤销", "Undo")) {
                                store.toggleChore(recentlyCompletedChore)
                                self.recentlyCompletedChore = nil
                            }
                        }
                    }
                }

                if let recentlyCompletedMaintenance {
                    Section {
                        HStack {
                            Text(store.text("已完成：", "Completed: ") + recentlyCompletedMaintenance.title)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button(store.text("撤销", "Undo")) {
                                store.restoreMaintenance(recentlyCompletedMaintenance)
                                self.recentlyCompletedMaintenance = nil
                            }
                        }
                    }
                }
            }
            .navigationTitle(store.text("今天", "Today"))
            .appScreenTools(showsMemberSheet: $showsMemberSheet)
            .sheet(isPresented: $showsAddMeal) {
                AddMealView(defaultDate: Date())
            }
        }
    }
}
