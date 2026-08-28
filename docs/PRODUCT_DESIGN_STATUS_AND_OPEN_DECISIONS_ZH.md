# Household Companion — Product Design Status & Open Decisions v0.1

- **日期：** 2026-08-27
- **阶段：** Product Design
- **状态：** Product Design v0.1 与 Apple 原生方向已确认；第一阶段可行性验证通过
- **目的：** 区分已确认、技术设计阶段再决定、可以以后决定的内容

## 1. 当前结论

产品设计已经不再只是一个概念。四个主 Tab、主要模块、核心跨模块流程、成员、双语和共享家庭同步
都已经有明确方向。

多设备同步的具体体验和通知发送对象已经确认。核心技术组合已经确认为 SwiftUI、Core Data、CloudKit
和 Apple Translation。完整 Xcode 已安装，本地保存与 Apple Translation 真机验证已经通过；
CloudKit、多人共享和离线冲突验证等待用户决定是否加入 Apple Developer Program。

## 2. 已确认的产品基础

### 产品范围

- 服务个人和 2–4 人小家庭；
- 保持 lightweight、personal、small-household-first；
- 不发展成商业 SaaS、家庭 ERP 或复杂工作管理系统。

### 主导航

    Today | Plan | Shopping | Home

### 主要模块

- Meals 与 Recipes；
- Chores；
- Unified Shopping；
- Wishlist → Inventory → Maintenance；
- Household Events；
- Today 与 Calendar；
- Household Members；
- 中英文 UI 与共享内容翻译。
- 每位成员可分别选择四种预设外观风格，以及跟随系统 / 浅色 / 深色模式。
- 跨模块内容遵守统一的修改、删除、解除连接和撤销原则。

### 已确认的重要连接

- Recipe ingredients 经检查后加入 Shopping；
- Shopping 统一 Grocery、Household Supplies 和 Maintenance 来源；
- Purchased Wishlist 可以创建独立 Inventory Item；
- Inventory 可以建立 Maintenance；
- Chores、Maintenance、Events 和 Meals 进入 Today / Calendar；
- Today 与 Calendar 不复制原模块数据。

### 成员与共享

- 成员有名字、头像、颜色和默认语言；
- 头像可以从相册选择；
- 右上角头像用于临时成员切换；
- 成员切换菜单不是 Today 内容；
- 不同成员可以在各自设备上共同编辑同一个家庭；
- 成员资料与真正连接设备的使用者保持区别；
- 使用一次性链接、二维码或短代码邀请；
- 已连接使用者共同编辑，不设置管理员层级；
- 只有持有家庭数据库的 iCloud 所有者管理邀请和停止访问；
- 停止访问与删除成员资料分开。

### 多设备

- iPhone、iPad 和 Mac 必须使用同一个 household 数据；
- 同一个人可以使用自己的多台设备；
- 不同成员也可以使用各自设备共同编辑。

## 3. 已确认的同步与通知行为

### 3.1 同步的具体行为

所有家庭共享数据参与同步，以及以下具体行为均已确认：

1. 当前成员、临时语言、通知权限和当前打开页面保留为每台设备自己的状态；
2. 没有网络时仍可查看和编辑已有内容，恢复后自动同步；
3. 新设备发现已有 household 时优先继续使用，不重新创建；
4. 正常同步不持续显示状态，只有长期失败才提示；
5. 从一台设备同步删除重要内容时，提供确认或恢复机会。

### 3.2 通知发送给谁

多成员各自设备加入后，不能只决定通知使用什么语言，还要决定发到哪些人的设备。

已确认的发送规则：

- 指定负责人的 Chore reminder 发给对应成员连接的设备；
- 多人共同负责时发给所有负责人；
- 无负责人 Chore 不主动推送个人提醒，只在 Today 显示；
- Maintenance 有负责人时发给负责人，无负责人时只在 Today 显示；
- Household Event reminder 默认发给所有已连接家庭使用者；
- Shopping 第一阶段不自动发送通知。

上述同步与通知行为已于 2026-08-27 由用户全部确认。

## 4. 进入技术设计阶段后再决定

这些决定重要，但属于“怎样实现”，现在不应提前定死：

- Apple 平台使用什么同步服务；
- 数据如何存储；
- 实际使用者怎样安全识别；
- 两台设备同时修改同一个字段时怎样合并；
- 自动翻译使用什么服务；
- 原文、翻译和照片怎样在设备间安全同步；
- 数据加密、备份和恢复方式；
- 开源版本怎样配置自己的同步与翻译能力。

## 5. 可以以后决定的产品增强

- App 最终名称；
- iPad 和 Mac 的具体多栏布局；
- Apple Calendar 集成；
- 多个 Event reminder；
- 高级 recurrence；
- ingredient 单位换算；
- pantry / 库存数量；
- 条码扫描、价格和优惠；
- Home Projects、Home Documents；
- 系统桌面小组件；
- 照片附件、收据和保修文件；
- 访客模式和 App 访问锁。

这些内容不会阻碍第一阶段的产品和架构设计。

## 6. 当前不做

- 商业订阅和计费；
- 企业组织与管理员体系；
- 复杂权限矩阵；
- 消费统计 dashboard；
- 仓库式库存管理；
- 工作项目管理；
- 公开社交或内容市场。

## 7. 推荐的下一步

1. 将 Product Design v0.1 作为后续工作的产品基线；
2. 安装完整 Xcode，并确认 Apple Developer Program 状态；
3. 创建最小验证项目，依次验证本地保存、CloudKit 同步、多人共享和翻译；
4. 验证通过并由用户确认后，再开始正式 App。
