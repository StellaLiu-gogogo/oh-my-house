# Household Companion --- 产品需求与设计任务书

-   **工作名称：** Household Companion（最终名称未定）
-   **日期：** 2026-08-27
-   **当前阶段：** 产品设计 / 架构规划
-   **实现状态：** 尚未开始写代码
-   **使用范围：**
    首先供自己的家庭使用，也可能给朋友小范围使用；项目计划在 GitHub 开源
-   **主要平台：** Apple 生态（iPhone / iPad / Mac）

> **Agent 沟通语言要求：**
> 与用户讨论本项目、汇报进展、解释设计、提出问题、撰写设计文档时，**默认始终使用中文回复**。代码、API
> 名称、框架名称、变量名以及适合保留英文的技术术语可以使用英文。除非用户明确要求，否则不要自行切换为英文回复。

------------------------------------------------------------------------

# 1. 产品定位

这个项目最初来自一个"这周吃什么"的家庭餐食规划
App，但现在希望将它设计成一个更完整、同时仍然轻量的 **Household
Companion（家庭生活助手）**。

它主要服务一个小型 household，通常只有 2--4 名成员。

它不是商业 SaaS，不追求大规模用户系统，也不是家庭
ERP、工作管理软件或复杂的 productivity suite。

核心目标是：

> 用一个简单、漂亮、低摩擦的
> App，协调共同生活中真正需要共享的信息和日常事务。

目前确定的主要领域包括：

1.  🍽 餐食 Meals
2.  🧹 家务 Chores
3.  🏠 Home Wishlist
4.  📦 Home Inventory
5.  🔧 Home Maintenance
6.  🛒 Household Supplies
7.  📅 Household Events

此外，**Today / Calendar**
作为跨模块的时间视图，把"今天和这周需要关注的事情"聚合起来。

------------------------------------------------------------------------

# 2. 核心设计原则

## 2.1 Household 才是核心对象

不要把产品理解为"Meal Planner 加一些附加功能"，也不要把 Calendar
当成唯一核心。

更合理的概念是：

``` text
Household
├── Members
├── Meals
├── Chores
├── Home Wishlist
├── Home Inventory
├── Home Maintenance
├── Household Supplies
└── Household Events

Today / Calendar
└── 聚合上述模块中与日期相关的信息
```

Calendar 是重要的 cross-module view，而不是所有数据都必须从 Calendar
出发。

------------------------------------------------------------------------

## 2.2 Personal-first / small-household-first

主要使用场景是自己的家庭，以及朋友的小家庭。

不需要提前设计：

-   enterprise permissions
-   organization management
-   复杂邀请流程
-   管理员体系
-   多级角色权限
-   大规模 SaaS backend
-   企业级 audit / administration

优先考虑简单、舒服、真实可用。

------------------------------------------------------------------------

## 2.3 Household Member 是轻量实体

系统中可以简单存在家庭成员 A / B / C。

例如：

``` text
Household
├── Sida
├── Ruru
└── Guest
```

成员可以拥有：

-   name
-   avatar / icon
-   display color
-   preferred display language
-   与具体模块相关的 preferences

现阶段 **HouseholdMember 不需要等同于 authenticated user account**。

不要为了未来可能的共享同步，提前建立复杂 account / permission system。

------------------------------------------------------------------------

## 2.4 Local-first，保持简单

优先考虑：

-   简单
-   清晰
-   可理解
-   容易维护
-   容易迁移
-   对开源用户友好

未来可以加入 sync，但不要为了未来可能的同步过度设计 backend。

------------------------------------------------------------------------

## 2.5 为扩展留空间，但不要提前实现未来

原则：

> Design for extension, not premature complexity.

当前不需要实现的功能，不要提前建立庞大的 framework。

但是也不要把 Calendar、Day、Household 等基础概念写死成只能服务 Meal。

------------------------------------------------------------------------

## 2.6 不要为了统一而制造万能对象

Meals、Chores、Events、Maintenance 等虽然可能都与日期有关，但语义不同。

不要强行做成一个巨大的：

``` text
GenericTask
GenericEvent
GenericItem
```

然后依靠大量 optional fields 区分。

例如概念上更倾向：

``` text
Day
├── MealPlan[]
├── ChoreAssignment[]
├── MaintenanceDue[]
└── HouseholdEvent[]
```

而不是所有东西都塞进一个 Task。

------------------------------------------------------------------------

## 2.7 开源友好

