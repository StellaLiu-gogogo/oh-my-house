# Oh My House 正式 App

这是正式 App 主体，与 `validation/LocalTranslationValidation` 技术验证程序分开。

## 当前里程碑

已经完成：

- iPhone、iPad、Mac 共用的 SwiftUI App 项目；
- Today、Plan、Shopping、Home 四个固定主 Tab；
- Today 按 Meals、Chores、Home、Events 分区，不使用时间轴；
- Plan 的 Meals、Chores、Events 与 Calendar 入口；
- Shopping 统一清单的三个来源分区；
- Shopping Item 本地新增、购买和撤销；
- Home 的 Wishlist → Inventory → Maintenance 入口；
- 每个主页面的“文/A”语言按钮和成员头像入口；
- 统一 `HouseholdDataStore` 数据入口；
- Core Data 本地数据库；
- iCloud、邀请和多人共享入口保持隐藏。

当前 Meals、Chores、Events、Wishlist、Inventory、Maintenance 和完整 Members 页面仍在开发中，
界面中会明确显示尚未完成，不把占位页面当成可用功能。

## 打开项目

使用 Xcode 打开：

`app/OhMyHouse/OhMyHouse.xcodeproj`

最低系统版本：iOS / iPadOS 18、macOS 15。

