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
-   复杂邀请与审批流程
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

多设备同步和不同成员各自设备共同编辑已经是核心要求，但不要因此把 HouseholdMember 直接变成登录账号。
系统只需要让真实使用者安全地加入同一个 household，不提前建立复杂的 account / permission system。

------------------------------------------------------------------------

## 2.4 Local-first 与多设备同步

优先考虑：

-   简单
-   清晰
-   可理解
-   容易维护
-   容易迁移
-   对开源用户友好
-   iPhone、iPad 与 Mac 之间保持家庭数据一致

多设备同步是当前核心要求，不再是未来功能。App 应在网络暂时不可用时仍可查看和编辑已有家庭数据，
恢复连接后继续同步。

云端同步已确认使用创建者自己的 iCloud 和 CloudKit 共享。设备内数据库等其他技术细节尚未选择。
不要为了同步过度设计商业 SaaS backend，也不要把简单的个人多设备同步扩大成企业账号、
组织管理或复杂权限系统。

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
11. 与用户沟通时优先使用日常、容易理解的语言。必须使用产品设计或技术术语时，
    应先用中文解释其具体含义，不要默认用户已经熟悉该术语。

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

同一个 household 可以设置 multiple household members，并在 iPhone、iPad 与 Mac 之间同步这些成员资料。
每个成员当前只需要：

-   name
-   avatar
-   display color
-   preferred display language

不建立正式 account system、复杂登录、角色或权限管理。

当前查看者可以在每台设备上选择或切换，App 分别记住该设备当前使用的成员，并根据该成员的
preferred display language 显示内容。

## 19.5 Today 不使用时间轴

Today 页面不使用小时级 timeline（时间轴）。这种表达对于本产品过于细化，也会迫使用户为
大量家庭内容填写不必要的精确时间。

Today 应按照 Meals、Chores、Maintenance / Home、Household Events 等生活领域分区展示。
具有精确时间的 Household Event 可以在 Events 分区内部按时间排序，但整个 Today 页面不转换成时间轴。

## 19.6 Plan 首页与 Calendar 入口

Plan 首页默认显示 Meals、Chores 和 Household Events 的本周简短概况。

Calendar 是 Plan 顶部的次级入口，用于按具体日期查看跨模块内容。Plan 首页不直接复制完整的
Meal Planner、Chore List 或 Calendar。

## 19.7 根据当前页面添加内容

创建入口采用“根据当前页面添加”的方式：

-   在 Shopping 中点击添加，直接添加 Shopping Item；
-   在 Chores 中点击添加，直接添加 Chore；
-   在 Wishlist 中点击添加，直接添加 Wishlist Item；
-   其他页面遵循同样原则。

不设置一个包含 Meal、Chore、Event、Shopping、Wishlist、Inventory、Maintenance
等所有类型的巨大全局创建菜单。

Today 可以保留少量最常用的快捷添加，但不能变成所有创建类型的目录。

## 19.8 Shopping Item 勾选后的行为

Shopping Item 被勾选为已购买后：

1.  先移动到当前页面的 Purchased 区域；
2.  允许用户立即 undo；
3.  稍后从当前购物清单移入有限的 recent history；
4.  不建立长期消费统计、价格分析或 spending dashboard。

## 19.9 Meal Planning → Shopping

iPhone 的一周餐食视图使用从周一到周日的纵向列表，每天显示 Lunch / Dinner 等餐食位置，
不使用拥挤的七列横向表格。

添加一顿饭时同时支持：

-   只写餐食名称；
-   选择 Recipe；
-   重复最近吃过的餐食。

输入餐食名称时，第一阶段使用食谱名称的简单匹配显示少量建议。用户需要主动选择某个食谱，系统不会
仅因名称相似就自动关联。选择后，Meal 保留与 Recipe 的来源关系，并按照当前 servings 显示食材；
只有用户检查并勾选确认的食材才加入统一 Shopping List。没有匹配食谱时仍可保存普通文字餐食。

