# Household Companion — Today & Calendar Flow v0.1

- **日期：** 2026-08-27
- **阶段：** Product Design
- **状态：** 核心流程已由用户确认
- **范围：** Today、Plan → Calendar、逾期内容、直接完成和信息数量控制

## 1. 两个页面各自负责什么

Today 和 Calendar 展示的是 Meals、Chores、Maintenance、Events 中已有的内容，不拥有另一份副本。

- **Today：** 今天家里有什么需要知道或处理；
- **Calendar：** 某一天安排了什么，以及未来日期的大致分布；
- **原模块：** 保存完整内容并负责创建、编辑、重复规则和历史。

Today 不是任务收件箱，Calendar 也不是所有功能的起点。

## 2. Today 的基本结构

Today 不使用小时级时间轴，继续按照生活领域分区：

    Meals
    Chores
    Home / Maintenance
    Events（有内容时才出现）

Shopping 不在 Today 重复显示。它已经拥有固定的底部 Tab；用户随时可以直接进入。

## 3. 什么会出现在 Today

### 当天内容

- 今天安排的 Meal；
- 今天到期的 Chore；
- 今天到期的 Maintenance；
- 今天发生的 Event；
- 今天触发的 Event reminder，即使 Event 本身在明天。

### 逾期内容

未完成的 Chore 和 Maintenance 继续留在 Today，并清楚显示“昨天到期”等说明，直到用户完成、
重新安排或取消。

Meal 不变成逾期任务。已经过去的 Event 也不一直留在 Today。

### 空的分区

Chores、Maintenance 和 Events 没有内容时不显示空分区。

Meals 可以作为例外：如果今天还没有安排家庭关心的餐食，可以显示一条轻量提示，例如“今天还没有安排晚餐”，
并允许直接添加。这样“还没决定吃什么”本身也能被看见。

## 4. Today 中可以直接做什么

可以直接：

- 完成 Chore；
- 完成 Maintenance；
- 立即撤销刚才的完成；
- 打开 Meal 或 Recipe；
- 打开 Event；
- 从未安排的 Meal 提示中添加餐食。

完整编辑、重复设置、负责人调整和历史查看仍然回到原模块。

完成的 Chore 或 Maintenance 可以短暂留在页面中，方便撤销；之后从 Today 隐藏，但历史仍由原模块保留。

## 5. 内容太多时怎么办

每个分区先显示最需要注意的 3 项：

1.  逾期内容优先；
2.  当天内容其次；
3.  有准确时间的 Event 在 Events 内按时间排列。

如果同一分区超过 3 项，显示“展开另外 X 项”，用户可以在 Today 中展开，不强迫跳到另一个页面。

这是为了控制首屏长度，不会丢失或自动隐藏真实内容。

## 6. Today 没有内容时

显示平静的说明：

    今天家里没有特别安排

并简单提示可以从 Shopping 或 Plan 继续，不使用工作软件式的警告、分数或“清空收件箱”表达。

## 7. Calendar 的入口和默认页面

Calendar 的固定入口是：

    Plan → Calendar

iPhone 默认显示月视图。日期下方使用少量颜色点表示当天是否有 Meal、Chore、Maintenance
或 Event，不在月格中塞入完整标题。

选择日期后，在月历下方显示当天内容；也可以进入更完整的日期页面。

## 8. Calendar 的日期内容

选择某一天后，仍然按生活领域分区：

    Meals
    Chores
    Maintenance
    Events

顶部可以选择只看某个领域。这个选择只是临时查看，不改变数据。

点击项目进入它所属模块的详情。Chore 和 Maintenance 可以直接完成并立即撤销，与 Today 使用同一条记录。

Calendar 不显示没有日期的 Wishlist、Inventory 或 Shopping Item。

## 9. 双语显示

Today、Calendar、日期详情以及从它们打开的页面都保留 `文/A` 按钮。

- 页面标题、日期说明和系统提示使用当前显示语言；
- Meal、Chore、Maintenance 和 Event 内容使用共享内容翻译；
- 人名、品牌、型号和数值不做机械翻译；
- 切换语言不会产生另一份 Today 或 Calendar 数据。

## 10. 已确认的选择

1. Today 按 Meals、Chores、Home / Maintenance、Events 分区，不使用时间轴；
2. Shopping 不在 Today 重复显示；
3. Today 显示当天内容、逾期 Chore / Maintenance，以及今天触发的 Event reminder；
4. 空的 Chores、Maintenance、Events 分区隐藏；未安排的 Meal 可以显示轻量添加提示；
5. Chore 和 Maintenance 可以在 Today 直接完成并立即撤销；
6. 每个分区先显示 3 项，更多内容可以在 Today 内展开；
7. Calendar 从 Plan 进入，iPhone 默认使用月视图和少量颜色点；
8. Calendar 选择日期后仍按领域显示，并可以临时只看某个领域；
9. Calendar 中的 Chore 和 Maintenance 也可以直接完成并撤销；
10. 点击 Today 或 Calendar 的内容时，进入原模块详情，不创建另一份记录。

上述内容已于 2026-08-27 由用户确认，并同步写入主需求文档。

## 11. 可以以后决定

- iPad 和 Mac 使用月视图、周视图还是组合布局；
- Calendar 是否记住上一次选择的领域；
- 每个分区默认显示 3 项是否需要根据屏幕尺寸调整；
- 是否支持系统桌面小组件；
- 是否连接 Apple Calendar；
- Today 是否提供其他少量快捷添加；
- 节假日和生日显示。

这些内容不影响第一阶段 Today 与 Calendar 的职责划分。
