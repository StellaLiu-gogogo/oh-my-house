# Household Companion — Household Events & Reminders Flow v0.1

- **日期：** 2026-08-27
- **阶段：** Product Design
- **状态：** Agent 建议，等待用户 review
- **范围：** 家庭事件、重复日期、提醒、Today / Calendar 和双语通知

## 1. Event 是什么

Household Event 用来记录与共同家庭生活有关、容易忘记的日期，例如：

- 垃圾回收；
- 家电送货；
- 技术人员上门；
- 暖气检查预约；
- 家庭相关截止日期。

它不取代 Apple Calendar，也不记录工作会议、个人约会或完整个人日程。

## 2. Events 首页

Events 默认使用 Upcoming List，也就是按照日期显示接下来会发生什么。

例如：

    8月28日  绿色垃圾回收
    9月2日   洗衣机送货
    9月12日  暖气检查

对于数量不多的家庭事件，这比打开完整月历更容易快速阅读。

Calendar 仍然可以从 Plan 进入，用于和 Meals、Chores、Maintenance 一起查看某一天。

## 3. 创建 Event

最少需要：

- 事件名称；
- 日期。

时间可以选择：

- 全天；
- 准确时间；
- 时间范围，例如 14:00–17:00。

这样既能记录没有准确时间的垃圾回收，也能记录技术人员上门时间。

## 4. 重复 Event

第一阶段建议支持：

- 不重复；
- 每周；
- 每两周；
- 每月；
- 每年。

“每两周”对于市政垃圾回收等真实家庭场景很重要。

更复杂的市政日历导入或不规则日期可以以后决定。

## 5. Reminder

Reminder 的意思是“在事件发生前提醒家庭成员”。

例如：

    Event
    绿色垃圾回收 · 星期五

    Reminder
    星期四 20:00
    把绿色垃圾桶推出去

Event title 和 reminder text 可以不同。Event 说明“发生什么”，reminder 说明“现在需要注意什么”。

**Agent 建议：** 第一阶段每个 Event 先支持一个 reminder。一个 reminder 已经覆盖主要场景，也能保持设置简单。

以后有真实需要时再支持多个提醒，例如“前一天晚上”和“当天早上”各提醒一次。

## 6. Today 和 Calendar

- Event 在发生日期出现在 Calendar；
- 如果 reminder 在前一天触发，Today 可以提前显示这件事；
- Event 详情仍然由 Events 模块拥有；
- Today 和 Calendar 不复制一份新的 Event。

## 7. 双语通知

同一条 Event reminder 按接收成员的首选语言显示。

例如 Sida 看到：

    明天绿色垃圾回收
    把绿色垃圾桶推出去

Ruru 看到：

    Green waste collection tomorrow
    Put the green waste bin outside

原文仍然保留。翻译不可用时显示原文，提醒不会被取消。

## 8. Event 与 Chore 的区别

简单判断：

- “星期五是绿色垃圾回收日”是 Event；
- “星期四晚上把垃圾桶推出去”如果需要负责人和完成状态，可以是 Chore。

对于只需要提醒一次的简单场景，Event 的 reminder text 写“把垃圾桶推出去”已经足够，不必强迫用户再创建 Chore。

如果家庭希望知道“谁负责”和“是否完成”，用户可以另外创建 Chore。第一阶段不自动让 Event 生成 Chore，避免一件事产生两条容易混淆的记录。

## 9. 当前建议确认的选择

### 9.1 Events 首页

**Agent 建议：** 默认显示按照日期排列的 Upcoming List，Calendar 作为另一种查看方式。

### 9.2 必填内容

**Agent 建议：** Event name 和 date 必填；准确时间可选，也可以是全天。

### 9.3 重复选项

**Agent 建议：** 第一阶段支持不重复、每周、每两周、每月和每年。

### 9.4 Reminder 数量

**Agent 建议：** 第一阶段每个 Event 支持一个 reminder，并允许 reminder text 与 Event title 不同。

### 9.5 Event 不自动生成 Chore

**Agent 建议：** 简单提醒只保存在 Event 中；只有需要负责人和完成状态时，用户才另外创建 Chore。第一阶段不自动关联或生成。

## 10. 可以以后决定

- 多个 reminder；
- Apple Calendar 集成；
- 市政垃圾回收日历导入；
- 不规则重复日期；
- Event 和 Chore 的可选关联；
- 附件、地址和地图；
- 与外部送货追踪服务连接。

这些功能都不影响当前轻量 Events 体验。
