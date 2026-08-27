# Household Companion — Screen Architecture & Interaction Flows v0.1

- **日期：** 2026-08-27
- **阶段：** Product Design
- **依据：** 主需求文档与已确认的第一轮产品决定
- **文档性质：** 屏幕架构与交互建议；未标记为“已确认”的选择仍需用户 review

## 1. 目标

本轮将已确认的四 Tab 信息架构展开为可以 review 的屏幕结构，重点回答：

- 用户打开每个 Tab 时首先看到什么；
- Today 和 Plan / Calendar 如何避免重复；
- 模块如何自然连接，但仍由各自 domain 拥有数据；
- 哪些操作可以快速完成，哪些操作应进入 domain 详情。

## 2. App Shell

### 2.1 Primary Navigation（已确认）

    Today | Plan | Shopping | Home

四个 Tab 保持稳定。切换 Tab 时应记住各自的 navigation position，避免用户从一个 Inventory Item
切换到 Shopping，再返回 Home 时丢失上下文。

### 2.2 Household / Member 入口

所有 Tab 的右上角使用当前成员 avatar 作为稳定入口。点击后首先打开轻量 member switcher：

    Viewing as
    ● Sida
    ● Ruru

    Manage Household
    App Settings

切换成员后：

- UI 切换到该成员的 preferred display language；
- 共享内容显示该语言的原文或翻译；
- assignee 相关的视觉强调相应更新；
- 不触发登录、登出或权限流程。

### 2.3 Create 入口

**Agent 建议：** 每个 Tab 使用 contextual add，不建立包含所有 domain 的巨大全局创建菜单。

- Plan 创建 Meal、Chore 或 Event；
- Shopping 默认创建 Shopping Item；
- Home 根据当前分区创建 Wishlist Item、Inventory Item 或 Maintenance；
- Today 只提供最常用的有限快捷创建。

## 3. Today

### 3.1 产品职责

Today 是默认首页，只回答：

> 今天家里有什么需要知道或处理？

Today 不负责完整规划、历史搜索或长表管理。

### 3.2 推荐页面结构

    Thursday, 27 August                   [Avatar]
    Good morning

    Needs attention
    └── 仅在存在逾期或时间敏感内容时出现

    Meals
    ├── Lunch
    └── Dinner

    Chores
    ├── Chore + assignee + completion
    └── Chore + assignee + completion

    Home
    └── Due maintenance

    Events
    └── Time / all-day household event

    Shopping
    └── 未购买项数量和入口

### 3.3 排序原则

**已确认：** Today 以生活领域分区为主，而不是完整的小时级时间轴。

Meal 和多数 Chore 只关心“今天”或“晚上”。强制使用时间轴会要求用户为大量家庭内容设置不必要的精确时间。
具有精确时间的 Event 可以在自己的 section 内按时间排序。

### 3.4 直接操作

Today 允许：

- complete / undo Chore；
- complete Maintenance；
- 打开 Meal 或 Recipe；
- 打开 Event；
- 进入 Shopping List。

编辑 recurrence、更换 Recipe、修改 Inventory 等操作回到原 domain 完成。

### 3.5 Empty State

今天没有内容时显示平静的状态，例如“今天家里没有特别安排”，而不是工作软件式的 Inbox zero。

## 4. Plan

### 4.1 产品职责

Plan 是“接下来怎么安排”的空间，不是一个新 domain。

### 4.2 推荐首页

    Plan                                      [Avatar]
    This week                              [Calendar]

    Meals
    └── 5 of 7 dinners planned                 [Open]

    Chores
    └── 4 remaining this week                  [Open]

    Events
    └── Waste collection · Friday              [Open]

Plan 首页只显示每个 domain 的周摘要和入口，不在同一屏复制完整 Meal Planner、Chore List 和 Calendar。

### 4.3 Meals

Weekly Meal Planner 是 Meals 的主页面：

- 按天展示 lunch / dinner 等 meal slots；
- 允许只输入自由文本 meal；
- 也可以选择 Recipe；
- 人数和 servings 是可选增强信息；
- ingredients 经过 review 后再加入 Shopping。

不要强迫所有 meal 使用 Recipe，也不要未经 review 自动填充 Shopping List。

### 4.4 Chores

Chores 默认使用简单 scope switcher：

    Today | This Week | All

列表项优先显示 title、assignee、date 和 completion。Recurrence 等配置仅在详情或编辑中展开。

### 4.5 Household Events

Events 默认显示 Upcoming List，比月历更适合少量家庭事件。Calendar 是另一种查看方式，不是唯一页面。

### 4.6 Calendar

Calendar 从 Plan 顶部进入，可按以下 domain 过滤：

    All | Meals | Chores | Maintenance | Events

Calendar item 打开原 domain 的详情，不创建 Calendar-specific copy。

## 5. Shopping

### 5.1 产品职责

Shopping 只回答：

> 家里现在需要买什么？

它不追踪库存数量、库存扣减或花费统计。

### 5.2 统一清单（已确认）

来源包括：

- Grocery / Meals
- Household Supplies
- Maintenance Item

推荐页面结构：

    Shopping                                  [Avatar]
    [Add item]

    Meals
    ☐ Tomatoes                 Thursday dinner
    ☐ Rice                     Curry recipe

    Household
    ☐ Dishwasher tablets

    Maintenance
    ☐ Air purifier filter      Bedroom purifier

    Purchased recently                         [Show]

