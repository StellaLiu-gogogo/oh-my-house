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
                        MemberAvatarView(member: store.currentMember, size: 28)
                    }
                    .accessibilityLabel(store.text("当前使用者", "Current member"))
                }
            }
            .sheet(isPresented: $showsMemberSheet) {
                MemberManagementView(isPresented: $showsMemberSheet)
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
