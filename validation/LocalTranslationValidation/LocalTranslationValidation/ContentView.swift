import CoreData
import SwiftUI
import Translation

struct ContentView: View {
    private enum TranslationDirection: String, CaseIterable, Identifiable {
        case chineseToEnglish = "中文 → English"
        case englishToChinese = "English → 中文"

        var id: Self { self }

        var sourceLanguage: Locale.Language {
            switch self {
            case .chineseToEnglish:
                Locale.Language(identifier: "zh-Hans")
            case .englishToChinese:
                Locale.Language(identifier: "en")
            }
        }

        var targetLanguage: Locale.Language {
            switch self {
            case .chineseToEnglish:
                Locale.Language(identifier: "en")
            case .englishToChinese:
                Locale.Language(identifier: "zh-Hans")
            }
        }
    }

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: false)],
        animation: .default
    ) private var savedItems: FetchedResults<ValidationItem>

    @State private var sourceText = "买牛奶"
    @State private var translatedText = ""
    @State private var direction = TranslationDirection.chineseToEnglish
    @State private var translationConfiguration: TranslationSession.Configuration?
    @State private var statusMessage = "尚未开始翻译"
    @State private var localStoreStatus = "正在检查…"

    var body: some View {
        NavigationStack {
            Form {
                Section("说明") {
                    Label("这是技术验证，不是正式 App", systemImage: "wrench.and.screwdriver")
                    Text("只测试本地保存与中英文翻译，不连接 iCloud。")
                        .foregroundStyle(.secondary)
                }

                Section("本地保存自动检查") {
                    LabeledContent("结果", value: localStoreStatus)
                }

                Section("翻译测试") {
                    Picker("方向", selection: $direction) {
                        ForEach(TranslationDirection.allCases) { direction in
                            Text(direction.rawValue).tag(direction)
                        }
                    }

                    TextField("输入虚构的测试内容", text: $sourceText, axis: .vertical)
                        .lineLimit(2...5)

                    Button("开始翻译", action: startTranslation)
                        .disabled(sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    LabeledContent("状态", value: statusMessage)

                    if !translatedText.isEmpty {
                        LabeledContent("翻译结果", value: translatedText)
                        Button("保存这条测试内容", action: saveCurrentItem)
                    }
                }

                Section("已保存在这台设备上（\(savedItems.count)）") {
                    if savedItems.isEmpty {
                        Text("还没有测试内容")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(savedItems) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.originalText)
                                if let translation = item.translatedText, !translation.isEmpty {
                                    Text(translation)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .navigationTitle("技术验证")
        }
        .translationTask(translationConfiguration) { session in
            await translate(using: session)
        }
        .task {
            runLocalStoreCheck()
        }
    }

    private func startTranslation() {
        translatedText = ""
        statusMessage = "正在准备翻译…"

        let newConfiguration = TranslationSession.Configuration(
            source: direction.sourceLanguage,
            target: direction.targetLanguage
        )

        if translationConfiguration == newConfiguration {
            translationConfiguration?.invalidate()
        } else {
            translationConfiguration = newConfiguration
        }
    }

    private func translate(using session: TranslationSession) async {
        do {
            let response = try await session.translate(sourceText)
            await MainActor.run {
                translatedText = response.targetText
                statusMessage = "翻译成功；原文仍然保留"
            }
        } catch {
            await MainActor.run {
                translatedText = ""
                statusMessage = "翻译暂不可用；原文没有丢失"
            }
        }
    }

    private func saveCurrentItem() {
        let item = ValidationItem(context: viewContext)
        item.id = UUID()
        item.originalText = sourceText
        item.translatedText = translatedText
        item.createdAt = Date()
        saveContext()
    }

    private func deleteItems(at offsets: IndexSet) {
        for offset in offsets {
            viewContext.delete(savedItems[offset])
        }
        saveContext()
    }

    private func saveContext() {
        guard viewContext.hasChanges else { return }

        do {
            try viewContext.save()
            statusMessage = "已保存到这台设备"
        } catch {
            statusMessage = "保存失败，请稍后重试"
        }
    }

    private func runLocalStoreCheck() {
        do {
            localStoreStatus = try PersistenceController.runRoundTripCheck()
                ? "通过：关闭后重新读取成功"
                : "未通过"
        } catch {
            localStoreStatus = "未通过：无法重新读取"
        }
    }
}
