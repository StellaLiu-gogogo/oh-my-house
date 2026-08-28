import PhotosUI
import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct RecipeLibraryView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false
    @State private var showsAdd = false
    @State private var editingRecipe: RecipeItem?

    var body: some View {
        List {
            if store.recipes.isEmpty {
                ContentUnavailableView(
                    store.text("还没有食谱", "No recipes yet"),
                    systemImage: "book.closed",
                    description: Text(store.text("先建立一份常吃的食谱。", "Add a recipe your household often eats."))
                )
            } else {
                ForEach(store.recipes) { recipe in
                    Button { editingRecipe = recipe } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recipe.title)
                                Text(store.text(
                                    "\(recipe.baseServings) 份 · \(recipe.ingredients.count) 种食材",
                                    "\(recipe.baseServings) servings · \(recipe.ingredients.count) ingredients"
                                ))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button(role: .destructive) { store.deleteRecipe(recipe) } label: {
                            Label(store.text("删除", "Delete"), systemImage: "trash")
                        }
                    }
                    .contextMenu {
                        Button(store.text("编辑", "Edit")) { editingRecipe = recipe }
                        Button(store.text("删除", "Delete"), role: .destructive) { store.deleteRecipe(recipe) }
                    }
                }
            }
        }
        .navigationTitle(store.text("食谱库", "Recipe Library"))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showsAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .appScreenTools(showsMemberSheet: $showsMemberSheet)
        .sheet(isPresented: $showsAdd) { RecipeFormView() }
        .sheet(item: $editingRecipe) { RecipeFormView(recipe: $0) }
    }
}

private struct IngredientDraft: Identifiable {
    let id: UUID
    var name: String
    var quantityText: String
    var unit: String

    init(id: UUID = UUID(), name: String = "", quantityText: String = "", unit: String = "") {
        self.id = id
        self.name = name
        self.quantityText = quantityText
        self.unit = unit
    }

    init(_ ingredient: RecipeIngredient) {
        id = ingredient.id
        name = ingredient.name
        quantityText = ingredient.quantity.map { $0.formatted(.number.precision(.fractionLength(0...2))) } ?? ""
        unit = ingredient.unit
    }

