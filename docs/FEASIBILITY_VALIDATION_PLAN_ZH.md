# Oh My House — 可行性验证计划 v0.1

- **日期：** 2026-08-27
- **阶段：** 技术可行性验证准备
- **状态：** 范围已确认；等待安装 Xcode，Apple Developer Program 尚未加入
- **目标：** 在正式 App 开发前验证最难、风险最高的 Apple 技术能力

## 1. 这不是正式 App

这一步只制作一个很小的测试程序。

它不会包含完整的 Today、Plan、Shopping、Home 页面，也不会在视觉设计上投入大量时间。
它只回答一个问题：

> 已确认的 iCloud 共享、离线使用、邀请和翻译方案能否可靠工作？

如果答案是否定的，应该先调整技术方案，而不是等完整 App 做完后再返工。

## 2. 已确认的测试技术

- SwiftUI：显示最少量的测试页面和按钮；
- Core Data：在设备中保存测试 household 和少量测试项目；
- CloudKit：同步到数据所有者的 iCloud，并共享给另一位用户；
- Apple Translation：测试中文和英文内容；
- 最低系统版本：iOS 18、iPadOS 18、macOS 15。

## 3. 开始前必须准备

### 3.1 完整 Xcode

当前 Mac 只有 Command Line Tools，没有完整 Xcode，因此不能创建、签名或运行 Apple App。

当前 macOS 15.7.8 满足 Xcode 26 对 macOS 15.6 或更高版本的要求，不需要升级到 macOS 26。
Xcode 需要由用户通过 Apple 官方渠道安装。

### 3.2 Apple 开发者账号

CloudKit 需要为 App 建立专用的 iCloud container，也就是只属于 Oh My House 的云端数据空间。
Apple 官方文档说明，启用这项能力需要有效的 Apple 开发者账号和相应权限。

Apple Developer Program 当前公开价格为每年 99 美元，具体以注册时显示的当地货币价格为准。
用户目前尚未加入。可以先免费准备 Xcode 和本地验证，但在测试 CloudKit 前必须由用户自行决定并完成加入；
项目不会自行购买或注册。

### 3.3 两个 iCloud 使用者

多人共享至少需要：

- 数据所有者的 iCloud；
- 另一位家庭成员自己的 iCloud。

不需要向项目文档或 Git 仓库写入账号、密码、验证码或其他秘密信息。

### 3.4 实际设备

建议至少准备：

- 当前 Mac；
- 一台运行 iOS 18 或更高版本的 iPhone；
- 如果需要验证 iPad 布局和同步，再准备一台运行 iPadOS 18 或更高版本的 iPad。

多人邀请和 iCloud 账号切换优先在真实设备上测试，不只依赖模拟器。

## 4. 验证步骤

### 第一步：本地保存

建立最小测试数据：

- 一个 Household；
- 两个 Member；
- 两条测试 Item。

关闭并重新打开测试程序后，数据必须仍然存在。断网时必须可以新增和修改。

### 第二步：所有者的多设备同步

使用数据所有者的同一个 iCloud，在两台设备上打开测试 household。

一台设备新增内容后，另一台设备应自动看到；不要求用户导出、导入或手动复制文件。

### 第三步：不同 iCloud 用户共享

数据所有者生成一次性邀请，第二位 iCloud 用户接受后看到同一个 household。

第二位用户修改普通内容后，数据所有者和其他参与设备都应看到变化。

### 第四步：邀请形式和访问管理

验证同一个邀请可以表现为：

- 分享链接；
- 屏幕二维码；
- 手动输入的短代码。

邀请只能使用一次，可以由数据所有者取消，并在 24 小时后拒绝加入。
只有数据所有者看到生成邀请和停止访问入口。

### 第五步：离线修改与冲突

两台设备断网后分别修改不同项目，联网后两项修改都必须保留。

两台设备修改同一个项目时，不能静默删除整条记录。具体选择哪一个字段值可以以后完善，
但测试必须确认不会造成整条 household 数据损坏。

### 第六步：头像

从相册为 Member 选择一张头像，确认它可以同步到另一台设备。

验证测试资料和截图不得把用户私人照片提交到 Git 仓库。

### 第七步：中英文翻译

分别输入中文和英文测试内容：

- 原文必须永久保留；
- 翻译成功后与原文一起同步；
- 翻译暂时不可用时仍能保存和显示原文；
- 页面保留已确认的“文/A”切换入口。

## 5. 通过标准

只有以下条件全部满足，才进入正式 App 开发：

1. 本地数据在重新打开和断网时可靠保留；
2. 同一所有者的多台设备可以同步；
3. 第二位 iCloud 用户可以通过邀请加入和共同编辑；
4. 邀请的一次性、取消和过期规则可实现；
5. 只有数据所有者管理访问；
6. 离线修改恢复后不会丢失整条记录；
7. 头像可以安全同步；
8. 中英文原文和翻译可以按规则显示与同步；
9. iPhone、iPad、Mac 的核心能力一致。

## 6. 验证结果怎样记录

每项测试记录：

- 通过；
- 未通过；
- 有限制但可以接受；
- 需要调整产品规则。

测试数据使用虚构名字和示例照片。账号信息、设备验证码、签名文件和其他秘密内容不进入 Git。

验证结束后提交一份简短结果报告，再由用户决定是否开始正式 App。

## 7. 当前下一步

1. 用户安装完整 Xcode；
2. 免费验证本地保存和 Apple Translation；
3. 用户在开始 CloudKit 验证前加入 Apple Developer Program；
4. 再验证 iCloud 与多人共享。

在 Xcode 安装完成前，不创建无法运行和验证的项目代码。

## 8. Apple 官方资料

- [Xcode 系统要求](https://developer.apple.com/xcode/system-requirements)
- [配置 iCloud 服务](https://developer.apple.com/documentation/xcode/configuring-icloud-services)
- [CloudKit Shared Records](https://developer.apple.com/documentation/cloudkit/shared-records)
- [Apple Developer Program 注册与费用](https://developer.apple.com/programs/enroll/)
