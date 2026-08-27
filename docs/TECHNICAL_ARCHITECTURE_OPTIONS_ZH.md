# Oh My House — 技术架构方案比较 v0.1

- **日期：** 2026-08-27
- **阶段：** 技术架构比较
- **状态：** iCloud / CloudKit 云端方向已确认；其他技术细节待确认
- **注意：** 确认云端方向不等于已授权开始写代码

## 1. 先用日常语言解释这个问题

Oh My House 的每条 Chore、Meal 和 Shopping Item，都需要同时存在两个地方：

1. 当前设备里有一份，所以断网时仍然可以使用；
2. 云端有一份，所以其他 iPhone、iPad 和 Mac 也能看到。

“同步”就是在网络恢复后，自动把这些变化对齐。

这里的关键选择不是按钮用什么颜色，而是：云端这份数据由 Apple 的 iCloud 保管，
还是由我们另外建立一套网络服务来保管。

## 2. 方案 A：使用 Apple 的 iCloud（推荐）

### 用户实际会感受到什么

- App 不再要求创建一套 Oh My House 账号和密码；
- 真正在自己设备上使用 App 的人，需要在设备上登录 iCloud；
- 一个人的 iPhone、iPad 和 Mac 自动看到同一份数据；
- 不同 iCloud 用户通过家庭邀请，共同编辑同一个 household；
- 儿童或不使用 App 的家人仍然可以只有 Member 资料，不需要 iCloud 身份。

### 它为什么适合这个项目

- 只服务 iPhone、iPad 和 Mac，和 Apple 的能力范围完全一致；
- 不需要运营独立账号系统、密码找回和家庭服务器；
- Apple 已经提供多设备同步、多人共享、一次性邀请和共享参与者管理；
- 家庭数据存在用户的 iCloud 范围内，比我们自己保管用户账号和数据更符合小型个人项目。

### 需要知道的限制

- 已连接的真实使用者必须有可用的 iCloud 账号；
- 创建 household 的人在 iCloud 底层仍是数据所有者；
- App 可以让其他连接用户具有邀请、移除参与者和编辑数据的能力，但最底层仍存在一个创建者；
- 一次性链接可以直接使用 Apple 的能力，二维码可以表示同一条链接；
- 24 小时失效和短代码需要 App 在 iCloud 中加一层简单验证，不是 Apple 现成界面自动完成的；
- 共享和一次性邀请的较新能力可能影响 App 最低支持的系统版本，需要在正式开发前用小型测试验证。

## 3. 方案 B：自己建立云端服务

“云端服务”可以理解为：除了 App，还有一个长期在网上运行的程序，专门保存数据、
检查谁能加入家庭，并把改动发给其他设备。

### 好处

- 可以完全自定义邀请链接、短代码、过期时间和家庭成员规则；
- 不必依赖 iCloud；
- 如果以后要做 Android 或网页版，比较容易沿用。

### 代价

- 需要建立真实的登录身份，即使界面做得简单，底层也存在账号系统；
- 需要我们自己处理断网编辑、同时修改、数据安全、备份和运行故障；
- 可能产生持续费用，而且项目发布后仍需要维护网上的服务；
- 开发和测试量明显增加，容易把一个家庭 App 慢慢做成一套小型 SaaS。

## 4. 方案 C：iCloud 加一套独立小服务

这个方案让 iCloud 保存家庭数据，再用另一个服务处理短代码或其他特殊功能。

它看似折中，实际上要同时维护两套系统。只要能用 CloudKit 本身完成短代码验证，
第一阶段就不建议选它。

## 5. 我的推荐

建议选择方案 A：使用 Apple 原生能力建立 iPhone、iPad 和 Mac App，并使用 iCloud 保存和共享数据。

原因不是“Apple 技术听起来更高级”，而是它的限制和这个项目的边界正好一致：

- 只需要 Apple 设备；
- 只服务一个小家庭；
- 不想建立正式账号体系；
- 需要离线使用和多设备同步；
- 不想长期运营一个服务器产品。