Source 是辅助上下文，不应让用户为手动添加的每个项目做复杂选择。手动添加可以默认使用 Household / Other。

### 5.3 Generated Items

Meals 产生的 ingredients 和 Maintenance 产生的 replacement item 经过一次 review 后加入清单。

Review 只需支持：

- 取消不需要的项；
- 简单修改名称或数量文本；
- 识别明显重复项并建议合并。

当前不引入 ingredient master catalog 或单位换算系统。

### 5.4 Purchased State

**Agent 建议：** 勾选后先移到当页 Purchased section 并支持 undo，之后进入有限的 recent history。

不建立长期购物分析、价格历史或 spending dashboard。

## 6. Home

### 6.1 产品职责（已确认）

Home 将三个独立 domain 放入同一自然 lifecycle：

    Wishlist → Inventory → Maintenance

### 6.2 推荐首页

    Home                                      [Avatar]

    Wishlist
    “What could make home better?”
    3 ready to buy                            [Open]

    Inventory
    “What do we already have?”
    Browse by room and area                   [Open]

    Maintenance
    “What needs care next?”
    1 due this week                           [Open]

这些数字只是 contextual summary，不发展为 dashboard 或统计中心。

### 6.3 Wishlist

Wishlist 默认使用简单 list，可按状态筛选：

    All | Ideas | Researching | Ready to buy | Purchased

Planning 是否需要成为独立状态仍可继续 review。对小家庭而言，状态过多可能增加管理感。

### 6.4 Inventory

Inventory 默认按“房间与区域”组织：

    Kitchen
    Living Room
    Bedroom
    Office
    Garden
    Storage
    Whole Home

搜索是辅助入口，不替代 room-first 结构。

Inventory Item 详情按使用频率排序：

1. name、photo、room / area；
2. active maintenance；
3. brand / model / purchase date / warranty；
4. notes、receipt、manual 和 links。

创建 Inventory Item 时不要求填完所有资料。

### 6.5 Maintenance

Maintenance 首页按时间组织：

    Due / Overdue
    Upcoming
    Completed recently

每条记录显示 related item / home area，并可返回 Inventory Item。

## 7. Cross-domain Navigation

跨模块连接使用“关联和跳转”，不复制记录。

### 7.1 Origin Label

Shopping Item 显示来源，例如 Thursday dinner 或 Bedroom purifier。点击来源可返回 Recipe 或 Maintenance。

### 7.2 Related Content

Inventory Item 显示相关 Maintenance；Wishlist Item 购买后显示已创建的 Inventory Item。

### 7.3 Calendar Projection

Calendar 只引用原 domain records。从 Calendar 编辑内容时，实际编辑的仍是 Meal、Chore、Maintenance 或 Event。

### 7.4 Today Projection

Today 完成 Chore 或 Maintenance 后，原 domain 状态同步改变。Today 不维护另一份 completion state。

## 8. Bilingual Interaction

### 8.1 Normal Display

Lists 和 cards 只显示当前成员首选语言，不并排显示中英文。

### 8.2 Translation Indicator

自动翻译内容仅在详情页使用轻量 Translated / 已翻译 indicator，不在每个列表项中重复显示。

### 8.3 View Original

点击 indicator 或详情菜单可查看：

- displayed language；
- original text；
- original language；
- translation status。

### 8.4 Pending / Failed

- pending：先显示原文，可显示非阻塞的翻译中状态；
- failed：显示原文与轻量 retry；
- stale：优先显示原文，或明确标记旧翻译正在更新；
- 任何翻译状态都不阻止创建、完成和 reminder。

## 9. Interaction Principles

1. **Quick first, complete later：** 先允许只填标题，其他信息按需补充。
2. **One clear primary action：** 每个 screen / sheet 保持一个明确主操作。
3. **Progressive disclosure：** recurrence、translation、warranty 等信息需要时再展开。
4. **No forced completeness：** 不为数据完整性强迫填写。
5. **Calm completion：** 完成反馈清晰但克制，不做 productivity gamification。
6. **Domain ownership：** 跨模块视图不创建原记录的 copy。

## 10. 建议下一轮确认的决定

以下选择会影响下一轮 wireframe，适合优先 review：

### 10.1 Today 主结构（已确认）

使用 Meals、Chores、Home / Maintenance、Events 等生活领域分区，不使用完整时间轴。
有精确时间的 Event 仅在自己的分区内按时间排序。

### 10.2 Plan 首页

**Agent 建议：** 默认显示 Meals、Chores 和 Events 的周摘要，Calendar 作为顶部次级入口。

### 10.3 Create 方式

**Agent 建议：** 使用 contextual add，不建立包含所有类型的全局加号。Today 可保留一个有限快捷菜单。

### 10.4 Shopping 勾选行为

**Agent 建议：** 勾选后先移到当页 Purchased section 并支持 undo，稍后进入有限 recent history，不长期统计消费。

## 11. 可以延后的问题

- 具体颜色、字体、icon 与 motion；
- iPad / Mac 的 sidebar 和 multi-column 布局；
- Apple Calendar 集成；
- 通知的技术实现；
- translation provider 和 sync provider；
- 完整 recurrence language；
- Recipe ingredient 单位标准化；
- receipt / manual 文件存储方式；
- Wishlist 是否需要 Planning 状态；
- Home Projects 和 Home Documents。

这些问题不影响当前屏幕架构的 review。
