# Oh My House — Apple 原生技术架构提案 v0.1

- **日期：** 2026-08-27
- **阶段：** 技术架构设计
- **状态：** 核心技术组合、最低系统版本与验证计划均已确认；等待开发环境准备
- **范围：** iPhone、iPad、Mac；不包含 Android 或网页版
- **注意：** 本文档不授权开始正式 App 开发

## 1. 推荐结论

建议使用以下组合：

- **SwiftUI** 负责 App 页面；
- **Core Data** 负责在每台设备上保存可离线使用的数据；
- **CloudKit** 负责把数据保存在家庭创建者的 iCloud，并共享给其他成员；
- **Apple Translation** 负责中英文用户内容翻译；
- **Apple 本地通知** 负责 Chore、Maintenance 和 Event reminder。

整体关系可以理解为：

~~~ text
Today / Plan / Shopping / Home 页面
                 ↕
        设备内的 Core Data
       （断网时仍可使用）
                 ↕
          CloudKit 自动同步
                 ↕
      你的 iCloud 中的家庭数据
                 ↕
       其他成员的设备共享访问
~~~

## 2. SwiftUI 是什么

SwiftUI 是用来制作 App 页面的工具。

选择它的实际原因是：

- Today 卡片、Shopping List 和 Home 页面可以在三种设备上共用大部分代码；
- iPhone 可以使用底部 Tab，iPad 和 Mac 可以在大屏幕上自然展开；
- 相册选择、日期、通知和翻译等 Apple 功能更容易保持一致；
- 不需要分别建立一套 iPhone 界面和一套 Mac 界面。

除非以后改成同时支持 Android，否则这项选择没有明显的产品代价。

## 3. 为什么推荐 Core Data，而不是更新的 SwiftData

Core Data 和 SwiftData 都是“设备内的数据整理工具”。

SwiftData 更新、代码更简洁，但 Apple 官方对它的自动 iCloud 同步说明主要聚焦于
“同一个人的多台设备”。

Core Data 的代码会多一些，但 Apple 提供了完整的 Core Data + CloudKit 多用户共享方案，包括：

- 家庭创建者保存原始数据；
- 其他 iCloud 用户加入；
- 每台设备保留本地副本；
- 参与者共同修改；
- 取消共享或停止某人访问。

这个 App 的难点是“共享不能丢数据”，不是“尽量少写几行代码”。
因此当前推荐选择成熟、并且有直接官方参考的 Core Data。

## 4. CloudKit 怎样保存这个家庭

你创建 household 后：

~~~ text
你的 iCloud private database
└── Oh My House household
    ├── Members
    ├── Meals / Recipes
    ├── Chores
    ├── Shopping
    ├── Wishlist / Inventory / Maintenance
    └── Events
~~~

这一份 household 作为一个整体共享。其他成员看到的是这一份共享数据，
不是你的其他 iCloud 内容。

## 5. 最低系统版本

### 已核实的 Apple 版本要求

- 一次性邀请链接：iOS / iPadOS 18，macOS 15；
- 允许非所有者继续邀请其他人：iOS / iPadOS / macOS 26；
- Apple Translation 框架：iOS / iPadOS 17.4，macOS 14.4。

用户已经确认由持有 household 数据的 iCloud 所有者管理邀请和停止访问，其他成员不管理访问。
因此不需要依赖系统 26 才提供的共同访问管理能力。

> Oh My House 最低支持 iOS 18、iPadOS 18 和 macOS 15。

这组版本可以支持一次性 CloudKit 邀请、Core Data 多用户共享和 Apple Translation，
同时支持当前这台运行 macOS 15.7.8 的 Mac。

### 当前设备情况

当前用于项目的 Mac 是 M2 MacBook Air，目前运行 macOS 15.7.8，可以直接作为目标设备，
不要求为了使用 Oh My House 升级到 macOS 26。

## 6. 为什么选择系统 18 / 15

这项选择保留了家庭真正需要的能力：

- 数据所有者可以创建一次性邀请；
- 其他成员可以加入并共同编辑日常内容；
- 每台设备可以保留本地数据并同步；
- 用户内容可以中英文翻译；
- 当前 macOS 15.7.8 可以运行。

代价是只有 iCloud 数据所有者管理邀请和停止访问。用户已经接受这一点，
而且它和“完整数据库只存在于自己的 iCloud”这一要求保持一致。

## 7. 正式 App 开发前的可行性验证

“可行性验证”是一个只测试最难技术问题的小程序，不是正式 App。

建议它必须通过以下测试：

1. 你的 iCloud 创建一份测试 household；
2. 另一个 iCloud 用户通过一次性链接加入；
3. 同一链接可显示为二维码，并可通过短代码找到；
4. 邀请只能使用一次，可取消，并在 24 小时后拒绝加入；
5. 数据所有者能够取消邀请和停止其他成员访问，非所有者没有访问管理入口；
6. 两个用户在断网时修改不同数据，恢复后两项改动都保留；
7. 两个用户修改同一项内容时，不丢掉整条记录；
8. 成员头像能从相册加入并在其他设备显示；
9. 中英文用户内容可以翻译，原文和翻译都能同步；
10. 在 iPhone、iPad 和 Mac 上都能打开同一份测试 household。

如果其中任何核心测试失败，应该先回到架构选择，不直接开始搭建全部 App。

## 8. 现在需要确认的内容

### 决定 A：开发工具组合（已确认）

> SwiftUI + Core Data + CloudKit + Apple Translation

这项决定已于 2026-08-27 由用户确认。

### 决定 B：最低系统版本（已确认）

> iOS 18 + iPadOS 18 + macOS 15

这项决定已于 2026-08-27 由用户确认。

### 决定 C：是否先做可行性验证（已确认）

用户已确认先做可行性验证。验证通过后，才制作正式 App 结构。

当前设备尚未安装完整 Xcode。CloudKit 能力还需要可用的 Apple 开发者账号权限，
因此验证将在这些前提准备完成后开始。

## 9. Apple 官方依据

- [SwiftUI 官方说明](https://developer.apple.com/documentation/swiftui/)
- [SwiftData 跨个人多设备同步](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices)
- [Core Data + CloudKit 多用户共享](https://developer.apple.com/documentation/coredata/sharing-core-data-objects-between-icloud-users)
- [CloudKit Shared Records](https://developer.apple.com/documentation/cloudkit/shared-records)
- [CloudKit 一次性邀请](https://developer.apple.com/documentation/cloudkit/ckshare/participant/onetimeurlparticipant%28%29)
- [CloudKit 允许参与者邀请其他人](https://developer.apple.com/documentation/cloudkit/ckallowedsharingoptions/allowsparticipantstoinviteothers)
- [Apple Translation](https://developer.apple.com/documentation/translation)
- [macOS 26 支持的 Mac 型号](https://support.apple.com/en-us/122727)
