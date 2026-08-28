import SwiftUI
import Translation

struct TranslatedUserText: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    let original: String
    @State private var translated: String?
    @State private var configuration: TranslationSession.Configuration?

    var body: some View {
        Text(translated ?? original)
            .translationTask(configuration) { session in
                await translate(using: session)
            }
            .task(id: original + "|" + store.displayLanguage.rawValue) {
                prepareTranslation()
            }
    }

    private func prepareTranslation() {
        translated = nil
        let targetIsEnglish = store.displayLanguage == .english
        guard needsTranslation(original, targetIsEnglish: targetIsEnglish) else {
            configuration = nil
            return
        }

        let source = Locale.Language(identifier: targetIsEnglish ? "zh-Hans" : "en")
        let target = Locale.Language(identifier: targetIsEnglish ? "en" : "zh-Hans")
        let newConfiguration = TranslationSession.Configuration(source: source, target: target)
        if configuration == newConfiguration {
            configuration?.invalidate()
        } else {
            configuration = newConfiguration
        }
    }

    private func translate(using session: TranslationSession) async {
        do {
            try await session.prepareTranslation()
            let result = try await session.translate(original).targetText
            await MainActor.run { translated = result }
        } catch {
            await MainActor.run { translated = nil }
        }
    }

    private func needsTranslation(_ text: String, targetIsEnglish: Bool) -> Bool {
        if targetIsEnglish {
            return text.unicodeScalars.contains {
                (0x3400...0x9FFF).contains(Int($0.value))
            }
        }
        return text.range(of: "[A-Za-z]", options: .regularExpression) != nil
    }
}

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