Recipe 可以从相册添加一张可选照片；做法按照可增删的有序步骤分别输入。Today 中已经关联 Recipe
的餐食可以点击打开烹饪页面，显示照片、食材和编号步骤。普通文字餐食不打开空白烹饪页面。

新增餐食时默认选择所有 Household Members 一起吃，用户可以按实际情况取消某位成员。
参与成员与 servings 分开记录，因为两个人也可能做四份并保留剩菜。

Recipe ingredients 必须经过用户简单检查后才能加入 Shopping，不自动加入。

删除一个已经安排的 Meal 时，同时从 Shopping List 移除由这顿 Meal 加入的食材。只移除仍然关联这顿
Meal 的 Shopping Item；用户手动添加的项目、Maintenance / Supplies 项目以及其他 Meal 的食材不受影响。
如果以后一个合并后的 Shopping Item 同时关联多个来源，则只移除被删除 Meal 的来源关系；仍有其他来源时
保留该 Shopping Item。

第一阶段不根据“咖喱饭”“煮面”等简单自由文本自动猜测 ingredients。

## 19.10 Chore 创建、分配与轮流

Chore 只有 title 是必填项。日期、负责人、重复、提醒和 description 都是可选信息，
不应阻止用户快速保存。

负责人分配支持：

-   一位 Household Member；
-   多位 Household Members 共同负责；
-   暂时无人负责；
-   选定成员按照顺序轮流负责。

轮流顺序由计划日期决定。某一次家务漏做时，该次仍由原负责人负责，后续日期的负责人不自动改变。

完成重复 Chore 时只完成当前这一次安排，不结束后续重复，并允许立即 undo。

第一阶段优先支持每天、每周、每两周、每月等简单重复方式。更复杂的自定义重复方式以后再决定。

## 19.11 Household Events 与 Reminder

Events 首页默认按照日期显示接下来会发生的家庭事件。Events 首页本身没有“下一步”操作，
主要操作只有查看 Event、添加 Event，以及进入 Calendar。

Events 的固定入口位于：

    Plan → Events

Events 不占用单独的底部 Tab。Today 只在当天存在相关 Event 或 reminder 时显示 Events 分区；
没有相关内容时不显示空分区。Calendar 用于按日期与 Meals、Chores、Maintenance 一起查看 Event。

创建或编辑 Event 使用一个页面完成，不建立没有必要的多步流程。Reminder 设置可以在同一页面中展开。

Event name 和 date 必填。时间可选择准确时间、时间范围或全天。

第一阶段支持不重复、每周、每两周、每月和每年。

每个 Event 第一阶段支持一个 reminder，reminder text 可以与 Event title 不同。

Event 不自动创建 Chore。只有需要负责人和完成状态时，用户才另外创建 Chore。

## 19.12 每个界面的翻译 / 语言入口

每个主要页面、列表、详情以及创建 / 编辑界面的顶部，都必须提供固定且容易找到的翻译 / 语言按钮。
后续草图不得省略这个入口。

该按钮是整个 App 的系统级能力，不属于某一个 domain。

**已确认的具体行为：**

-   选择中文或 English 时，同时改变 App UI 和可翻译的共享内容；
-   “查看原文”只改变用户创建的共享内容，不改变 App UI 的语言；
-   临时语言选择只在当前使用期间有效，下次打开 App 时恢复当前成员的默认语言；
-   菜单提供“设为我的默认语言”，只有用户主动选择后才更新当前成员的默认语言。
-   用户输入内容按字段分别判断语言。一个页面中可以同时存在中英文：已经是目标语言的内容保持不变，
    另一种语言的菜名、食材名称、烹饪步骤等翻译为当前选择的语言；
-   自动翻译只改变显示结果，不覆盖用户保存的原文。

翻译失败时显示原文，不应因为翻译服务暂时不可用而隐藏或阻止家庭内容。

## 19.13 Home Lifecycle

Home 中 Wishlist、Inventory 与 Maintenance 保持为独立记录，并通过下列流程自然连接：

``` text
Wishlist → Purchased → Inventory → Maintenance → Today / Calendar
```

