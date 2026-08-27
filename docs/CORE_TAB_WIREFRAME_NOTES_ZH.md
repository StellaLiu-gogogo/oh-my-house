# Household Companion — Core Tab Wireframe Notes v0.1

- **日期：** 2026-08-27
- **阶段：** Product Design
- **用途：** 说明 Today、Plan、Shopping、Home 第一版界面草图的内容与 review 重点
- **注意：** 这是页面结构草图，不代表最终颜色、字体、图标或视觉细节

## 1. 整体结构

四个已确认的主页面始终位于底部：

    Today | Plan | Shopping | Home

每个页面右上角同时保留：

- 固定的翻译 / 语言按钮；
- 当前家庭成员入口。

切换成员时，页面内容按照该成员的首选语言显示。用户也可以随时通过翻译 / 语言按钮临时切换显示，
或查看共享内容原文。

## 2. Today

Today 不使用时间轴，按照生活领域分区：

1. 只有真正需要注意的内容才出现在顶部提醒区域；
2. Meals 显示今天的餐食；
3. Chores 显示今天的家务、负责人和完成按钮；
4. Home 显示今天到期的 Maintenance；
5. Household Events 在有内容时显示为独立分区。

Today 只提供查看和少量快速完成操作。完整编辑回到原来的模块。

## 3. Plan

Plan 首先显示本周概况：

- Meals：本周已经安排了多少餐；
- Chores：本周还有多少家务；
- Household Events：最近的重要家庭日期。

Calendar 位于页面上方，用户需要查看具体日期时再进入。

## 4. Shopping

Shopping 使用一张统一清单，并按来源分区：

- Meals / Grocery；
- Household Supplies；
- Maintenance Items。

右上角加号只添加 Shopping Item，不弹出其他模块的创建类型。

勾选后的 Shopping Item 先进入当前页面的 Purchased 区域并允许撤销，稍后进入有限的近期记录。

## 5. Home

Home 首页使用三个清晰入口：

1. Wishlist：未来想改善或购买什么；
2. Inventory：家里已经拥有什么；
3. Maintenance：接下来有什么需要维护。

三者保持独立，但通过以下顺序自然连接：

    Wishlist → Inventory → Maintenance

Home 首页只显示少量有用信息，例如“3 项 Ready to buy”或“1 项本周到期”，不做统计 dashboard。

## 6. 本轮需要观察的问题

这组草图主要用于判断：

- 四个主页面放在一起是否自然；
- Today 的信息是否太多或太少；
- Plan 是否足够清楚地表达“本周安排”；
- Shopping 的来源分区是否容易理解；
- Home 的三个入口是否能清楚表达物品 lifecycle。

这些草图不确认具体视觉风格，也不开始任何技术实现。
