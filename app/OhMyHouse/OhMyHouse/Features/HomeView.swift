import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @State private var showsMemberSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(store.text(
                        "愿望清单 → 家庭物品 → 维护",
                        "Wishlist → Inventory → Maintenance"
                    ))
                    .font(.headline)
                }
                Section {
                    NavigationLink {
                        ModulePlaceholderView(title: store.text("愿望清单", "Wishlist"))
                    } label: {
                        DomainSummaryCard(
                            title: store.text("愿望清单", "Wishlist"),
                            detail: store.text("记录未来想改善或购买的东西", "Things to improve or buy later"),
                            symbol: "heart"
                        )
                    }
                    NavigationLink {
                        ModulePlaceholderView(title: store.text("家庭物品", "Inventory"))
                    } label: {
                        DomainSummaryCard(
                            title: store.text("家庭物品", "Inventory"),
                            detail: store.text("按房间和区域整理已有物品", "Organize belongings by room and area"),
                            symbol: "shippingbox"
                        )
                    }
                    NavigationLink {
                        ModulePlaceholderView(title: store.text("维护", "Maintenance"))
                    } label: {
                        DomainSummaryCard(
                            title: store.text("维护", "Maintenance"),
                            detail: store.text("查看即将到期的家庭维护", "See upcoming home maintenance"),
                            symbol: "wrench.and.screwdriver"
                        )
                    }
                }
            }
            .navigationTitle(store.text("家", "Home"))
            .appScreenTools(showsMemberSheet: $showsMemberSheet)
        }
    }
}

