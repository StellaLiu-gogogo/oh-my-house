import SwiftUI

struct AppShellView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label(store.text("今天", "Today"), systemImage: "sun.max")
                }

            PlanView()
                .tabItem {
                    Label(store.text("计划", "Plan"), systemImage: "calendar")
                }

            ShoppingView()
                .tabItem {
                    Label(store.text("购物", "Shopping"), systemImage: "cart")
                }

            HomeView()
                .tabItem {
                    Label(store.text("家", "Home"), systemImage: "house")
                }
        }
    }
}

