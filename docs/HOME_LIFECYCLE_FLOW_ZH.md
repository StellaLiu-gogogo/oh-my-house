# Household Companion — Home Lifecycle Flow v0.1

- **日期：** 2026-08-27
- **阶段：** Product Design
- **状态：** 核心流程已由用户确认
- **范围：** Wishlist → Purchased → Inventory → Maintenance → Today

## 1. 这条流程解决什么问题

Home 不是一个把所有家庭资料塞在一起的大仓库，而是三个彼此独立、可以自然连接的部分：

- **Wishlist：** 想买什么；
- **Inventory：** 家里已经有什么；
- **Maintenance：** 接下来需要保养、更换或检查什么。

它们代表同一件物品在家庭生活中的不同阶段，但不应被合并成一条越来越复杂的记录。

## 2. Home 首页

Home 首页保留三个清楚的入口：

    Wishlist
    Inventory
    Maintenance

首页只提供简单摘要，例如“3 项 Ready to buy”或“1 项本周到期”。

这让用户可以直接进入当前目标，同时仍然看得出三者之间的关系。

## 3. Wishlist

新建 Wishlist Item 时只要求填写名称，状态默认是 Idea。

其他内容都可选：

- 状态，例如 Idea、Researching、Ready to buy、Purchased；
- 商品链接；
- 预计价格；
- 备注；
- 图片；
- 希望购买的时间。

这样既可以快速记下“想买空气净化器”，也可以在真正准备购买时补充比较结果。

## 4. 从 Purchased 到 Inventory

当 Wishlist Item 标记为 Purchased 后，App 询问：

    已经买到了。要添加到 Inventory 吗？

不要自动创建 Inventory Item。

原因是有些购买不值得长期记录，例如装饰品或低价值消耗品。由用户确认一次，可以避免 Inventory 很快变得杂乱。

如果用户选择添加：

- Wishlist Item 保留，并显示 Purchased；
- 创建一条新的 Inventory Item；
- 两条记录之间保留来源关系。

因此以后查看 Inventory Item 时，可以知道它来自哪个 Wishlist Item；但删除或编辑其中一条，不会不加说明地改坏另一条。

## 5. 可以带入 Inventory 的资料

创建 Inventory Item 时，可以先带入适合继续使用的内容，例如：

- 名称；
- 品牌与型号；
- 实际购买价格；
- 购买日期；
- 商品链接；
- 图片或收据。

用户保存前仍然可以检查和修改。

Inventory 只要求名称。房间或区域可以选择“未指定”，但界面应明显提醒用户补充，因为按房间查找物品通常最自然。

暂时不需要复杂的资产编号、折旧、预算或财务报表。

## 6. 从 Inventory 到 Maintenance

在 Inventory Item 详情页提供“添加维护计划”。新建时自动关联当前物品，不需要用户再搜索一次。

Maintenance 最少需要：

- 要做什么；
- 下一次日期。

其他内容可选：

- 重复方式，例如每 6 个月；
- 负责人，可以是一人、多人、无人或轮流；
- 提前提醒时间；
- 备注。

例如：

    更换空气净化器滤芯
    下一次：2027年2月27日
    重复：每6个月
    负责人：Sida
    提前3天提醒

Maintenance 也可以关联一个房间或区域，而不一定关联具体物品，例如“检查阁楼是否漏水”。

## 7. Maintenance 完成以后

完成一次维护时：

- 保留这次完成记录；
- 如果设置了重复，计算并安排下一次日期；
- 当前到期项目从 Today 中消失；
- 新的下一次日期继续显示在 Calendar，并在到期时进入 Today。

这不是把同一条记录简单向后改日期。保留历史可以回答“上一次什么时候换过滤芯”，同时界面仍然只突出下一次需要做的事。

## 8. Today 和 Calendar 的角色

- **Today：** 只显示今天已经到期或需要提醒的 Maintenance；
- **Calendar：** 显示未来某一天计划做的 Maintenance；
- **Home：** 保存物品详情、维护计划和完成历史。

Today 不复制 Home 中的数据，也不显示完整物品档案。用户点击 Today 中的维护项目后，进入由 Home 管理的详情。

## 9. 双语入口

Home 首页以及 Wishlist、Inventory、Maintenance 的列表、详情、新建和编辑页面，都保留统一的 `文/A` 按钮。

它可以用于切换中文 / English 或查看用户创建内容的原文。具体菜单行为继续遵循独立的 Bilingual Display Control 方案，在用户确认前不视为最终要求。

## 10. 已确认的选择

1. Wishlist 新建时只要求名称，状态默认是 Idea；
2. 标记 Purchased 后询问是否添加到 Inventory，不自动创建；
3. Wishlist 保留 Purchased 记录，新的 Inventory Item 与它保持来源关系；
4. 适合的资料可以带入 Inventory，但用户保存前能够修改；
5. Inventory 只要求名称，房间或区域允许暂时选择“未指定”；
6. Maintenance 只要求“要做什么”和“下一次日期”；
7. 完成 Maintenance 后保留历史，如果有重复则安排下一次。

上述内容已于 2026-08-27 由用户确认，并同步写入主需求文档。

## 11. 可以以后决定

- 收据扫描和保修文件；
- 商品条码；
- 维修费用；
- 物品借出记录；
- 更复杂的维护频率；
- 多张照片和附件；
- 从购买邮件自动导入；
- 按房间展示的图片式 Home Map。

这些都不影响第一阶段的轻量生命周期。