项目最终计划放到 GitHub 开源。

因此：

-   不要 hard-code 私人家庭数据
-   配置应容易理解
-   README 应清晰
-   数据模型应清晰
-   其他人应能 clone 后建立自己的 household
-   私人数据与项目代码应明确分离

------------------------------------------------------------------------

# 3. 双语与跨语言内容 ------ 核心系统要求

这是整个产品的**核心要求**，不是只针对菜谱的翻译功能。

支持语言：

-   中文
-   English

未来架构可以允许增加其他语言，但当前只需要真正设计和支持中英文。

------------------------------------------------------------------------

## 3.1 UI 本地化

整个 App UI 必须支持中文和英文。

包括：

-   navigation
-   screen titles
-   buttons
-   labels
-   statuses
-   settings
-   empty states
-   notifications
-   system-generated messages
-   Today / Calendar 中由系统生成的文字

用户可以在 App 内随时切换显示语言，不应完全依赖设备系统语言。

------------------------------------------------------------------------

## 3.2 输入语言与显示语言完全解耦

这是非常重要的原则：

> **Input language 和 display language 是两件不同的事情。**

任何家庭成员都可以随时用中文或英文输入。

不要假定：

``` text
Sida = 中文输入
Ruru = 英文输入
```

实际情况是：

-   Sida 有时输入中文，有时输入英文
-   Ruru 基本只输入英文
-   Ruru 应该始终能够用英文查看共享内容
-   Sida 应该能够用中文查看 Ruru 输入的英文内容

------------------------------------------------------------------------

## 3.3 每个 HouseholdMember 有 preferredDisplayLanguage

例如：

``` text
Sida
preferredDisplayLanguage = zh

Ruru
preferredDisplayLanguage = en
```

这个设置决定共享内容默认以什么语言呈现给当前查看者。

------------------------------------------------------------------------

## 3.4 用户创建的共享内容自动生成另一语言版本

例如 Sida 输入：

``` text
周四晚上把绿色垃圾桶推出去
```

系统应保留原文，并生成：

``` text
Put the green waste bin outside on Thursday evening
```

Ruru 默认看到英文。

反过来，Ruru 输入：

``` text
Remember to descale the coffee machine
```

Sida 可以默认看到：

``` text
记得给咖啡机除垢
```

------------------------------------------------------------------------

## 3.5 原文必须永久保留

概念上：

``` text
SharedContent

originalText
originalLanguage

translations
├── zh
└── en
```

机器翻译永远不能覆盖原始输入。

如果原文修改，则由原文派生的旧翻译应视为 stale，并重新生成。

------------------------------------------------------------------------

## 3.6 默认只显示查看者需要的语言

不要在所有界面同时堆叠中文和英文。

正常体验应该是：

-   Sida 看中文
-   Ruru 看英文

但应该提供轻量方式：

-   查看原文
-   查看另一语言版本
-   必要时知道该内容是自动翻译的

------------------------------------------------------------------------

## 3.7 Localization 与 Content Translation 必须分开

例如：

``` text
UI Localization
Settings → 设置
Purchased → 已购买
```

与：

``` text
Dynamic Content Translation
清洗楼上的浴室
↕
Clean the upstairs bathroom
```

是两个不同系统。

结构化状态、类别等应该使用 localization，而不是机器翻译。

------------------------------------------------------------------------

## 3.8 不需要翻译的内容

不要机械翻译：

-   人名
-   品牌名
-   型号
-   URL
-   价格
-   日期
-   identifier

------------------------------------------------------------------------

## 3.9 翻译适用于整个 App

适用于有意义的共享自由文本，包括：

-   Meals
-   Recipes
-   Chores
-   Home Wishlist
-   Home Inventory
-   Home Maintenance
-   Household Supplies
-   Household Events
-   descriptions
-   notes（适当情况下）

Agent 在设计阶段需要考虑一个**简单但可靠**的 translation
architecture，包括：

-   何时翻译
-   是否缓存/保存翻译
-   原文修改后如何刷新
-   翻译暂时不可用怎么办
-   如何识别原文语言
-   是否允许用户以后手动修正翻译
-   notifications 如何使用正确语言

不要把它做成复杂的 translation-management platform。

------------------------------------------------------------------------

# 4. 🍽 Meals --- 餐食规划

解决的问题：

> 这周吃什么？

这是项目最初的核心功能，应保留其重要性。

需要支持：