已确认的具体行为：

1.  新建 Wishlist Item 时只有名称必填，状态默认是 Idea；
2.  Wishlist Item 标记为 Purchased 后，询问用户是否添加到 Inventory，不自动创建；
3.  原 Wishlist Item 继续保留 Purchased 状态，新的 Inventory Item 与它保持来源关系；
4.  名称、品牌、型号、购买价格、购买日期、商品链接等适合的资料可以带入 Inventory，
    但保存前允许用户检查和修改；
5.  Inventory Item 只有名称必填，房间或区域允许暂时选择“未指定”；
6.  Maintenance 只有“要做什么”和“下一次日期”必填，重复、负责人、提醒和备注可选；
7.  完成一次 Maintenance 后保留历史；如果设置了重复，则安排下一次日期。

到期的 Maintenance 出现在 Today，未来日期可以在 Calendar 中查看，物品详情、维护计划和完成历史
仍由 Home 管理。Home 各级页面继续遵守每个界面提供翻译 / 语言入口的系统要求。

## 19.14 Unified Shopping 详细行为

Shopping 默认显示全部购物项，并按来源分组：

``` text
Grocery
Household Supplies
Maintenance
```

顶部可以临时选择只看其中一类，但这些分类仍然属于同一张 Shopping List，不拆成三套独立清单。

已确认的具体行为：

1.  手动添加 Shopping Item 时只有名称必填；
2.  手动添加的来源默认是 Grocery，并允许改为 Household Supplies 或 Maintenance；
3.  Meals、Maintenance 等模块产生的购物项自动保留来源关系；
4.  发现相似项目时只提示，由用户决定合并或继续分开；
5.  合并时由用户检查并填写最终数量，系统不自动换算不同单位；
6.  合并后的一个 Shopping Item 可以保留多个来源；
7.  最近购买记录提供“再次添加”；
8.  将 Maintenance 所需用品标记为已购买，不会自动完成对应的 Maintenance。

Purchased 移入最近购买的具体时间、最近记录的保留范围、清单手动排序、商店或货架分类、条码、价格
与优惠信息以后再决定。当前不建立库存扣减、消费统计或家庭账本。

## 19.15 Today 与 Calendar 详细行为

Today 继续按照 Meals、Chores、Home / Maintenance、Household Events 分区，不使用小时级时间轴。
Shopping 不在 Today 重复显示，因为它已经拥有固定的底部 Tab。

Today 显示：

-   当天安排的 Meal、Chore、Maintenance 和 Event；
-   尚未完成的逾期 Chore 与 Maintenance；
-   今天触发的 Event reminder，即使 Event 本身在未来日期。

Meal 不变成逾期任务，已经过去的 Event 也不持续留在 Today。空的 Chores、Maintenance 和 Events
分区不显示。未安排的 Meal 可以显示轻量添加提示。

Chore 和 Maintenance 可以直接在 Today 完成，并允许立即 undo。完成内容可以短暂保留以便撤销，
之后从 Today 隐藏，但原模块继续保留历史。

每个 Today 分区先显示最需要注意的 3 项，逾期内容优先；更多项目可以在 Today 内展开。

Calendar 的固定入口为：

    Plan → Calendar

iPhone Calendar 默认使用周视图，从周一到周日直接显示每天的 Dinner 与 Chores；当天存在
Maintenance 或 Event 时也继续显示。用户可以前后切换周，并切换到月视图查看较远日期。月视图的
日期下方以少量颜色点表示当天是否有 Meals、Chores、Maintenance 或 Events，不在月格中显示完整标题。

选择日期后，内容仍按生活领域分区，并允许临时只查看某个领域。Calendar 中的 Chore 和 Maintenance
也可以直接完成并 undo。

Today 和 Calendar 中的项目始终打开并更新原模块记录，不创建 Today-specific 或 Calendar-specific 副本。

## 19.16 Household Members 详细行为

第一次打开 App 时不注册账号、不要求家庭名称，只要求创建第一位 Household Member。其他成员可以
立即添加，也可以进入 Today 后再添加。

