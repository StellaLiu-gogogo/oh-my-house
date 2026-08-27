# Household Companion — Product Design Proposal v0.1

-   **日期：** 2026-08-27
-   **状态：** 第一轮产品方向已 review，四项核心决定已确认
-   **范围：** Product Design / Architecture Planning，不包含技术选型与实现

## 1. Product Model

Household Companion 是一个小家庭的共同生活空间，而不是 Meal Planner 加一组附加工具，
也不是以 Calendar 为中心的通用任务管理器。

各个 domain 保存自己完整的业务语义，Today 和 Calendar 只负责在正确的时间聚合需要关注的内容。

## 2. Information Architecture

``` text
Household
├── Today
├── Plan
│   ├── Meals / Weekly Meal Plan / Recipes
│   ├── Chores
│   ├── Household Events
│   └── Calendar
├── Shopping
│   ├── Grocery requirements
│   ├── Household supplies
│   └── Maintenance requirements
├── Home
│   ├── Wishlist
│   ├── Inventory
│   └── Maintenance
└── Household Settings
    ├── Members
    ├── Languages
    └── Notifications
```

## 3. Navigation

已确认使用四个 primary tabs：

``` text
Today | Plan | Shopping | Home
```

-   Today 是默认首页，回答“今天家里有什么需要注意”。
-   Plan 组织 Meals、Chores、Events 和 Calendar，但不把它们合并成一个通用对象。
-   Shopping 聚合当前需要购买的内容。
-   Home 呈现 Wishlist → Inventory → Maintenance lifecycle。

Household member 和 Settings 从顶部 household / avatar 入口进入。

## 4. Core Screens

1.  Today
2.  Plan / This Week
3.  Weekly Meal Planner
4.  Recipes
5.  Chores
6.  Household Events
7.  Calendar
8.  Shopping List
9.  Home
10. Wishlist
11. Inventory / Inventory Item
12. Maintenance
13. Household Settings

简单创建和编辑操作优先使用 sheet，不为每个动作创建独立页面。

## 5. Today and Calendar

Today 是一个轻量 attention surface，而不是 task inbox。它按 Meals、Chores、Maintenance 和
Events 聚合今日内容，并支持完成 chore、完成 maintenance 和查看详情等少量直接操作。

Calendar 是位于 Plan 内的跨模块时间视图。它可以按 domain 过滤，但不是所有内容的唯一创建入口。

## 6. Key Flows

### Meals → Shopping

``` text
Weekly Meal Plan → Recipe / free-text meal → ingredient suggestions
                 → user confirmation → Shopping List
```

用户可以只填写简单 meal，不强迫同时建立完整 Recipe。

### Chore → Today

``` text
Create chore → optional assignee / date / recurrence / reminder
             → Today / Calendar → complete
```

### Event → Today

``` text
Create household event → date / recurrence / reminder
                       → Calendar → Today / notification
```

### Wishlist → Inventory → Maintenance

``` text
Wishlist Item → mark Purchased → offer Add to Inventory
              → choose room or area → Inventory Item
              → add Maintenance Plan → Today / Calendar
```

Wishlist Item 与 Inventory Item 始终保持为独立对象。

### Bilingual Shared Content

``` text
Save original → detect language → generate and cache translation
              → display viewer's preferred language
              → allow View Original
```

翻译不可用时显示原文，不阻止保存、查看和 reminder。

## 7. Domain Boundaries

-   Meal 负责吃什么、人数、recipe 和 servings。
-   Chore 负责日常家务、分配和完成。
-   Event 负责家庭相关的日期、时间和提醒。
-   Inventory 负责记录家中已有物品。
-   Maintenance 负责房屋、区域或具体物品的维护周期和历史。
-   Shopping 负责当前需要购买什么，不发展为库存或仓储系统。

## 8. Conceptual Data Model

``` text
Household
├── HouseholdMember[]
├── HomeLocation[]
├── MealPlan[] → MealPlanEntry[] → optional Recipe
├── Chore[] → ChoreOccurrence[]
├── HouseholdEvent[]
├── ShoppingList → ShoppingItem[]
├── WishlistItem[] → optional InventoryItem
└── InventoryItem[] → MaintenancePlan[] → MaintenanceOccurrence[]
```

Today、Day 和 Calendar 是对按日期相关的 domain records 的查询与呈现，不拥有这些记录。

## 9. Bilingual Architecture

UI localization 和 dynamic content translation 是两个独立系统。

共享自由文本使用一个跨 domain 的可翻译内容能力：

``` text
TranslatableContent
├── originalText
├── originalLanguage
├── sourceRevision
└── Translation[]
    ├── language
    ├── translatedText
    ├── basedOnSourceRevision
    └── status
```

保存操作先保存原文，再生成并缓存翻译。原文修改后旧翻译标记为 stale。机器翻译永远不覆盖原文。

HouseholdMember 包含 name、avatar、display color 和 preferred display language。设备记住当前成员，
用于内容显示和通知语言，不建立正式 account system。

## 10. Visual and Interaction Direction

产品应保持 personal、warm、calm、native 和 low-friction。

-   Today 使用少量 cards 和清晰的 domain sections。
-   Chores、Shopping、Wishlist 和 Inventory 以 list 为主。
-   Meal Planner 使用一周视图。
-   iPhone Calendar 使用月视图和所选日期列表，并提供 domain filters。
-   icon、文字和弱化的颜色共同区分 domain，不依赖单一颜色。
-   成员使用 avatar、name 和稳定 display color 识别。
-   layout 支持中英文长度差异，不使用依赖字符数的固定宽度。

## 11. Deferred Decisions

以下内容尚未确认，并且不需要在当前阶段决定：

-   技术栈和数据存储
-   sync provider
-   Apple Calendar integration
-   ingredient 归一化和高级数量合并
-   recurrence 的完整表达方式
-   机器翻译的手动修正
-   Week A / Week B 是否成为全局 household rhythm
-   iPad 和 Mac 的多栏布局
-   Home Projects 或 Home Documents 等未来模块

上述内容不应在未经用户确认时变成已确认需求。
