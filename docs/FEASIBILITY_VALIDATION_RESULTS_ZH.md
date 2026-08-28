# Oh My House — 可行性验证结果（进行中）

- **日期：** 2026-08-28
- **范围：** 本地保存与 Apple Translation
- **状态：** 第一阶段完成；本地保存与 Apple Translation 均已通过

## 已完成

### iPhone、iPad 与 Mac 编译

- iPhone 模拟器版本：通过；
- Mac 版本：通过；
- 使用最低系统版本设置：iOS / iPadOS 18、macOS 15。

### 实际启动

测试程序已经安装并成功启动于 iPhone 17 Pro（iOS 26.5）模拟器。
随后使用 Xcode Personal Team 安装并成功启动于 iPhone 14 Pro（iOS 26.6.1）真实设备。

### 本地保存

自动检查执行了以下过程：

1. 建立临时的本地数据库；
2. 写入一条虚构测试内容；
3. 关闭第一次数据库连接；
4. 用新的连接重新打开同一个数据库；
5. 成功读回原测试内容。

结果：**通过**。

真实 iPhone 上还进行了组合检查：把原文和翻译结果保存后，完全关闭并重新打开测试程序，
“买牛奶”和“Buy milk”仍然存在。

结果：**通过**。

## Apple Translation

在 iOS 26.5 模拟器中触发 Apple Translation 时，系统明确提示：模拟设备不支持翻译，
必须在真实设备上测试。这是模拟器能力限制，不代表翻译方案失败。

用户使用自己的 Apple Account，通过 Xcode Personal Team 把测试程序安装到 iPhone 14 Pro，
并完成以下真机检查：

- 中文原文：“买牛奶”；
- 英文翻译：“Buy milk”；
- 状态显示“翻译成功；原文仍然保留”；
- 保存后关闭并重新打开程序，原文和译文仍然存在。

结果：**通过**。

## 下一阶段尚未开始

- iCloud / CloudKit 同步；
- 不同 iCloud 用户共享；
- 离线冲突；
- 成员头像同步。

这些项目需要 Apple Developer Program 和实际设备，当前测试程序没有启用相关能力。