创建成员时只有名字必填。App 为头像、颜色和默认语言提供可修改的默认值：

-   头像可以使用名字首字母、内置图标、emoji，或从相册选择照片；
-   照片不是必填，只在用户主动选择相册照片时请求所需访问；
-   颜色默认选择一个尚未使用的颜色；
-   默认语言初始使用当前 App 显示语言，可改为中文或 English。

每个主要页面右上角的当前成员头像用于打开成员切换列表。点击另一位成员后立即切换，设备记住选择。
切换会改变 UI 与共享内容的显示语言和成员颜色提示，但不会隐藏、过滤或改变家庭共享内容。

成员切换列表不是 Today 或其他页面中的内容分区。它只在点击右上角头像后临时出现，选择成员或点击
菜单外部后立即关闭。

本机通知使用设备当前成员的默认语言。Household Member 资料之间不设置管理员、所有者、角色或日常内容权限。
管理 iCloud 访问的是创建 household 的真实使用者，不是某一个 Member 资料。

移除成员时：

-   过去记录继续保留该成员的名字、头像和颜色；
-   尚未完成的单人安排如果只由该成员负责，则变为“未分配”；
-   多人或轮流安排移除该成员，其他成员继续保留；没有其他成员时变为“未分配”；
-   移除后提供受影响项目的检查入口；
-   家庭中始终至少保留一位成员。

家庭名称、App 访问锁、访客模式和清除整个家庭的流程以后再决定。

## 19.17 多终端设备同步

同一个 household 的数据必须能够在用户的 iPhone、iPad 和 Mac 之间同步。多设备同步是第一阶段核心能力，
不再作为未来扩展。

当前已确认的同步核心范围包括所有主要家庭领域：

-   Household Members 及头像；
-   Meals 与 Recipes；
-   Chores；
-   Shopping；
-   Wishlist、Inventory 与 Maintenance；
-   Household Events；
-   用户创建内容的原文与已有翻译；
-   完成状态和相关历史。

已确认的具体同步行为：

-   网络暂时不可用时仍能查看和编辑已有内容，恢复后自动继续同步；
-   正常同步保持安静，只有持续问题才显示状态；
-   同步删除提供确认或恢复机会。

以下状态保留为每台设备自己使用，不随着另一台设备切换：

-   当前使用的 Household Member；
-   本次临时选择的显示语言；
-   设备通知权限和适合设备本身的设置；
-   当前打开的页面。

不同家庭成员使用各自独立设备，共同查看和编辑同一个 household，也属于第一阶段核心要求。

Household Member 资料与“实际连接进来使用 App 的人”需要保持区别：

-   Household Member 是名字、头像、颜色、默认语言以及负责人关系；
-   实际使用者需要一种最低限度的身份识别，才能在自己的设备上安全加入 household；
-   儿童、访客或暂时不用 App 的成员仍然可以只有 Household Member 资料，不必拥有登录身份。

加入家庭保持轻量。已确认由已连接的家庭成员生成一次性邀请，同一个邀请可以通过链接、二维码或短代码
分享；接收者加入后，选择“我是已有成员”或“添加我为新成员”，避免重复 Member 资料。

日常家庭内容不建立管理员层级或细分权限，已连接的家庭成员默认共同编辑。由于完整数据库由创建者的
iCloud 持有，只有该 iCloud 所有者负责生成邀请和停止设备访问。移除某人的设备访问与删除其
Household Member 历史资料必须作为两个不同操作。

云端数据使用用户自己的 iCloud 和 CloudKit 的方向已经确认。设备内的具体数据存储工具、
冲突处理实现和最低系统版本继续留在技术设计阶段决定。

## 19.18 Shared Household Join Flow

家庭邀请的固定入口为：

``` text
右上角头像
→ 管理家庭成员
→ 已连接使用者
→ 邀请家庭成员
```

“邀请家庭成员”和停止访问入口只提供给持有 household 云端数据库的 iCloud 所有者。
其他已连接成员仍可查看成员资料和共同编辑日常家庭内容。