## 6. 如果选择方案 A，App 大致由什么组成

### 6.1 界面：SwiftUI

SwiftUI 是 Apple 用来构建 App 页面的工具。它能让 iPhone、iPad 和 Mac 共用大部分页面逻辑，
同时允许每种设备保留适合自己的布局。

这一项推荐很明确，但仍然等待和整体架构一起确认。

### 6.2 设备里的数据库：优先考虑 Core Data

“数据库”在这里不是复杂的企业系统，只是 App 在设备上有条理地保存 Meals、Chores 等内容的方式。

Apple 有两种相关工具：

- SwiftData：更新、写起来更简单；
- Core Data：更成熟、代码稍多，但 Apple 对“不同 iCloud 用户共享数据”提供了更直接的官方方案。

因为“家庭成员共同编辑”是核心需求，当前建议优先选成熟度更高的 Core Data，
不只是为了少写一些代码而选更新的工具。

### 6.3 云端和共享：CloudKit

CloudKit 是 Apple 为 App 提供的 iCloud 数据服务。它负责在不同设备间传送改动，
并让不同 iCloud 用户加入同一份家庭数据。

### 6.4 翻译：分为两类

1. App 自己的固定文字，例如 Today、Save 和错误提示，由我们预先写好中文和英文；
2. 用户自己输入的内容，例如一条 Chore，使用 Apple Translation 生成翻译。

用户内容仍然保留原文，生成的翻译与原文一起同步。如果某次翻译不可用，
就显示原文，不阻止用户保存内容。

## 7. 开始写代码前的小型验证

在用户确认技术方向之后，建议先做一个很小的“可行性验证”。

可行性验证不是正式 App，而是一次专门测试最难问题的小实验：

1. 两个不同 iCloud 账号能否共同编辑一个测试 household；
2. 断网后两边改动，恢复网络后是否正确保留；
3. 一次性邀请、二维码、24 小时过期和短代码是否能按已确认流程完成；
4. 数据所有者能否生成和取消邀请，并停止其他使用者访问；
5. 中英文翻译在目标 iPhone、iPad 和 Mac 上是否都可用。

只有这些核心能力实际通过，才开始搭建正式 App。

## 8. 已确认的云端决定

用户已确认：

> 完整的 household 云端数据库保存在家庭创建者自己的 iCloud 中。
> 其他已连接使用者通过 CloudKit 共享访问和编辑同一份数据。

这不等于其他成员登录或共用数据所有者的 iCloud 账号。每个真实使用者使用自己的 iCloud 身份，
并且只获得 Oh My House 所分享的 household 数据权限。

每台设备上仍必须有本地同步副本，否则无法实现已确认的断网使用。这些本地副本不是各自独立的云端数据库。

下一步再确认：

- SwiftUI + Core Data + CloudKit 的组合；
- 可行性验证的具体通过标准。

最低系统版本已经确认为 iOS 18、iPadOS 18 和 macOS 15；只有 household 的 iCloud 所有者管理邀请和停止访问。

## 9. Apple 官方资料

- [SwiftUI](https://developer.apple.com/documentation/swiftui/)
- [使用 SwiftData 在一个人的设备间同步](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices)
- [判断 CloudKit 是否适合 App](https://developer.apple.com/documentation/cloudkit/deciding-whether-cloudkit-is-right-for-your-app)
- [在不同 iCloud 用户之间共享 Core Data 数据](https://developer.apple.com/documentation/coredata/sharing-core-data-objects-between-icloud-users)
- [CloudKit 一次性邀请参与者](https://developer.apple.com/documentation/cloudkit/ckshare/participant/onetimeurlparticipant%28%29)
- [CloudKit 共享管理员](https://developer.apple.com/documentation/cloudkit/ckshare/participantrole/administrator)
- [Apple Translation](https://developer.apple.com/documentation/translation)