    var value: RecipeIngredient {
        RecipeIngredient(
            id: id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: Double(quantityText.replacingOccurrences(of: ",", with: ".")),
            unit: unit.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

private struct StepDraft: Identifiable {
    let id: UUID
    var text: String

    init(id: UUID = UUID(), text: String = "") {
        self.id = id
        self.text = text
    }

    init(_ step: RecipeStep) {
        id = step.id
        text = step.text
    }

    var value: RecipeStep {
        RecipeStep(id: id, text: text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

struct RecipeFormView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    let recipe: RecipeItem?
    @State private var title: String
    @State private var baseServings: Int
    @State private var ingredients: [IngredientDraft]
    @State private var steps: [StepDraft]
    @State private var photoData: Data?
    @State private var selectedPhoto: PhotosPickerItem?

    init(recipe: RecipeItem? = nil) {
        self.recipe = recipe
        _title = State(initialValue: recipe?.title ?? "")
        _baseServings = State(initialValue: recipe?.baseServings ?? 2)
        let existing = recipe?.ingredients.map(IngredientDraft.init) ?? []
        _ingredients = State(initialValue: existing.isEmpty ? [IngredientDraft()] : existing)
        let existingSteps = recipe?.steps?.map(StepDraft.init) ?? []
        let legacySteps = (recipe?.instructions ?? "")
            .split(separator: "\n")
            .map { StepDraft(text: String($0)) }
        let initialSteps = existingSteps.isEmpty ? legacySteps : existingSteps
        _steps = State(initialValue: initialSteps.isEmpty ? [StepDraft()] : initialSteps)
        _photoData = State(initialValue: recipe?.photoData)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(store.text("基本信息", "Basics")) {
                    TextField(store.text("食谱名称", "Recipe name"), text: $title)
                    Stepper(
                        store.text("默认 \(baseServings) 份", "Default: \(baseServings) servings"),
                        value: $baseServings,
                        in: 1...30
                    )
                }

                Section(store.text("照片（可选）", "Photo (optional)")) {
                    let photoButtonTitle = photoData == nil
                        ? store.text("从相册添加照片", "Add Photo from Library")
                        : store.text("更换照片", "Change Photo")
                    if photoData != nil {
                        RecipePhotoView(data: photoData)
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        Button(store.text("移除照片", "Remove Photo"), role: .destructive) {
                            photoData = nil
                            selectedPhoto = nil
                        }
                    }
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label(
                            photoButtonTitle,
                            systemImage: "photo"
                        )
                    }
                }

                Section(store.text("食材", "Ingredients")) {
                    ForEach($ingredients) { $ingredient in
                        VStack(spacing: 8) {
                            TextField(store.text("食材名称", "Ingredient"), text: $ingredient.name)
                            HStack {
                                TextField(store.text("数量", "Amount"), text: $ingredient.quantityText)
#if os(iOS)
                                    .keyboardType(.decimalPad)
#endif
                                TextField(store.text("单位", "Unit"), text: $ingredient.unit)
#if os(iOS)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
#endif
                            }
                        }
                    }
                    .onDelete { ingredients.remove(atOffsets: $0) }

                    Button {
                        ingredients.append(IngredientDraft())
                    } label: {
                        Label(store.text("添加食材", "Add Ingredient"), systemImage: "plus.circle")
                    }
                }

                Section(store.text("做法（分步）", "Instructions (Steps)")) {
                    ForEach(Array(steps.indices), id: \.self) { index in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.headline)
                                .frame(width: 24, height: 28)
                                .background(.secondary.opacity(0.15), in: Circle())
                            TextField(
                                store.text("输入这一步", "Describe this step"),
                                text: $steps[index].text,
                                axis: .vertical
                            )
                            .lineLimit(1...5)
                        }
                    }
                    .onDelete { steps.remove(atOffsets: $0) }

                    Button {
                        steps.append(StepDraft())
                    } label: {
                        Label(store.text("添加步骤", "Add Step"), systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle(recipe == nil ? store.text("添加食谱", "Add Recipe") : store.text("编辑食谱", "Edit Recipe"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.text("取消", "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .automatic) {
                    Button(store.displayLanguage == .chinese ? "文" : "A") { store.toggleDisplayLanguage() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.text("保存", "Save")) {
                        if let recipe {
                            store.updateRecipe(
                                recipe, title: title, baseServings: baseServings,
                                ingredients: ingredients.map(\.value),
                                instructions: steps.map(\.text).joined(separator: "\n"),
                                photoData: photoData,
                                steps: steps.map(\.value)
                            )
                        } else {
                            store.addRecipe(
                                title: title, baseServings: baseServings,
                                ingredients: ingredients.map(\.value),
                                instructions: steps.map(\.text).joined(separator: "\n"),
                                photoData: photoData,
                                steps: steps.map(\.value)
                            )
                        }
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .task(id: selectedPhoto) {
                guard let selectedPhoto,
                      let data = try? await selectedPhoto.loadTransferable(type: Data.self) else { return }
                photoData = data
            }
        }
    }
}

struct RecipeCookingView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    let recipe: RecipeItem

    private var cookingSteps: [RecipeStep] {
        if let steps = recipe.steps, !steps.isEmpty { return steps }
        return recipe.instructions.split(separator: "\n").map {
            RecipeStep(id: UUID(), text: String($0))
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if recipe.photoData != nil {
                    RecipePhotoView(data: recipe.photoData)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .listRowInsets(EdgeInsets())
                }
                if !recipe.ingredients.isEmpty {
                    Section(store.text("食材", "Ingredients")) {
                        ForEach(recipe.ingredients) { ingredient in
                            Text([ingredient.quantity?.formatted(.number.precision(.fractionLength(0...2))) ?? "", ingredient.unit, ingredient.name]
                                .filter { !$0.isEmpty }.joined(separator: " "))
                        }
                    }
                }
                Section(store.text("烹饪步骤", "Cooking Steps")) {
                    if cookingSteps.isEmpty {
                        Text(store.text("这份食谱还没有填写步骤", "No cooking steps yet"))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(cookingSteps.enumerated()), id: \.element.id) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .frame(width: 30, height: 30)
                                    .background(.blue.opacity(0.15), in: Circle())
                                Text(step.text)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle(recipe.title)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(store.displayLanguage == .chinese ? "文" : "A") { store.toggleDisplayLanguage() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.text("完成", "Done")) { dismiss() }
                }
            }
        }
    }
}

struct RecipePhotoView: View {
    let data: Data?

    var body: some View {
        Group {
            if let data, let image = platformImage(data: data) {
                image.resizable().scaledToFill()
            } else {
                Rectangle().fill(.secondary.opacity(0.12))
                    .overlay { Image(systemName: "photo").foregroundStyle(.secondary) }
            }
        }
    }

    private func platformImage(data: Data) -> Image? {
#if os(macOS)
        guard let image = NSImage(data: data) else { return nil }
        return Image(nsImage: image)
#else
        guard let image = UIImage(data: data) else { return nil }
        return Image(uiImage: image)
#endif
    }
}
