import SwiftUI

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

struct RecipeFormView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    let recipe: RecipeItem?
    @State private var title: String
    @State private var baseServings: Int
    @State private var ingredients: [IngredientDraft]
    @State private var instructions: String

    init(recipe: RecipeItem? = nil) {
        self.recipe = recipe
        _title = State(initialValue: recipe?.title ?? "")
        _baseServings = State(initialValue: recipe?.baseServings ?? 2)
        let existing = recipe?.ingredients.map(IngredientDraft.init) ?? []
        _ingredients = State(initialValue: existing.isEmpty ? [IngredientDraft()] : existing)
        _instructions = State(initialValue: recipe?.instructions ?? "")
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

                Section(store.text("做法（可选）", "Instructions (optional)")) {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 120)
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
                                ingredients: ingredients.map(\.value), instructions: instructions
                            )
                        } else {
                            store.addRecipe(
                                title: title, baseServings: baseServings,
                                ingredients: ingredients.map(\.value), instructions: instructions
                            )
                        }
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
