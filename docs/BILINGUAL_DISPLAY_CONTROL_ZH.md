# Household Companion — Bilingual Display Control v0.1

- **日期：** 2026-08-27
- **阶段：** Product Design
- **状态：** 入口与具体行为均已由用户确认

## 1. 为什么需要固定入口

每个 Household Member 虽然有首选显示语言，但用户仍然需要随时：

- 临时切换中文或 English；
- 查看机器翻译前的原文；
- 确认某段内容是否经过自动翻译。

因此不能把语言功能只藏在 Settings，也不能只在个别详情页出现。

## 2. 入口位置

每个主要页面、列表、详情和创建 / 编辑页面的顶部显示统一按钮：

    文/A

它通常位于 Household Member avatar 左侧。如果页面右侧还有添加按钮，则三个入口按照空间合理排列。

这个按钮的位置和外观在 Meals、Chores、Shopping、Home、Events、Today 和 Calendar 中保持一致。

## 3. 语言菜单

点击后显示：

    显示语言
    ✓ 中文
      English

    查看共享内容原文
    设为我的默认语言

### 中文 / English

切换后同时改变：

- App 自己的按钮、标题和说明；
- 用户创建内容的可用翻译；
- 系统生成的文字。

这次切换只在当前使用期间有效，不自动改变 Household Member 的 preferred display language。

### 查看共享内容原文

只改变用户创建的内容，例如：

- Chore title；
- Event title；
- Recipe instructions；
- Wishlist description。

App 自己的按钮和标题继续使用当前显示语言。

## 4. 默认行为

打开 App 时仍然使用当前 Household Member 的 preferred display language。

顶部按钮用于临时切换和查看原文，不取代成员默认设置。

如果用户希望永久改变默认语言，可以在菜单中选择“设为我的默认语言”。只有用户主动执行这一步，
才会更新当前 Household Member 的 preferred display language。

## 5. 翻译状态

正常情况下列表只显示所选语言，不反复展示“已翻译”标签。

在详情页查看原文时，可以显示：

- 原文语言；
- 当前是否为自动翻译；
- 翻译是否正在生成；
- 翻译失败时的 retry。

## 6. 已确认的选择

1. 中文 / English 切换同时改变 UI 和可翻译的共享内容；
2. “查看原文”只改变共享内容，保持 UI 语言不变；
3. 顶部按钮的临时语言选择只在当前使用期间有效，下次打开 App 时恢复为成员默认语言；
4. 菜单提供“设为我的默认语言”，由用户主动决定是否永久保存。

上述行为已于 2026-08-27 由用户确认。
