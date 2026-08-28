import SwiftUI

struct AppScreenTools: ViewModifier {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Binding var showsMemberSheet: Bool

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        store.toggleDisplayLanguage()
                    } label: {
                        Text("文/A")
                    }
                    .accessibilityLabel(store.text("切换显示语言", "Switch display language"))

                    Button {
                        showsMemberSheet = true
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                    }
                    .accessibilityLabel(store.text("当前使用者", "Current member"))
                }
            }
            .sheet(isPresented: $showsMemberSheet) {
                NavigationStack {
                    Form {
                        Section(store.text("当前使用者", "Current member")) {
                            Label(store.currentMemberName, systemImage: "person.crop.circle.fill")
                        }
                        Section {
                            Text(store.text(
                                "成员头像、颜色和切换功能将在成员模块中完成。",
                                "Member photos, colors, and switching will be completed in the member module."
                            ))
                            .foregroundStyle(.secondary)
                        }
                    }
                    .navigationTitle(store.text("家庭成员", "Household Members"))
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(store.text("完成", "Done")) {
                                showsMemberSheet = false
                            }
                        }
                    }
                }
            }
    }
}

extension View {
    func appScreenTools(showsMemberSheet: Binding<Bool>) -> some View {
        modifier(AppScreenTools(showsMemberSheet: showsMemberSheet))
    }
}

struct DomainSummaryCard: View {
    let title: String
    let detail: String
    let symbol: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title2)
                .frame(width: 34)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
    }
}