-   weekly meal planning
-   一周视图
-   不同日期的 lunch / dinner 等餐食
-   每餐参与人数
-   household member preferences
-   recipes
-   servings
-   ingredients
-   从 meal plan / recipe 产生 grocery requirements
-   meal-related reminders / notifications
-   中英文 recipe 内容与自动翻译

如果已有 Week A / Week B
的家庭节奏，可以支持这种循环模式，但不要把所有家庭都写死为同样的节奏。

应考虑 office day、周末、需要剩菜/预制菜等真实生活场景，但具体 household
数据应是可配置的，而不是 hard-coded。

------------------------------------------------------------------------

# 5. 🧹 Chores --- 家务分配

解决：

> 今天/这周有什么家务？谁负责？

例如：

-   vacuum
-   laundry
-   clean bathroom
-   dishwasher
-   general cleaning
-   take rubbish out

需要考虑：

-   title / description
-   assignee
-   date
-   recurrence
-   completion
-   household member
-   reminder
-   简单轮换机制

例如：

``` text
Week A
Bathroom → A

Week B
Bathroom → B
```

Chore 是独立 domain，不要为了统一而和 Meal 合并成 GenericTask。

------------------------------------------------------------------------

# 6. 🏠 Home Wishlist

解决：

> 什么东西能够改善我们的家庭生活？我们未来想买什么、添置什么、改善什么？

这不是普通 grocery list，也不是财务预算系统。

例如：

-   furniture
-   appliances
-   garden improvements
-   home upgrades
-   nice-to-have products
-   大件商品

一个 Wishlist Item 可以考虑：

-   title
-   description
-   category
-   priority
-   estimated budget
-   target date（optional）
-   candidate product links
-   notes
-   status

可能的状态：

-   Idea
-   Researching
-   Planning
-   Ready to buy
-   Purchased

价格只是 Wishlist Item 的属性。

**不要扩展成 household spending / budgeting system。**

------------------------------------------------------------------------

# 7. 📦 Home Inventory

解决：

> 家里已经有什么东西？

主要组织原则：

> **Room → Items**

例如：

``` text
Home
├── Living Room
├── Kitchen
├── Bedroom
├── Office
├── Garden
└── Storage
```

每个房间下面记录物品。

Inventory Item 可以考虑：

-   name
-   room
-   category
-   brand
-   model
-   purchase date
-   purchase price
-   warranty
-   notes
-   photos
-   receipt / manual（适当情况下）

------------------------------------------------------------------------

## 7.1 Wishlist → Inventory

Wishlist 和 Inventory 是两个独立概念，但应该存在自然 workflow：

``` text
Wishlist
    ↓
Purchased
    ↓
Add to Home Inventory
```

当 Wishlist Item 被购买后，可以方便地转换/创建 Inventory
Item，并继承适合的信息，例如名称、型号、价格、链接等。

不要把 WishlistItem 和 InventoryItem 设计成同一个对象。

------------------------------------------------------------------------

# 8. 🔧 Home Maintenance

解决：

> 家里的房屋、设备和物品什么时候需要维护？

例如：

-   replace air purifier filter
-   descale coffee machine
-   heating maintenance
-   smoke detector check
-   garden maintenance
-   appliance cleaning

Maintenance 与 Chore 应区分：

**Chore：** 日常、频繁的家庭任务。

**Maintenance：** 通常与房屋、设备或 Inventory Item
有关，频率较低，并具有维护周期。

Maintenance 可以考虑：

-   related inventory item
-   description
-   recurrence
-   next due date
-   last completed
-   responsible household member
-   reminder

Maintenance 应自然出现在 Today / Calendar。

------------------------------------------------------------------------

# 9. 🛒 Household Supplies / Shopping

除了 Meal 产生的 grocery requirements，还需要管理家庭日常消耗品，例如：

-   toilet paper
-   laundry detergent
-   dishwasher tablets
-   cleaning products
-   replacement filters
-   household consumables

不要建立复杂 warehouse / stock management。

核心问题只是：

> 家里现在需要买什么？

需要在设计阶段考虑：

-   Grocery 和 Household Supplies 是否作为两个 list
-   或者是否应该在 UX 上形成一个 unified Shopping
    experience，并显示不同来源/category

Agent 可以提出推荐方案并解释理由，但不要未经讨论就把它定死。

可能的跨模块来源：

``` text
Meal Plan
→ Ingredients
→ Shopping

Household Supplies
→ Shopping

Maintenance
→ Replacement item
→ Shopping
```

