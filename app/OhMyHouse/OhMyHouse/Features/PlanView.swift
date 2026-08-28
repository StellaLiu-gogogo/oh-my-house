import SwiftUI

struct PlanView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false

    private var weekInterval: DateInterval {
        Calendar.current.dateInterval(of: .weekOfYear, for: Date())!
    }

    private var mealsThisWeek: Int {
        store.meals.filter { weekInterval.contains($0.date) }.count
    }

    private var choresThisWeek: Int {
        store.chores.filter { item in
            !item.isCompleted && (item.dueDate.map(weekInterval.contains) ?? false)
        }.count
    }

    private var eventsThisWeek: Int {
        store.events.filter { weekInterval.contains($0.startDate) }.count
    }

    var body: some View {
        NavigationStack {
            List {
                Section(store.text("本周", "This Week")) {
                    NavigationLink {
                        MealPlanView()
                    } label: {
                        DomainSummaryCard(
                            title: store.text("餐食", "Meals"),
                            detail: store.text("已安排 \(mealsThisWeek) 餐", "\(mealsThisWeek) meals planned"),
                            symbol: "fork.knife"
                        )
                    }
                    NavigationLink {
                        ChoreListView()
                    } label: {
                        DomainSummaryCard(
                            title: store.text("家务", "Chores"),
                            detail: store.text("本周还有 \(choresThisWeek) 项", "\(choresThisWeek) remaining this week"),
                            symbol: "checkmark.circle"
                        )
                    }
                    NavigationLink {
                        EventListView()
                    } label: {
                        DomainSummaryCard(
                            title: store.text("家庭事件", "Events"),
                            detail: store.text("本周有 \(eventsThisWeek) 个", "\(eventsThisWeek) this week"),
                            symbol: "calendar.badge.clock"
                        )
                    }
                }
                Section {
                    NavigationLink(store.text("打开日历", "Open Calendar")) {
                        HouseholdCalendarView()
                    }
                }
            }
            .navigationTitle(store.text("计划", "Plan"))
            .appScreenTools(showsMemberSheet: $showsMemberSheet)
        }
    }
}