已确认的具体行为：

1.  同一个一次性邀请同时提供分享链接、屏幕二维码和短代码；
2.  邀请使用一次后失效，可以由邀请人随时取消，并在 24 小时后自动失效；
3.  接收者先看到邀请人、已有 Member 和共同编辑范围，确认后才继续；
4.  接收者可以选择尚未连接真实使用者的已有 Member，或创建新的 Member；
5.  已连接到其他真实使用者的 Member 不直接出现在可选列表中，避免错误认领；
6.  加入确认页面显示所选 Member、默认语言和共同编辑能力；
7.  加入后该设备默认使用所选 Member，自动同步家庭内容并进入 Today；
8.  只有持有 household 云端数据库的 iCloud 所有者可以生成邀请和停止其他使用者访问；
9.  停止访问只断开真实使用者及其设备，不删除 Member 资料、过去记录或负责人历史；
10. 邀请已使用、过期或取消时只显示简单说明，并允许索取新邀请。

成员管理和家庭邀请不出现在 Today 内容中，也不占用底部 Tab。

## 19.19 通知发送对象

不同成员使用各自设备后，通知按照内容的负责人和家庭范围发送：

-   一人负责的 Chore reminder 发送到该成员连接的设备；
-   多人共同负责的 Chore reminder 发送给所有负责人；
-   无人负责的 Chore 不主动推送个人提醒，只在 Today 显示；
-   Maintenance 有负责人时发送给负责人，无负责人时只在 Today 显示；
-   Household Event reminder 默认发送给所有已连接家庭使用者；
-   Shopping 第一阶段不自动发送通知。

通知文字使用接收设备所关联成员的默认语言。设备通知权限继续由每台设备自己控制，不在家庭设备间同步。

Meal-related reminder 的具体使用场景和接收对象可以在以后有真实需要时补充，不阻碍 Product Design v0.1。

## 19.20 iCloud 数据归属

已确认的云端数据方向是：

-   完整的 household 云端数据库由创建家庭的用户自己的 iCloud 持有；
-   其他已连接使用者通过 CloudKit 共享权限访问和编辑这一份数据；
-   其他使用者不会因此获得数据所有者的其他 iCloud 内容；
-   其他使用者的 iCloud 不拥有另一套独立的 household 云端数据库；
-   每台设备仍保留一份必要的本地同步副本，以支持断网查看和编辑；
-   设备上的本地副本不是另一个独立家庭，恢复网络后会回到同一份共享数据；
-   真正连接家庭的使用者需要在设备上登录可用的 iCloud 账号；
-   儿童或不使用 App 的 Household Member 仍然不需要 iCloud 账号。

创建 household 的 iCloud 用户在 Apple 底层是数据所有者，并负责邀请和停止设备访问。其他已连接成员
仍然共同编辑全部日常家庭内容，但不能管理谁可以访问 household。数据导出和备份方案需要在技术设计中
作为重要保护措施。

## 19.21 已确认的 Apple 技术方向

已确认使用以下技术组合：

-   SwiftUI 制作 iPhone、iPad 和 Mac 页面；
-   Core Data 保存每台设备上的本地数据并支持离线使用；
-   CloudKit 将完整 household 云端数据保存在创建者的 iCloud，并共享给其他使用者；
-   Apple Translation 翻译中英文用户生成内容；
-   Apple 通知能力处理 Chore、Maintenance 和 Event reminder。

最低系统版本已经确认为 iOS 18、iPadOS 18 和 macOS 15。

正式 App 开发前先做一个小型可行性验证，只验证本地保存、CloudKit 多设备与多用户共享、一次性邀请、
离线修改、头像和中英文翻译。验证通过前不搭建完整 Today、Plan、Shopping 和 Home 页面。

开始验证需要完整 Xcode，以及能够为 App 启用 CloudKit 的 Apple 开发者账号。购买或注册开发者计划
不由项目自动执行，必须由用户自行决定。