------------------------------------------------------------------------

# 10. 📅 Household Events

用于记录与共同家庭生活有关、容易忘记的日期和提醒。

真实的重要使用场景：

> 经常忘记哪一天需要把垃圾桶推出去。

例如：

-   put rubbish bin outside
-   waste collection
-   bulky waste collection
-   maintenance appointment
-   delivery
-   technician visit
-   household-related deadline
-   recurring municipal collection

需要支持：

-   one-off event
-   recurring event
-   reminder
-   与 Today / Calendar 的连接
-   中英文内容显示

不要试图重新实现 Apple Calendar。

这里只管理 **household-related events / routines**。

------------------------------------------------------------------------

# 11. Today / Calendar

Today / Calendar 是跨模块的时间视图，而不是一个独立业务 domain。

某一天可能显示：

``` text
Thursday

🍽 Meals
Dinner — Tomato beef stew

🧹 Chores
Vacuum upstairs — A
Take bins out — B

🔧 Maintenance
Replace air purifier filter

📅 Household Event
Put rubbish bin outside
```

需要设计：

-   Today view
-   weekly / calendar view
-   如何避免信息过多
-   如何视觉区分不同 domain
-   如何快速 complete / inspect / edit
-   reminders 与 calendar 的关系

目标：

> 用户打开 App 后，应很快知道"今天家庭里有什么需要注意"。

------------------------------------------------------------------------

# 12. 关键跨模块关系

这些自然连接是整个产品形成统一体验的关键。

## Meals → Shopping

``` text
Meal Plan
→ Recipe
→ Ingredients
→ Shopping
```

## Wishlist → Inventory

``` text
Wishlist
→ Purchased
→ Inventory
```

## Inventory → Maintenance

``` text
Inventory
→ Maintenance
→ Reminder / Today
```

## Chores → Today

``` text
Chores
→ Today / Calendar
```

## Events → Today

``` text
Household Events
→ Today / Calendar
```

## Supplies → Shopping

``` text
Household Supplies
→ Shopping
```

不要为了这些连接而强行统一底层 domain object。

------------------------------------------------------------------------

# 13. 产品体验与视觉方向

整个 App 应该感觉：

-   personal
-   warm
-   lightweight
-   calm
-   practical
-   visually clean
-   low-friction
-   native
-   pleasant enough to open every day

避免：

-   enterprise dashboard
-   productivity-tool overload
-   dense tables
-   excessive statistics
-   admin-panel aesthetics
-   复杂 workflow
-   到处都是设置和配置

这是家庭生活 App，不是工作软件。

------------------------------------------------------------------------

# 14. 明确不做的领域

当前明确不要主动加入：

-   household spending / budgeting
-   banking
-   personal finance
-   generic personal todo
-   work task management
-   health / fitness
-   travel planning
-   messaging / chat
-   enterprise permissions
-   complex user-account infrastructure

尤其：

> **Spending / Budgeting 当前明确不做。**

Wishlist 可以有 estimated price / actual purchase price，Inventory
可以记录 purchase price，但这些信息不能自动演变成家庭财务管理系统。

------------------------------------------------------------------------

# 15. 当前不要求主动加入的大型模块

如果 Agent 认为还有自然的未来扩展，可以放到：

`Possible Future Extensions`

但不要未经用户确认就加入当前产品 architecture。

例如此前讨论过但目前没有确认作为核心模块的：

-   Home Projects
-   Home Documents
-   Household spending

其中 Spending 已明确排除。

------------------------------------------------------------------------

# 16. Agent 当前设计任务

当前阶段：

> **Product Design / Architecture Planning**

**不要立即开始写代码。**

请基于本文件进行第一轮整体设计。

需要重点输出：

## A. Product Model

用简洁方式说明整个产品应该如何理解。

## B. Information Architecture

设计主要 domains、层级及相互关系。

## C. Navigation

提出最合理的 primary navigation。

不要默认每个 domain 都需要一个 tab。

请考虑 iPhone 为主的小型 household app 怎样导航最自然。

## D. Core Screens

列出真正需要的核心 screens，并说明职责。

不要一开始设计几十个页面。

## E. Key User Flows

至少设计：