struct MealPlanView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false
    @State private var showsAdd = false

    private var weekDays: [Date] {
        let interval = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!
        return (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: interval.start) }
    }

    var body: some View {
        List {
            ForEach(weekDays, id: \.self) { day in
                Section {
                    let meals = store.meals.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
                    if meals.isEmpty {
                        Text(store.text("尚未安排", "Not planned"))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(meals) { meal in
                            HStack {
                                Text(meal.slot == "lunch" ? store.text("午餐", "Lunch") : store.text("晚餐", "Dinner"))
                                    .foregroundStyle(.secondary)
                                Text(meal.title)
                                Spacer()
                                Text(store.text("\(meal.servings) 份", "\(meal.servings) servings"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text(day, format: .dateTime.weekday(.wide).month().day())
                }
            }
        }
        .navigationTitle(store.text("一周餐食", "Weekly Meals"))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showsAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .appScreenTools(showsMemberSheet: $showsMemberSheet)
        .sheet(isPresented: $showsAdd) { AddMealView(defaultDate: Date()) }
    }
}

struct ChoreListView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false
    @State private var showsAdd = false

    var body: some View {
        List {
            Section(store.text("待完成", "To Do")) {
                if store.chores.filter({ !$0.isCompleted }).isEmpty {
                    Text(store.text("还没有家务", "No chores yet"))
                        .foregroundStyle(.secondary)
                }
                ForEach(store.chores.filter { !$0.isCompleted }) { chore in
                    ChoreRow(chore: chore)
                }
            }
            if store.chores.contains(where: \.isCompleted) {
                Section(store.text("已完成", "Completed")) {
                    ForEach(store.chores.filter(\.isCompleted)) { chore in
                        ChoreRow(chore: chore)
                    }
                }
            }
        }
        .navigationTitle(store.text("家务", "Chores"))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showsAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .appScreenTools(showsMemberSheet: $showsMemberSheet)
        .sheet(isPresented: $showsAdd) { AddChoreView() }
    }
}

private struct ChoreRow: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    let chore: ChoreItem

    var body: some View {
        Button { store.toggleChore(chore) } label: {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: chore.isCompleted ? "checkmark.circle.fill" : "circle")
                VStack(alignment: .leading, spacing: 3) {
                    Text(chore.title)
                    HStack {
                        if let dueDate = chore.dueDate {
                            Text(dueDate, format: .dateTime.month().day())
                        }
                        let names = store.members
                            .filter { chore.assigneeIDs.contains($0.id) }
                            .map(\.name).joined(separator: ", ")
                        Text(names.isEmpty ? store.text("未分配", "Unassigned") : names)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct EventListView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false
    @State private var showsAdd = false

    var body: some View {
        List {
            if store.events.isEmpty {
                ContentUnavailableView(
                    store.text("还没有家庭事件", "No household events"),
                    systemImage: "calendar.badge.plus"
                )
            } else {
                ForEach(store.events) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                        Text(event.startDate, format: event.isAllDay
                             ? .dateTime.year().month().day()
                             : .dateTime.year().month().day().hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(store.text("家庭事件", "Household Events"))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showsAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .appScreenTools(showsMemberSheet: $showsMemberSheet)
        .sheet(isPresented: $showsAdd) { AddEventView() }
    }
}

struct HouseholdCalendarView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var selectedDate = Date()
    @State private var showsMemberSheet = false

    var body: some View {
        List {
            DatePicker(
                store.text("选择日期", "Select date"),
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)

            let meals = store.meals.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            let chores = store.chores.filter { $0.dueDate.map { Calendar.current.isDate($0, inSameDayAs: selectedDate) } ?? false }
            let events = store.events.filter { Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate) }

            if !meals.isEmpty {
                Section(store.text("餐食", "Meals")) { ForEach(meals) { Text($0.title) } }
            }
            if !chores.isEmpty {
                Section(store.text("家务", "Chores")) { ForEach(chores) { ChoreRow(chore: $0) } }
            }
            if !events.isEmpty {
                Section(store.text("家庭事件", "Events")) { ForEach(events) { Text($0.title) } }
            }
        }
        .navigationTitle(store.text("日历", "Calendar"))
        .appScreenTools(showsMemberSheet: $showsMemberSheet)
    }
}

struct AddMealView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var date: Date
    @State private var slot = "dinner"
    @State private var participantIDs = Set<UUID>()
    @State private var servings = 1

    init(defaultDate: Date) { _date = State(initialValue: defaultDate) }

    var body: some View {
        NavigationStack {
            Form {
                TextField(store.text("吃什么", "Meal name"), text: $title)
                DatePicker(store.text("日期", "Date"), selection: $date, displayedComponents: .date)
                Picker(store.text("餐次", "Meal"), selection: $slot) {
                    Text(store.text("午餐", "Lunch")).tag("lunch")
                    Text(store.text("晚餐", "Dinner")).tag("dinner")
                }
                Section(store.text("一起吃饭的人", "People eating")) {
                    ForEach(store.members) { member in
                        Button { toggle(member.id, in: &participantIDs) } label: {
                            SelectableMemberRow(member: member, selected: participantIDs.contains(member.id))
                        }
                        .buttonStyle(.plain)
                    }
                }
                Stepper(store.text("准备 \(servings) 份", "Prepare \(servings) servings"), value: $servings, in: 1...30)
            }
            .navigationTitle(store.text("添加餐食", "Add Meal"))
            .formScreenToolbar(canSave: !title.trimmingCharacters(in: .whitespaces).isEmpty) {
                store.addMeal(title: title, date: date, slot: slot, participantIDs: Array(participantIDs), servings: servings)
                dismiss()
            }
            .onAppear {
                if participantIDs.isEmpty {
                    participantIDs = Set(store.members.map(\.id))
                    servings = max(store.members.count, 1)
                }
            }
        }
    }
}

struct AddChoreView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var mode: ChoreAssignmentMode = .unassigned
    @State private var assigneeIDs = Set<UUID>()
    @State private var recurrence: SimpleRecurrence = .none

    var body: some View {
        NavigationStack {
            Form {
                TextField(store.text("家务名称", "Chore title"), text: $title)
                Toggle(store.text("设置日期", "Set date"), isOn: $hasDueDate)
                if hasDueDate {
                    DatePicker(store.text("日期", "Date"), selection: $dueDate, displayedComponents: .date)
                }
                Picker(store.text("负责人", "Assignment"), selection: $mode) {
                    ForEach(ChoreAssignmentMode.allCases) { item in
                        Text(assignmentLabel(item)).tag(item)
                    }
                }
                if mode != .unassigned {
                    Section(store.text("选择成员", "Choose members")) {
                        ForEach(store.members) { member in
                            Button { selectAssignee(member.id) } label: {
                                SelectableMemberRow(member: member, selected: assigneeIDs.contains(member.id))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                Picker(store.text("重复", "Repeat"), selection: $recurrence) {
                    ForEach(SimpleRecurrence.allCases.filter { $0 != .yearly }) { item in
                        Text(recurrenceLabel(item)).tag(item)
                    }
                }
            }
            .navigationTitle(store.text("添加家务", "Add Chore"))
            .formScreenToolbar(canSave: !title.trimmingCharacters(in: .whitespaces).isEmpty) {
                let finalMode: ChoreAssignmentMode = assigneeIDs.isEmpty ? .unassigned : mode
                store.addChore(
                    title: title, dueDate: hasDueDate ? dueDate : nil,
                    assignmentMode: finalMode, assigneeIDs: Array(assigneeIDs), recurrence: recurrence
                )
                dismiss()
            }
        }
    }

    private func selectAssignee(_ id: UUID) {
        if mode == .one { assigneeIDs = [id] } else { toggle(id, in: &assigneeIDs) }
    }

    private func assignmentLabel(_ item: ChoreAssignmentMode) -> String {
        switch item {
        case .unassigned: store.text("暂时无人", "Unassigned")
        case .one: store.text("一个人", "One person")
        case .shared: store.text("多人共同", "Multiple people")
        case .rotating: store.text("轮流", "Rotating")
        }
    }

    private func recurrenceLabel(_ item: SimpleRecurrence) -> String {
        recurrenceText(item, store: store)
    }
}

struct AddEventView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var startDate = Date()
    @State private var isAllDay = true
    @State private var hasEnd = false
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var recurrence: SimpleRecurrence = .none
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    @State private var reminderText = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField(store.text("事件名称", "Event name"), text: $title)
                Toggle(store.text("全天", "All day"), isOn: $isAllDay)
                DatePicker(
                    store.text("开始", "Starts"), selection: $startDate,
                    displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                )
                Toggle(store.text("设置结束时间", "Set end time"), isOn: $hasEnd)
                if hasEnd {
                    DatePicker(
                        store.text("结束", "Ends"), selection: $endDate,
                        in: startDate...,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                }
                Picker(store.text("重复", "Repeat"), selection: $recurrence) {
                    ForEach([SimpleRecurrence.none, .weekly, .biweekly, .monthly, .yearly]) { item in
                        Text(recurrenceText(item, store: store)).tag(item)
                    }
                }
                Section(store.text("提醒", "Reminder")) {
                    Toggle(store.text("添加提醒", "Add reminder"), isOn: $hasReminder)
                    if hasReminder {
                        DatePicker(store.text("提醒时间", "Reminder time"), selection: $reminderDate)
                        TextField(store.text("提醒文字（可选）", "Reminder text (optional)"), text: $reminderText)
                    }
                }
            }
            .navigationTitle(store.text("添加家庭事件", "Add Household Event"))
            .formScreenToolbar(canSave: !title.trimmingCharacters(in: .whitespaces).isEmpty) {
                store.addEvent(
                    title: title, startDate: startDate, endDate: hasEnd ? endDate : nil,
                    isAllDay: isAllDay, recurrence: recurrence,
                    reminderDate: hasReminder ? reminderDate : nil,
                    reminderText: reminderText.isEmpty ? nil : reminderText
                )
                dismiss()
            }
        }
    }
}

private struct SelectableMemberRow: View {
    let member: MemberEntity
    let selected: Bool

    var body: some View {
        HStack {
            MemberAvatarView(member: member, size: 30)
            Text(member.name)
            Spacer()
            if selected { Image(systemName: "checkmark") }
        }
        .contentShape(Rectangle())
    }
}

private struct FormScreenToolbar: ViewModifier {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    let canSave: Bool
    let save: () -> Void

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(store.text("取消", "Cancel")) { dismiss() }
            }
            ToolbarItem(placement: .automatic) {
                Button(store.displayLanguage == .chinese ? "文" : "A") {
                    store.toggleDisplayLanguage()
                }
                .accessibilityLabel(store.text("切换为英文", "Switch to Chinese"))
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(store.text("保存", "Save"), action: save).disabled(!canSave)
            }
        }
    }
}

private extension View {
    func formScreenToolbar(canSave: Bool, save: @escaping () -> Void) -> some View {
        modifier(FormScreenToolbar(canSave: canSave, save: save))
    }
}

private func toggle(_ id: UUID, in selection: inout Set<UUID>) {
    if selection.contains(id) { selection.remove(id) } else { selection.insert(id) }
}

@MainActor
private func recurrenceText(_ value: SimpleRecurrence, store: LocalHouseholdDataStore) -> String {
    switch value {
    case .none: store.text("不重复", "Never")
    case .daily: store.text("每天", "Daily")
    case .weekly: store.text("每周", "Weekly")
    case .biweekly: store.text("每两周", "Every two weeks")
    case .monthly: store.text("每月", "Monthly")
    case .yearly: store.text("每年", "Yearly")
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
