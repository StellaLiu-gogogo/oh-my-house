import SwiftUI

struct PlanView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section(store.text("本周", "This Week")) {
                    NavigationLink {
                        ModulePlaceholderView(title: store.text("餐食计划", "Meal Plan"))
                    } label: {
                        DomainSummaryCard(
                            title: store.text("餐食", "Meals"),
                            detail: store.text("安排本周吃什么", "Plan what to eat this week"),
                            symbol: "fork.knife"
                        )
                    }
                    NavigationLink {
                        ModulePlaceholderView(title: store.text("家务", "Chores"))
                    } label: {
                        DomainSummaryCard(
                            title: store.text("家务", "Chores"),
                            detail: store.text("查看今天、本周和全部家务", "View today, this week, and all chores"),
                            symbol: "checkmark.circle"
                        )
                    }
                    NavigationLink {
                        ModulePlaceholderView(title: store.text("家庭事件", "Household Events"))
                    } label: {
                        DomainSummaryCard(
                            title: store.text("家庭事件", "Events"),
                            detail: store.text("查看接下来的家庭日期", "See upcoming household dates"),
                            symbol: "calendar.badge.clock"
                        )
                    }
                }
                Section {
                    NavigationLink(store.text("打开日历", "Open Calendar")) {
                        ModulePlaceholderView(title: store.text("日历", "Calendar"))
                    }
                }
            }
            .navigationTitle(store.text("计划", "Plan"))
            .appScreenTools(showsMemberSheet: $showsMemberSheet)
        }
    }
}

struct ModulePlaceholderView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    let title: String
    @State private var showsMemberSheet = false

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: "hammer",
            description: Text(store.text("这个模块将在下一阶段完成。", "This module will be completed next."))
        )
        .navigationTitle(title)
        .appScreenTools(showsMemberSheet: $showsMemberSheet)
    }
}

