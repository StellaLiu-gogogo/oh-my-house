# Oh My House 正式 App

这是正式 App 主体，与 `validation/LocalTranslationValidation` 技术验证程序分开。

## 当前里程碑

已经完成：

- iPhone、iPad、Mac 共用的 SwiftUI App 项目；
- Today、Plan、Shopping、Home 四个固定主 Tab；
- Today 按 Meals、Chores、Home、Events 分区，不使用时间轴；
- Plan 的 Meals、Chores、Events 与 Calendar 入口；
- Shopping 统一清单的三个来源分区和临时筛选；
- Shopping Item 本地新增、购买和撤销；
- Wishlist 标记已购买后，由用户决定是否加入 Inventory；
- Maintenance 可关联 Inventory、安排下次日期，并把所需用品加入 Shopping；
- 到期 Maintenance 进入 Today，未来维护日期进入 Calendar；
- 每个主页面的“文/A”语言按钮和成员头像入口；
- 可建立多个本地家庭成员，并按名字、颜色区分；
- 点击右上角头像切换当前使用者；
- 每位成员可以从相册选择头像；
- 一周餐食按周一到周日纵向安排，可选择一起吃饭的成员和份数；
- 一周餐食的每一天都保留添加入口；
- Plan → Meals 中包含可新增、编辑和删除的食谱库；
- 食谱支持从相册添加照片，并按编号分别输入烹饪步骤；
- Today 中点击关联食谱的餐食会打开照片、食材和烹饪步骤；
- 添加餐食时按名称显示食谱建议，选择后保留餐食与食谱的来源关系；
- 选择食谱后可以按份数检查食材，只把勾选内容加入 Shopping；
- 家务可选日期，并可设为一人、多人、无人或轮流负责；
- 家庭事件支持全天、准确时间、时间范围，并可记录一个提醒；
- Meals、Chores 和 Events 支持编辑与删除；
- 重复家务完成当前一次后安排下一次，轮流家务切换到下一位负责人；
- 重复 Event 会在相应日期进入 Today 和 Calendar；
- Today 汇总当天餐食、到期/逾期家务和家庭事件，不使用时间轴；
- Plan 提供 Meals、Chores、Events 和 Calendar 的固定入口；
- Calendar 默认使用周视图，直接显示每天的晚餐与家务，并可切换月视图；
- 统一 `HouseholdDataStore` 数据入口；
- Core Data 本地数据库；
- iCloud、邀请和多人共享入口保持隐藏。

当前仍在继续完善编辑、删除、重复计划、系统通知、用户内容翻译以及更完整的异常处理。

## 打开项目

使用 Xcode 打开：

`app/OhMyHouse/OhMyHouse.xcodeproj`

最低系统版本：iOS / iPadOS 18、macOS 15。