Synology NAS 方案已经讨论，但不作为第一阶段实时同步服务。项目继续使用原生 App + iCloud / CloudKit，
避免同时维护原生 App、NAS 后端和家庭远程网络。NAS 以后可以作为数据导出或备份目的地，但不是当前
household 数据库。

## 19.22 分阶段开发：先完成本地主体，再接入 iCloud

用户暂时不加入 Apple Developer Program。第一阶段本地保存与 Apple Translation 真机验证通过后，
项目可以开始制作正式 App 主体，但这一阶段只承诺单台设备上的完整使用体验。

本地主体包括已确认的 Today、Plan、Shopping、Home、Meals、Chores、Events、Members、
Wishlist、Inventory 和 Maintenance 等页面与流程。数据继续使用 Core Data 保存在当前设备，
中英文界面和用户内容翻译继续作为系统级能力实现。

为了以后加入 CloudKit 时不重做所有页面，正式页面统一通过共享的数据管理层读写内容，
而不是各页面自行决定保存方式。数据模型从一开始保留稳定 ID、household 归属、创建和修改时间、
成员归属等同步所需基础信息，并遵守未来 CloudKit 接入需要的模型限制。

当前阶段不制作假的云端状态，也不把尚未验证的同步、邀请或多人共享表现为可用功能。
iCloud 入口暂时隐藏。加入 Apple Developer Program 后，仍必须完成多设备同步、不同 iCloud 用户共享、
离线冲突、邀请和头像同步验证，验证通过后才能把这些能力视为可交付功能。

## 19.23 可选择的外观风格

App 第一阶段提供四种完整的预设外观风格：

-   温暖家庭：米白背景、柔和暖色和圆润卡片，作为默认风格；
-   清爽简洁：白色与浅灰背景、蓝色点缀和更少装饰；
-   自然舒适：浅绿色、米色和自然色调；
-   活泼多彩：更明显地使用成员颜色和模块颜色，但不做成儿童化界面。

外观风格可以改变页面背景、卡片颜色与圆角、按钮和 Tab 的主要颜色、模块辅助颜色及部分图标表现，
但不改变四个 Tab、页面结构、按钮位置、操作方式或数据内容。所有风格必须继续支持系统字体大小和
辅助功能，不能为了视觉效果降低可读性。

每位 Household Member 分别保存自己的外观风格。切换当前成员时，App 使用该成员选择的风格；未来加入
iCloud 后，这项偏好跟随该成员同步到其他设备，不改变其他成员的选择。

浅色 / 深色与外观风格分开设置，提供“跟随系统、始终浅色、始终深色”。固定入口为：

``` text
右上角头像 → 外观 → 风格 / 浅色与深色
```

第一阶段不提供任意颜色和大量细节的自由组合。以后有真实需要时，可以增加自选主要颜色，但不改变
预设风格优先、简单易选的原则。

## 19.24 关联内容的修改与删除原则

Meals、Recipes、Shopping、Wishlist、Inventory 和 Maintenance 等记录可以彼此连接，但连接不代表
它们变成同一条记录。修改或删除其中一项时，统一遵守以下原则：

1.  由来源自动产生、并且仍只属于该来源的附属内容，可以随来源一起删除。例如删除 Meal 时，移除由
    该 Meal 加入 Shopping 的食材；
2.  用户已经单独编辑过的内容，不被系统静默覆盖。需要自动更新时，应提示用户检查或选择；
3.  已经成为独立家庭记录的内容，删除来源时通常保留，只解除来源连接。例如 Wishlist 创建 Inventory
    后，删除 Wishlist 不自动删除家中实际拥有的 Inventory Item；
4.  删除会影响其他内容时，操作前用通俗文字说明会删除什么、保留什么或解除什么连接；
5.  删除后尽量提供立即撤销。未来通过 iCloud 同步到其他设备的重要删除也遵守确认或恢复原则。

如果一条内容同时有多个来源，删除其中一个来源只移除对应连接；仍有其他来源时继续保留内容。具体页面
遇到两种都合理的处理方式时，仍需单独确认，不能借这些通用原则擅自扩展产品行为。
