# Oh My House

Oh My House 是一个面向 2–4 人小家庭的轻量 Household Companion。

它希望用一个简单、温暖、低摩擦的 App，协调共同生活中真正需要共享的信息和日常事务。

## 当前状态

项目的 **Product Design v0.1 已确认**。Apple 原生核心技术方向已经确认，准备进入可行性验证；
正式 App 尚未开始开发。

当前确认的核心领域：

- Meals
- Chores
- Shopping
- Home Wishlist
- Home Inventory
- Home Maintenance
- Household Events
- Today / Calendar
- 中英文 UI 与共享内容自动翻译

食谱详情已经接入用户内容翻译：同一份食谱可以混合输入中英文，App 会按当前显示语言翻译菜名、
食材名称和烹饪步骤，同时保留原始输入。

## 文档

- [主需求文档](./HOUSEHOLD_COMPANION_REQUIREMENTS_ZH.md)
- [Product Design Proposal v0.1](./docs/PRODUCT_DESIGN_PROPOSAL_ZH.md)
- [Screen Architecture & Interaction Flows v0.1](./docs/SCREEN_ARCHITECTURE_AND_FLOWS_ZH.md)
- [Core Tab Wireframe Notes v0.1](./docs/CORE_TAB_WIREFRAME_NOTES_ZH.md)
- [Meal Planning → Shopping Flow v0.1](./docs/MEAL_PLANNING_TO_SHOPPING_FLOW_ZH.md)
- [Chore Assignment & Rotation Flow v0.1](./docs/CHORE_ASSIGNMENT_AND_ROTATION_FLOW_ZH.md)
- [Household Events & Reminders Flow v0.1](./docs/HOUSEHOLD_EVENTS_AND_REMINDERS_FLOW_ZH.md)
- [Bilingual Display Control v0.1](./docs/BILINGUAL_DISPLAY_CONTROL_ZH.md)
- [Home Lifecycle Flow v0.1](./docs/HOME_LIFECYCLE_FLOW_ZH.md)
- [Unified Shopping Flow v0.1](./docs/UNIFIED_SHOPPING_FLOW_ZH.md)
- [Today & Calendar Flow v0.1](./docs/TODAY_AND_CALENDAR_FLOW_ZH.md)
- [Household Members Flow v0.1](./docs/HOUSEHOLD_MEMBERS_FLOW_ZH.md)
- [Multi-device Sync Product Requirements v0.1](./docs/MULTI_DEVICE_SYNC_PRODUCT_REQUIREMENTS_ZH.md)
- [Shared Household Join Flow v0.1](./docs/SHARED_HOUSEHOLD_JOIN_FLOW_ZH.md)
- [Product Design Status & Open Decisions v0.1](./docs/PRODUCT_DESIGN_STATUS_AND_OPEN_DECISIONS_ZH.md)
- [Notification Delivery Rules v0.1](./docs/NOTIFICATION_DELIVERY_RULES_ZH.md)
- [Technical Architecture Options v0.1](./docs/TECHNICAL_ARCHITECTURE_OPTIONS_ZH.md)
- [Apple Native Architecture Proposal v0.1](./docs/APPLE_NATIVE_ARCHITECTURE_PROPOSAL_ZH.md)
- [Feasibility Validation Plan v0.1](./docs/FEASIBILITY_VALIDATION_PLAN_ZH.md)

`HOUSEHOLD_COMPANION_REQUIREMENTS_ZH.md` 是当前阶段的 source of truth。

## 已确认的 Primary Navigation

``` text
Today | Plan | Shopping | Home
```

本项目保持 personal、lightweight 和 small-household-first，不会被设计成商业 SaaS、家庭 ERP
或复杂的 productivity suite。