1.  规划一周餐食
2.  使用/生成 Shopping List
3.  创建、分配并完成一个 Chore
4.  创建 Household Event / reminder
5.  添加 Home Wishlist item
6.  将 Purchased Wishlist item 加入 Inventory
7.  为 Inventory item 添加 Maintenance
8.  查看今天有什么需要处理
9.  中文输入共享内容后，英文用户如何自然看到英文
10. 英文输入共享内容后，中文用户如何自然看到中文

## F. Domain Relationships

解释 Meals / Chores / Wishlist / Inventory / Maintenance / Supplies /
Events / Today 如何连接，同时保持清晰边界。

## G. Conceptual Data Model

只做到 conceptual level。

说明主要 entities 与关系即可。

不要现在写 production database schema，也不要过早建立复杂 abstraction。

## H. Bilingual Architecture

单独说明：

-   UI localization
-   dynamic content translation
-   preferredDisplayLanguage
-   original text preservation
-   translation caching / invalidation
-   notifications 的语言
-   translation unavailable 时的 fallback

## I. Visual / Interaction Direction

提出：

-   information hierarchy
-   cards / lists / calendar 的使用
-   icons
-   household member identity
-   statuses
-   interaction style
-   中英文长度差异对 layout 的影响

## J. Open Design Decisions

明确指出哪些地方需要用户继续决定。

不要自行把重要 product choice 变成 confirmed requirement。

------------------------------------------------------------------------

# 17. Agent 工作规则

1.  **默认始终使用中文与用户交流。**
2.  不要因为代码和技术栈使用英文，就改用英文解释产品。
3.  当前先设计，不要直接 coding。
4.  不要把自己的建议写成用户已经确认的需求。
5.  如果发现旧 handoff
    与本文件冲突，以本文件中较新的明确要求为准，并指出重要冲突。
6.  不要因为追求"完整架构"而主动扩大产品 scope。
7.  对未决定事项，明确标记为：
    -   待决定
    -   候选方案
    -   Agent 建议
8.  重要架构选择需要解释 reasoning。
9.  优先保持产品简单、生活化、低摩擦。
10. 任何未来扩展都应遵循： \> Design for extension, not premature
    complexity.

------------------------------------------------------------------------

# 18. 第一轮设计输出要求

阅读本文件后，请不要直接开始 implementation。

首先输出一份**结构清晰但不过度冗长的 Product Design Proposal**，包括：

1.  你对产品的整体理解
2.  推荐的信息架构
3.  推荐的导航方式
4.  核心页面
5.  关键用户流程
6.  模块之间的连接
7.  conceptual data model
8.  双语与自动翻译架构
9.  visual / interaction direction
10. 仍需要用户决定的问题

然后等待用户 review。

**除非用户明确要求开始实现，否则不要写代码。**

------------------------------------------------------------------------

# 19. 已确认的第一轮产品设计决定

**确认日期：** 2026-08-27

以下决定已经用户确认，应作为后续产品设计的已知前提：

## 19.1 Primary Navigation

iPhone 为主的 primary navigation 采用四个 Tab：

``` text
Today | Plan | Shopping | Home
```

-   Today：今天需要关注的家庭信息
-   Plan：Meals、Chores、Household Events 与 Calendar
-   Shopping：统一购物清单
-   Home：Wishlist、Inventory 与 Maintenance

Household 成员与设置不单独占用底部 Tab，从 household / avatar
入口进入。

## 19.2 Unified Shopping List

Shopping 使用一张统一的 Shopping List，不把 Grocery 和 Household
Supplies 分成两套独立体验。

购物项通过来源区分，当前至少包括：

-   Grocery / Meals
-   Household Supplies
-   Maintenance Item

这种统一仅发生在 Shopping UX 中，不会把 Meals、Supplies 和 Maintenance
合并成一个通用 domain object。

## 19.3 Home 组织方式

Home 以下列三个独立但自然连接的领域组织：

``` text
Wishlist → Inventory → Maintenance
```

-   Wishlist：未来想添置或改善的内容
-   Inventory：家中已经拥有的物品
-   Maintenance：房屋、区域和物品的维护

Inventory 在 UI 中以“房间与区域”组织，以容纳 Living Room、Kitchen、Garden、
Storage 和 Whole Home 等真实场景。

## 19.4 Lightweight Household Members

一台设备上可以设置 multiple household members。每个成员当前只需要：

-   name
-   avatar
-   display color
-   preferred display language

不建立正式 account system、复杂登录、角色或权限管理。

当前查看者可以在设备上选择或切换，App 记住该设备当前使用的成员，并根据该成员的
preferred display language 显示内容。
