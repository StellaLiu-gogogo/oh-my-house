# Oh My House — 本地优先数据基础 v0.1

- **日期：** 2026-08-28
- **阶段：** 正式 App 主体开发
- **同步状态：** 当前只保存在本机；CloudKit 尚未启用

## 1. 统一数据入口

正式页面不直接决定数据存在哪里。Today、Plan、Shopping 和 Home 都通过同一个 `HouseholdDataStore`
读取和修改内容。当前使用 `LocalHouseholdDataStore` 把数据写入 Core Data。

以后加入 CloudKit 时，页面仍然使用同一个入口，只在数据层增加同步、共享和冲突处理。
这会减少页面返工，但不代表 CloudKit 可以不经过真实验证。

## 2. 独立的家庭领域

第一版数据结构为以下内容保留独立记录：

- Household；
- Household Member；
- Home Location；
- Meal；
- Recipe；
- Chore；
- Household Event；
- Shopping Item；
- Wishlist Item；
- Inventory Item；
- Maintenance；
- Translation。

Today 和 Calendar 不创建另一份任务数据，只查询 Meal、Chore、Event 和 Maintenance。

## 3. 为以后同步预留的信息

每条主要记录从一开始保存：

- 不随设备变化的 UUID；
- 所属 household；
- 创建时间；
- 最后修改时间；
- 可选的软删除时间。

跨模块连接暂时使用稳定 UUID，例如 Wishlist Item 购买后记录所创建的 Inventory Item，
Maintenance 记录关联的 Inventory Item。CloudKit 接入前仍需验证最终关系模型和共享范围。

## 4. 当前边界

- 不显示假的同步成功状态；
- 不建立邀请或已连接使用者入口；
- 不把本地数据称为云端数据；
- 不把 Personal Team、Apple ID 或设备编号提交到 Git；
- 正式 App 数据结构仍可在首个真实发布前调整。

