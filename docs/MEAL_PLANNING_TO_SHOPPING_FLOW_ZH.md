# Household Companion — Meal Planning → Shopping Flow v0.1

- **日期：** 2026-08-27
- **阶段：** Product Design
- **状态：** 核心流程已由用户确认
- **范围：** 从安排一周餐食，到把 Recipe ingredients 加入统一 Shopping List

## 1. 要解决的问题

这个过程需要同时满足：

- 用户可以很快写下“这顿吃什么”；
- 不强迫每顿饭都创建完整 Recipe；
- 使用 Recipe 时，可以根据人数准备需要购买的食材；
- 食材不会未经确认自动塞进 Shopping；
- Shopping Item 保留来自哪顿饭、哪份 Recipe 的信息。

## 2. 推荐流程

### 第一步：查看一周餐食

iPhone 使用从周一到周日的纵向列表，每天显示 Lunch、Dinner 等餐食位置。

这种方式仍然能看到完整一周，同时给餐食名称留下足够空间。iPhone 不使用七列横向表格，因为文字会过于拥挤。

iPad 和 Mac 的较大屏幕布局可以以后再决定。

### 第二步：添加一顿饭

点击空的餐食位置后，用户可以：

1. 直接写下这顿饭；
2. 从 Recipes 中选择；
3. 重复最近吃过的一顿饭。

“直接写下”只需要一个名称，例如“煮面”“外出吃饭”或“吃剩菜”，不要求补全 Recipe。

### 第三步：确认人数和份数

如果选择了 Recipe，用户可以确认：

- 哪些家庭成员一起吃；
- 需要做几份。

默认选择全部家庭成员，用户只在有人不吃时调整。

份数用于计算 Recipe ingredients。家庭成员人数和份数可以不同，例如两个人吃但做四份，用作第二天午餐。

### 第四步：检查食材

Recipe ingredients 在加入 Shopping 前必须经过用户确认。

用户可以：

- 取消家里已经有的食材；
- 修改数量文字；
- 看到 Shopping 中已有的明显重复项；
- 选择是否合并重复项。

当前只做简单的重复提示，不建立复杂的食材名称标准库或单位换算系统。

### 第五步：加入 Shopping

确认后的食材进入统一 Shopping List，并保留：

- 来源为 Meals；
- 对应日期和 meal；
- 对应 Recipe。

例如：

    牛肉 500g
    来源：周四晚餐 · 番茄炖牛肉

## 3. 简单餐食与 Recipe 的区别

### 简单餐食

只记录“吃什么”，适合：

- 外出吃饭；
- 吃剩菜；
- 临时决定；
- 用户不想建立 Recipe 的普通餐食。

第一阶段不根据简单餐食名称自动猜测 ingredients。

### Recipe

保存 servings、ingredients 和制作内容，可以：

- 重复使用；
- 根据份数调整 ingredients；
- 生成待确认的 Shopping Items；
- 在中英文成员之间显示翻译后的内容。

简单餐食以后可以选择转换或关联到 Recipe，但创建时不强迫转换。

## 4. 重复 Shopping Item

当新 Recipe ingredient 与 Shopping 中已有内容明显相同时，系统只提出建议：

    Shopping 已有“米”
    [合并] [仍然分开]

不建议第一阶段自动合并，因为：

- 名称相同不一定是同一种商品；
- 单位可能不同；
- 用户可能确实需要分别购买；
- 自动判断错误会降低信任。

## 5. 双语显示

- Meal name、Recipe title、instructions 和适合翻译的 notes 使用共享内容翻译能力；
- ingredient name 可以显示为当前成员首选语言；
- 数量、单位、品牌和型号不做机械翻译；
- Shopping Item 保留来源关系，不把翻译后的文字复制成一份新的业务记录。

## 6. 已确认的选择

### 6.1 iPhone 一周视图

使用从周一到周日的纵向列表，每天显示 Lunch / Dinner；不在 iPhone 上使用七列横向表格。

### 6.2 餐食创建方式

同时支持“只写餐食名称”“选择 Recipe”“重复最近餐食”三种方式。

### 6.3 默认参与成员

新增餐食时默认选择所有家庭成员，需要时再取消某位成员。

### 6.4 食材进入 Shopping

Recipe ingredients 必须经过一次简单确认后才能加入 Shopping，不自动加入。

### 6.5 简单餐食不猜测 ingredients

第一阶段不根据“咖喱饭”“煮面”等自由文本自动猜测需要购买的食材。

## 7. 可以以后决定

- Breakfast、Snack 等其他 meal slot 的默认显示；
- iPad / Mac 的周视图；
- 更复杂的 servings 换算；
- ingredient 单位换算；
- pantry / 家庭库存扣减；
- 根据自由文本自动建议 ingredients；
- 营养信息；
- Recipe 导入方式。

这些问题不会阻碍当前流程的设计。
