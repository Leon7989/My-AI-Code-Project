# 新疆高考 AI 志愿助手
# UI Specification / High Fidelity V1.0

- **文件名：** `07-ui-specification.md`
- **版本：** V1.0
- **阶段：** Step 7
- **上游：** `00-project-master-context.md`、`00-decision-register.md`、`01-prd.md`、`02-xinjiang-business-rules.md`、`03-system-architecture.md`、`04-database-design.md`、`05-api-contract.md`、`06-information-architecture.md`
- **适用端：** 原生微信小程序 + Admin Web
- **状态：** COMPLETED

---

# 0. 文档目的

本文件将 Step 6 Information Architecture 转换为可实施 UI 规范。

本文件解决：

- Design Tokens；
- Color / Typography / Spacing / Radius / Shadow；
- 微信小程序布局；
- Admin Web 布局；
- 导航、表单、列表、状态组件；
- Assessment Wizard；
- Recommendation 结果；
- REACH / MATCH / SAFE / WATCH 视觉语言；
- Risk 视觉语言；
- Evidence / Explainability；
- Membership / Paywall；
- Payment Server Confirmation；
- AI Analysis；
- Admin Table / Filter / Pagination；
- Admin 高风险变更；
- zh-CN / ug-CN 双语；
- RTL；
- Loading / Empty / Error / Degraded；
- P0 High Fidelity Page Specs。

本文件不是新的 PRD、业务规则、数据库设计或 API 设计。

---

# 1. Conflict Report

## 1.1 结论

```text
CONFLICT_REPORT_STATUS = NO_BLOCKING_CONFLICT
```

未发现阻断 Step 7 的冻结决策冲突。

## 1.2 保持开放，不在 UI 层擅自解决

| ID | 事项 | 当前状态 | UI 处理 |
|---|---|---|---|
| OD-001 | 产品正式名称 | OPEN | 使用项目工作名，不制作不可逆品牌资产 |
| OD-002 | 永久会员价格 | OPEN | 价格组件支持服务端配置，不写死 |
| OD-007 | 支付能力 | GATE-0 OPEN | 支付入口可展示能力状态，不承诺真实支付已上线 |
| OD-008 | 维吾尔语人工审校资源 | OPEN | 标注翻译审校工作流，不宣称全部已人工核验 |
| OD-009 | 招生数据来源与授权 | CRITICAL OPEN | 数据证据页保留来源/版本位，不伪造来源 |
| OD-010 | 2026 单列类政策冲突 | REQUIRES_POLICY_RECONCILIATION | 使用显式 Policy Warning，不由 AI 给结论 |

## 1.3 冻结决策保持性

本 UI 不得破坏：

- 新疆单地区定位；
- zh-CN / ug-CN；
- ug-CN RTL；
- 2026 `TRADITIONAL_WENLI`；
- 2027 `XJ_3_1_2` 预留；
- User / Candidate 分离；
- Profile Versioning；
- Eligibility 非 Boolean；
- Recommendation 最小单位 `AdmissionPlanItem`；
- `REACH / MATCH / SAFE / WATCH`；
- 不输出未经校准精确录取概率；
- `QuotaAccount + QuotaLedger`；
- `request_hash + idempotency_key`；
- `Membership + Entitlement`，禁止 `user.vip`；
- AI 只解释，不突破 Hard Rule；
- 支付成功必须服务端确认。

---

# 2. UI Design Principles

## 2.1 Trust Before Excitement

高考志愿属于高风险决策。

视觉优先级：

```text
可信
>
清晰
>
可解释
>
高效
>
营销感
```

禁止：

- 夸张“上岸率”；
- “稳录”“包录”；
- 伪概率；
- 赌博式转盘；
- 红色倒计时恐吓；
- 把 AI 包装成权威政策源。

## 2.2 Decision First

页面首屏先回答：

- 我现在该做什么？
- 当前方案是否完整？
- 推荐结果有哪些关键风险？
- 下一步是什么？

## 2.3 Evidence Visible

重要结论旁必须有：

- 依据；
- 数据年份；
- 规则年度；
- 风险说明；
- 可展开证据。

## 2.4 Color Is Not Meaning Alone

冲稳保与风险不能只靠颜色。

必须同时使用：

- 文本标签；
- 图标；
- 形状或边框；
- 辅助说明。

## 2.5 Progressive Disclosure

默认展示人能理解的结论。

版本号、算法版本、Snapshot Hash 等进入“查看依据 / 技术详情”。

## 2.6 Bilingual by Construction

双语不是上线前翻译补丁。

组件从一开始支持：

- 文本扩张；
- RTL；
- 混合数字；
- 长院校名；
- 长政策标题；
- 双向箭头。

---

# 3. Design Token Architecture

Token 分四层：

```text
Primitive Token
↓
Semantic Token
↓
Component Token
↓
Page Token
```

禁止页面直接大量硬编码 Hex。

建议代码组织：

```text
packages/design-tokens/
├── primitive.ts
├── semantic.ts
├── mini-program.ts
├── admin.ts
├── rtl.ts
└── index.ts
```

---

# 4. Primitive Color Tokens

> 颜色数值为 V1.0 设计基线。未来品牌正式命名确定后可在不改变语义层的前提下换肤。

## 4.1 Neutral

```text
neutral-0    #FFFFFF
neutral-25   #FCFCFD
neutral-50   #F8FAFC
neutral-100  #F1F5F9
neutral-200  #E2E8F0
neutral-300  #CBD5E1
neutral-400  #94A3B8
neutral-500  #64748B
neutral-600  #475569
neutral-700  #334155
neutral-800  #1E293B
neutral-900  #0F172A
neutral-950  #020617
```

## 4.2 Primary

主色用于：主要 CTA、选中态、链接、关键进度。

```text
primary-50   #EFF6FF
primary-100  #DBEAFE
primary-200  #BFDBFE
primary-300  #93C5FD
primary-400  #60A5FA
primary-500  #3B82F6
primary-600  #2563EB
primary-700  #1D4ED8
primary-800  #1E40AF
primary-900  #1E3A8A
```

## 4.3 Success

```text
success-50   #ECFDF5
success-100  #D1FAE5
success-500  #10B981
success-600  #059669
success-700  #047857
```

## 4.4 Warning

```text
warning-50   #FFFBEB
warning-100  #FEF3C7
warning-500  #F59E0B
warning-600  #D97706
warning-700  #B45309
```

## 4.5 Danger

```text
danger-50    #FEF2F2
danger-100   #FEE2E2
danger-500   #EF4444
danger-600   #DC2626
danger-700   #B91C1C
```

## 4.6 Info / Purple

```text
info-50      #F5F3FF
info-100     #EDE9FE
info-500     #8B5CF6
info-600     #7C3AED
info-700     #6D28D9
```

---

# 5. Semantic Color Tokens

## 5.1 Background

```text
bg-page              neutral-50
bg-surface           neutral-0
bg-surface-raised    neutral-0
bg-subtle            neutral-100
bg-mask              rgba(15, 23, 42, 0.48)
```

## 5.2 Text

```text
text-primary          neutral-900
text-secondary        neutral-600
text-tertiary         neutral-500
text-disabled         neutral-400
text-inverse          neutral-0
text-link             primary-600
```

## 5.3 Border

```text
border-default        neutral-200
border-strong         neutral-300
border-focus          primary-500
border-danger         danger-500
```

## 5.4 Action

```text
action-primary-bg         primary-600
action-primary-hover      primary-700
action-primary-pressed    primary-800
action-primary-disabled   neutral-200
```

---

# 6. Recommendation Tier Visual Language

## 6.1 原则

Tier 是推荐策略，不是录取承诺。

禁止：

```text
SAFE = 保证录取
MATCH = 录取概率 80%
REACH = 不可能
```

## 6.2 REACH / 冲

语义：冲刺。

```text
Tier Code       REACH
中文            冲
主视觉色        info-600
浅背景          info-50
图标            upward-trend / rocket-outline
形状            左侧 4px 强调条 + 标签
```

辅助文案：

> 相对更具挑战，建议结合风险依据谨慎配置。

## 6.3 MATCH / 稳

```text
Tier Code       MATCH
中文            稳
主视觉色        primary-600
浅背景          primary-50
图标            balance / target
```

辅助文案：

> 与当前条件相对匹配，仍需结合年度变化与专业条件判断。

## 6.4 SAFE / 保

```text
Tier Code       SAFE
中文            保
主视觉色        success-600
浅背景          success-50
图标            shield-check
```

辅助文案：

> 相对更偏保守配置，但不代表保证录取。

## 6.5 WATCH / 观察

```text
Tier Code       WATCH
中文            观察
主视觉色        warning-600
浅背景          warning-50
图标            eye / alert-circle
```

辅助文案：

> 数据、可比性或资格条件需要额外核验，不直接归入冲稳保。

## 6.6 Tier Chip

尺寸：

```text
height          24px / 48rpx
padding-inline  8px
radius          999px
font-size       12px
font-weight     600
```

必须包含文字。

---

# 7. Risk Visual Language

Risk 与 Tier 是两套不同语义，不得混淆。

```text
Tier = 推荐组合策略
Risk = 风险等级
```

## 7.1 Risk Levels

| Risk | 中文 | 色彩语义 | 图标 |
|---|---|---|---|
| VERY_HIGH | 很高 | danger-700 | alert-octagon |
| HIGH | 高 | danger-600 | alert-triangle |
| MEDIUM | 中 | warning-600 | alert-circle |
| LOW | 低 | primary-600 | info |
| VERY_LOW | 很低 | success-600 | shield-check |
| INSUFFICIENT_DATA | 数据不足 | neutral-600 | database-question |
| NON_COMPARABLE | 不可直接比较 | info-600 | split / compare-off |

## 7.2 风险条

禁止类似股票“涨跌”表达。

使用：

```text
[文字等级] + [解释] + [查看依据]
```

不使用仅有 1～5 格颜色条作为唯一信息。

---

# 8. Typography

## 8.1 字体策略

小程序：

```text
font-family:
- system-ui
- -apple-system
- BlinkMacSystemFont
- "PingFang SC"
- "Noto Sans CJK SC"
- sans-serif
```

Admin：同上。

维吾尔语：优先操作系统可用的高可读阿拉伯字母字体；正式上线前必须在目标真机验证字形与连写。

建议 fallback：

```text
"Noto Sans Arabic"
"Noto Naskh Arabic"
system-ui
sans-serif
```

不得把未确认授权字体打包进仓库。

## 8.2 Mini Program Type Scale

```text
Display       28px / 56rpx  700  line-height 1.25
H1            24px / 48rpx  700  1.3
H2            20px / 40rpx  700  1.35
H3            18px / 36rpx  600  1.4
Body-L        17px / 34rpx  400  1.55
Body-M        16px / 32rpx  400  1.55
Body-S        14px / 28rpx  400  1.5
Caption       12px / 24rpx  400  1.45
```

## 8.3 Admin Type Scale

```text
Page Title    24px  600
Section       18px  600
Card Title    16px  600
Body          14px  400
Small         13px  400
Caption       12px  400
```

## 8.4 数字

分数、位次、金额使用 tabular numbers（可用时）。

位次展示：

```text
8,120
```

而不是：

```text
8120
```

---

# 9. Spacing Tokens

基于 4px 网格。

```text
space-0    0
space-1    4px
space-2    8px
space-3    12px
space-4    16px
space-5    20px
space-6    24px
space-8    32px
space-10   40px
space-12   48px
space-16   64px
```

小程序对应 rpx 可按 2 倍换算作为设计基线。

---

# 10. Radius Tokens

```text
radius-xs     4px
radius-sm     8px
radius-md     12px
radius-lg     16px
radius-xl     20px
radius-full   999px
```

建议：

- Input：12px；
- Card：16px；
- Bottom Sheet 顶部：20px；
- Chip：full。

---

# 11. Shadow Tokens

小程序避免过度阴影。

```text
shadow-sm  0 1px 2px rgba(15,23,42,.06)
shadow-md  0 4px 12px rgba(15,23,42,.08)
shadow-lg  0 12px 32px rgba(15,23,42,.12)
```

边界优先使用 `border-default`，阴影用于浮层与提升层级。

---

# 12. Motion Tokens

```text
motion-fast      120ms
motion-normal    200ms
motion-slow      320ms
```

Easing：

```text
ease-out   cubic-bezier(.2,.8,.2,1)
ease-in    cubic-bezier(.4,0,1,1)
```

禁止对关键政策/风险信息使用跳动吸睛动画。

---

# 13. Mini Program Layout

## 13.1 Viewport

以 375px 逻辑宽度设计基线，兼容常见微信小程序设备。

## 13.2 Page Padding

```text
mobile-page-padding-inline = 16px / 32rpx
```

大屏手机可保持 16～20px。

## 13.3 Content Width

普通页面：全宽减 padding。

结果详情长文：

```text
max readable line length ≈ 32～38 个中文字符
```

## 13.4 Safe Area

底部 CTA：

```text
padding-bottom:
max(12px, env(safe-area-inset-bottom))
```

## 13.5 Sticky Action

Assessment、支付确认、提交推荐可使用底部 Sticky CTA。

必须保证正文末尾有对应占位，不遮挡内容。

---

# 14. Admin Web Layout

## 14.1 Shell

```text
Top Header
+
Left Sidebar
+
Main Content
```

建议：

```text
sidebar expanded     240px
sidebar collapsed     64px
header                 56px
content max-width    none for tables
content padding       24px
```

## 14.2 Page Header

包含：

- Breadcrumb；
- Page Title；
- Description（可选）；
- Primary Action；
- Secondary Actions。

## 14.3 Density

后台默认中密度。

表格行：

```text
48px default
40px compact
```

---

# 15. Navigation Components

## 15.1 Mini Program TabBar

固定四项：

```text
首页
院校
推荐
我的
```

要求：

- 图标 + 文字；
- 选中态不得仅颜色变化；
- ug-CN RTL 下保持逻辑目标不变；
- Tab 顺序如需镜像，必须在真机可用性测试确认，V1.0 默认保持产品定义顺序并镜像图标方向性元素。

## 15.2 Top Navigation

标准：

```text
Back
Title
Optional Action
```

返回图标 RTL 镜像。

## 15.3 Admin Sidebar

一级：

```text
工作台
用户与考生
政策与规则
数据治理
招生数据
推荐审计
会员与商业
AI 与 Prompt
内容与翻译
系统审计
```

禁止按数据库表机械生成菜单。

---

# 16. Button Component

## 16.1 Variants

```text
Primary
Secondary
Tertiary
Danger
Text
```

## 16.2 Sizes

Mobile：

```text
Large   48px
Medium  44px
Small   36px
```

主要 CTA 优先 Large。

## 16.3 States

```text
Default
Pressed
Disabled
Loading
```

Loading 时：

- 保持按钮宽度；
- 禁止重复触发；
- 文案可切为“提交中…”；
- Recommendation 的重复点击由前端阻止，但业务幂等仍以服务端为准。

---

# 17. Input Components

## 17.1 Text Field

结构：

```text
Label
Input
Helper / Error
```

Label 不得只使用 Placeholder 代替。

## 17.2 Number Field

适用：

- 分数；
- 位次；
- 学费预算。

位次必须允许粘贴并格式化。

## 17.3 Select

移动端优先：

- Bottom Sheet；
- Picker。

后台优先：

- Select；
- Cascader（确有层级时）。

## 17.4 Radio

Eligibility 用户输入：

```text
是
否
不确定
```

“不确定”不是次要灰色选项，必须等权可见。

## 17.5 Error

```text
字段边框
+
错误图标
+
明确错误文字
```

不只变红。

---

# 18. Form Validation

## 18.1 Timing

- 首次输入前不报错；
- Blur 后字段级校验；
- Continue 时全页校验；
- 服务端错误映射到字段或页面级。

## 18.2 Policy Validation

Hard Rule 相关条件不由前端自行判定业务事实。

前端可做格式校验，最终语义以服务端为准。

---

# 19. Card Component

## 19.1 Base Card

```text
background    bg-surface
border        1px border-default
radius        radius-lg
padding       16px
```

## 19.2 Interactive Card

必须有：

- Pressed 状态；
- Focus 状态（Web）；
- 明确可点击 affordance。

---

# 20. Assessment Wizard

## 20.1 Shell

顶部：

```text
Back
步骤标题
Save State（必要时）
```

主体：

```text
Step Indicator
Question Group
Context Help
```

底部：

```text
上一步（次要）
继续（主要）
```

## 20.2 Step Indicator

优先显示：

```text
第 2 / 6 步
专项资格
```

不建议手机端同时挤 7 个长标签。

## 20.3 2026 基础考试信息

字段：

```text
考试年份
考试制度（只读推导）
科类
分数
位次
计划类型
```

当 `SINGLE_COLUMN`：

```text
显示“下一步将补充单列类路径信息”
```

## 20.4 2027 预留

UI 可显示：

```text
首选科目
再选科目
```

但若正式能力未启用：

```text
展示“该年度正式推荐能力尚未开放”
```

不得假装可生成完整结果。

## 20.5 Single Column Path

选项：

```text
外语路径
民族语言路径
不确定
```

配合政策说明入口。

## 20.6 Eligibility UNKNOWN

用户选择“不确定”后显示 Info Panel：

> 你可以继续填写，但系统不会自动把“不确定”视为符合资格。正式推荐将依据当前规则与资格状态处理。

## 20.7 Review Page

按组展示：

```text
考试信息      编辑
专项资格      编辑
专业偏好      编辑
地区偏好      编辑
费用与发展    编辑
```

底部：

```text
[生成正式推荐]
```

若未登录：点击后进入 Auth Gate。

---

# 21. Auth Gate

## 21.1 Trigger

仅在需要：

- 正式推荐；
- 保存云端；
- 查看个人历史；
- 购买权益。

## 21.2 UI

Bottom Sheet 或独立页：

```text
标题：登录后生成正式推荐
说明：你的填写内容已保留
主按钮：微信快捷登录
次按钮：暂不登录
```

必须明确：

```text
登录失败不会丢失本地草稿
```

---

# 22. Recommendation Submission

## 22.1 Idle

按钮：

```text
生成正式推荐
```

附近展示：

- 剩余正式评估次数（服务端值）；
- “本次成功生成后将使用 1 次”；
- “系统失败不扣次”。

## 22.2 Submitting

```text
正在校验资格与招生规则…
```

可按阶段轮播非确定性提示，但不得伪造真实百分比进度。

禁止：

```text
83% 完成
```

除非后端确实提供可信进度。

## 22.3 Retry

网络失败：

```text
[重试]
```

必须复用同一用户动作的幂等语义，不为每次点击盲目创建新业务事实。

---

# 23. Recommendation Result Overview

## 23.1 Page Header

```text
你的志愿建议
2026 · 当前方案
生成时间
```

右侧/更多：

```text
查看依据
```

## 23.2 Critical Warning Zone

仅当存在：

- Policy Conflict；
- UNKNOWN Eligibility；
- Data Version 警告；
- Historical Comparability 问题。

使用 Warning Panel。

## 23.3 Tier Summary

```text
冲  8
稳 12
保 10
观察 3
```

每项可点。

不得只用颜色圆点。

## 23.4 Free User

免费用户展示：

```text
冲 1
稳 1
保 1
```

锁定区：

```text
还有更多匹配结果
[查看完整方案]
```

不得模糊免费已获得结果。

---

# 24. Recommendation Card

## 24.1 信息顺序

```text
[Tier Chip] [Risk Label]
院校名称
专业 / 专业组 / Plan Item 关键信息
所在地 · 院校属性
历史位次摘要
匹配原因 1～2 条
资格/数据警告（如有）
[查看详情]
```

## 24.2 最小单位真实性

虽然卡片首行突出院校，业务对象仍必须对应 `AdmissionPlanItem`。

不得把同校多个不同招生项无条件合并成一个推荐事实。

## 24.3 Card CTA

```text
查看详情
```

不要使用：

```text
立即填报
稳录
锁定名额
```

---

# 25. Recommendation Item Detail

顺序：

```text
院校 / 专业信息
Tier + Risk
为什么推荐
主要风险
历史数据
招生计划条件
资格状态
数据与规则依据
AI 深度解释入口
```

Hard Rule Fail 的项目不应进入正常推荐详情。

---

# 26. Evidence Components

## 26.1 Evidence Summary Card

```text
本次推荐依据
规则年度       2026
招生计划数据   2026-xx
历史数据       2023–2025（示例语义）
考生方案       当前方案 v3
[查看完整依据]
```

不得伪造具体版本。

## 26.2 Evidence Detail

Accordion：

```text
考生信息快照
规则适用信息
数据版本
历史可比性
风险因子
资格状态
技术详情
```

## 26.3 Technical Details

可显示：

```text
ruleSetVersion
admissionPlanDataVersion
admissionHistoryDataVersion
controlLineDataVersion
algorithmVersion
```

默认折叠。

---

# 27. AI Analysis UI

## 27.1 Entry

仅在结构化 Recommendation 已成功后。

## 27.2 AI Header

必须标识：

```text
AI 辅助分析
```

说明：

> 基于本次结构化推荐结果与已知偏好生成，用于辅助理解，不替代官方招生政策。

## 27.3 Sections

```text
核心结论
冲刺策略
稳妥策略
保底策略
专业偏好
地区选择
风险提示
下一步建议
```

## 27.4 Guard Rejected

```text
本次 AI 解释未通过规则一致性检查。
结构化推荐结果仍然有效。
[重新生成解释]
```

不得展示被 Guard 拒绝的内容。

## 27.5 AI Failure

```text
AI 分析暂时不可用
你的推荐结果没有受到影响
```

---

# 28. University List

## 28.1 Header

```text
院校
Search
Filter
```

## 28.2 Filters

P0 建议：

```text
地区
院校类型
院校属性
招生年份
```

不要一次把复杂专业级筛选全部塞首屏。

## 28.3 Card

```text
院校名称
地区
属性标签
简介摘要
[查看详情]
```

---

# 29. University Detail

信息顺序：

```text
院校 Header
基础信息
招生计划入口
相关专业
政策/数据提示
```

不得把历史最低分直接包装成“今年最低分预测”。

---

# 30. Membership UI

## 30.1 Principle

```text
Membership
≠
Entitlement
≠
Quota
```

UI 文案不得混成“开会员后全部无限”。

## 30.2 Membership Page

```text
当前状态
基础会员价值
包含权益
不包含权益
AI 使用说明
人工服务说明
购买入口（Gate-0）
```

## 30.3 Product Card

价格来自服务端。

UI 不写死：

```text
¥99 永久
```

除非当前 Product API 返回。

## 30.4 Paywall

结构：

```text
你已经获得免费的核心结果
解锁后可查看：
- 更多匹配结果
- 完整专业建议
- 高级筛选
- 适用的 AI 深度分析权益
```

避免羞辱式文案。

---

# 31. Quota UI

## 31.1 Display

```text
正式评估剩余 2 / 3 次
```

来源必须是服务端。

## 31.2 Ledger Friendly View

```text
2026-07-04  正式推荐成功  -1
2026-07-03  系统失败      0
```

用户不需要看到内部 Ledger ID。

---

# 32. Payment UI

## 32.1 Gate-0 Closed

允许：

```text
支付能力准备中
```

按钮可：

```text
暂未开放
```

禁止假支付。

## 32.2 Payment Flow

```text
确认商品
↓
创建订单
↓
发起支付
↓
客户端返回
↓
支付结果确认中
↓
服务端确认
↓
成功
```

## 32.3 Client Success State

客户端支付回调 success 后：

```text
Title: 正在确认支付结果
Body: 请稍候，我们正在向服务端确认订单状态。
Spinner
```

不得立即显示最终成功。

## 32.4 Server Confirmed

仅 `serverConfirmed = true`：

```text
支付成功
权益已更新
[查看我的权益]
```

## 32.5 Unknown / Timeout

```text
支付结果暂未确认
请勿重复支付
[刷新状态]
[查看订单]
```

## 32.6 Failed

明确区分：

- 用户取消；
- 支付失败；
- 订单关闭；
- 状态未知。

---

# 33. Loading State

## 33.1 Skeleton

适用：

- 首页；
- 院校列表；
- 推荐历史；
- 推荐详情。

Skeleton 形状应接近真实布局。

## 33.2 Spinner

适用短动作：

- 保存；
- 刷新；
- 支付状态确认。

## 33.3 Long Running Recommendation

使用阶段文案，不伪造百分比。

---

# 34. Empty State

## 34.1 Initial Empty

示例：无推荐历史。

```text
还没有推荐记录
完成考生信息后即可生成第一份正式推荐
[开始评估]
```

## 34.2 Filtered Empty

```text
没有符合当前筛选条件的结果
[清除筛选]
```

不得混同 Initial Empty。

---

# 35. Error State

## 35.1 Retryable

```text
暂时无法加载
[重试]
```

## 35.2 Non-Retryable

给出：

- 原因类别；
- 下一步；
- 返回安全路径。

## 35.3 Error Code

用户默认不看内部错误码。

可在“技术详情”或复制诊断信息中提供 `traceId`。

---

# 36. Degraded State

## 36.1 Data Version Unavailable

```text
当前招生数据版本暂不可用
为避免给出不可靠结果，本次暂不生成正式推荐
```

## 36.2 RuleSet Unavailable

```text
当前年度规则暂不可用
```

## 36.3 AI Unavailable

不影响结构化结果。

---

# 37. Warning / Alert Components

Variants：

```text
Info
Success
Warning
Danger
Neutral
```

结构：

```text
Icon
Title
Description
Optional Action
```

Policy Conflict 使用 Warning 或 Danger 取决于影响，但必须显示文字。

---

# 38. Bilingual UI

## 38.1 Locale Switch

首页与“我的”可访问。

切换时保持：

- 当前 Route；
- Entity ID；
- Filter；
- Wizard Step；
- Draft。

## 38.2 Text Expansion

组件至少容忍：

```text
1.5x 中文文本长度
```

关键按钮禁止固定窄宽导致截断。

## 38.3 Translation Missing

禁止静默空白。

建议：

- 回退中文；
- 记录 missing translation；
- 后台 Translation Review 可见。

---

# 39. RTL Specification

## 39.1 Root Direction

```text
zh-CN -> dir=ltr
ug-CN -> dir=rtl
```

## 39.2 Mirror

需要镜像：

- Back / Forward；
- Breadcrumb directional separators；
- Step progression；
- Horizontal flow arrows；
- Drawer entrance；
- Directional chevrons。

## 39.3 Do Not Mirror

- 数字；
- 年份；
- 分数；
- 位次；
- URL；
- API ID；
- 版本号；
- 院校代码。

## 39.4 Mixed Content

示例：

```text
2026
8,120
XJ_3_1_2
```

在 RTL 环境必须进行 bidi 真机测试。

## 39.5 Logical CSS

Web 优先：

```text
margin-inline-start
padding-inline-end
border-inline-start
inset-inline-start
```

避免大量 `left/right` 硬编码。

小程序样式同样建立逻辑方向封装。

---

# 40. Accessibility Baseline

## 40.1 Touch Target

移动端最小建议：

```text
44 x 44px
```

## 40.2 Contrast

正文与背景遵循可读性优先。

关键状态不得使用浅色低对比文字。

## 40.3 Focus

Admin Web 键盘 Focus 可见。

## 40.4 Labels

所有表单有 Label。

## 40.5 Motion

尊重 reduced motion（Web 可用时）。

---

# 41. Admin Table

## 41.1 Structure

```text
Page Header
Filter Bar
Batch Action（适用）
Table
Pagination
```

## 41.2 Columns

避免一次显示所有字段。

支持：

- Column Visibility；
- Sticky Key Column；
- Horizontal Scroll。

## 41.3 Status

使用 `StatusTag`：文字 + 颜色。

---

# 42. Admin Filter

## 42.1 Basic

首行只保留高频：

- Keyword；
- Status；
- Year；
- Date Range。

## 42.2 Advanced

折叠展开。

## 42.3 Active Filter

显示已生效条件并可单独清除。

---

# 43. Admin Pagination

```text
Total
Page Size
Previous
Page Number
Next
```

服务端分页为准。

---

# 44. Admin High-Risk Mutation

适用：

- RuleSet publish；
- RuleSet activate；
- DataVersion publish；
- PolicyConflict resolve；
- Prompt publish；
- Content publish；
- 人工 Quota 调整（未来）。

## 44.1 Confirmation Modal

必须显示：

```text
动作名称
影响对象
影响范围
不可逆性
当前版本
目标版本
```

## 44.2 Typed Confirmation

对极高风险操作可要求输入：

```text
PUBLISH
ACTIVATE
```

但不要滥用。

## 44.3 Reason

需要审计的动作提供：

```text
变更原因
```

## 44.4 Success

成功后展示：

- 新状态；
- 操作时间；
- 操作人；
- Operation Log 入口。

---

# 45. PolicyConflict Admin UI

## 45.1 List

Columns：

```text
Conflict ID
主题
影响年度
范围
状态
来源数量
更新时间
```

## 45.2 Detail

```text
冲突摘要
来源 A
来源 B
差异点
影响规则
影响推荐
当前状态
处理记录
解决动作
```

## 45.3 Resolve

不得只有一个“已解决”按钮。

需要：

- 解决依据；
- 关联 Policy Source；
- 规则版本影响；
- 操作原因。

---

# 46. DataVersion Admin UI

List：

```text
数据类型
版本
年度
状态
来源
导入时间
发布时间
质量状态
```

Publish 前显示：

- Quality Issues；
- Record Count；
- Source；
- Previous Active Version；
- Impact Warning。

---

# 47. Recommendation Audit UI

## 47.1 Overview

```text
Recommendation ID
Candidate
Run Status
Created At
Tier Count
Warnings
```

## 47.2 Tabs

```text
Overview
Profiles
Versions
Results
Rule Traces
Snapshots
Warnings
```

## 47.3 Result Audit

每个 Result Item 显示：

- AdmissionPlanItem；
- Tier；
- Risk；
- Rule trace summary；
- Data version；
- Warning。

---

# 48. AI / Prompt Admin UI

## 48.1 AI Call Logs

显示：

- Provider abstraction name；
- Model logical name；
- Prompt version；
- Status；
- Latency；
- Token usage（若可用）；
- Guard status。

不得展示不必要的用户敏感信息。

## 48.2 Prompt Publish

高风险操作。

必须显示 Diff：

```text
Current Published
vs
Candidate Version
```

---

# 49. Translation Review Admin UI

## 49.1 List

```text
Key
zh-CN
ug-CN
Review Status
Reviewer
Updated At
```

## 49.2 Preview

必须可预览：

```text
LTR
RTL
Mobile Width
Long Text
Mixed Number
```

## 49.3 Policy Content

政策类翻译标识更高风险等级。

---

# 50. High Fidelity Spec — MP Home

## 50.1 Route

```text
/pages/home/index
```

## 50.2 Visitor State

从上到下：

```text
1. Top Bar
   - 工作名 Logo
   - Locale Switch

2. Hero
   - Title: 更清楚地规划你的新疆高考志愿
   - Subtitle: 规则、数据与个性化建议，AI 负责解释
   - Primary CTA: 开始评估

3. Trust Note
   - 辅助决策，不承诺录取

4. Quick Entry
   - 院校库
   - 专业库
   - 政策信息

5. How It Works
   - 填写信息
   - 规则筛选
   - 冲稳保建议
   - 查看依据

6. Content

7. TabBar
```

## 50.3 Logged In + Complete Profile

Hero CTA：

```text
生成新推荐
```

增加：

```text
当前方案摘要
剩余正式评估次数
最近推荐
```

## 50.4 Running Recommendation

首页顶部状态卡：

```text
推荐正在生成
[查看进度]
```

---

# 51. High Fidelity Spec — Assessment Basic

## 51.1 Route

```text
/pages/assessment/basic
```

## 51.2 Layout

```text
NavBar
Step 1 / N
Title: 先告诉我们你的考试信息
Description

Field: 考试年份
Field: 科类
Field: 高考分数
Field: 位次
Field: 计划类型

Context Help

Sticky Footer
[继续]
```

## 51.3 Validation

分数/位次缺失时明确定位。

---

# 52. High Fidelity Spec — Assessment Eligibility

## 52.1 Route

```text
/pages/assessment/eligibility
```

## 52.2 Card Pattern

每个资格：

```text
资格名称
简短说明
[是] [否] [不确定]
[查看政策说明]
```

UNKNOWN 被选中时显示 Info Panel。

---

# 53. High Fidelity Spec — Assessment Review

## 53.1 Route

```text
/pages/assessment/review
```

结构：

```text
Title
Critical Warning（如有）

考试信息 Card    [编辑]
专项资格 Card    [编辑]
专业偏好 Card    [编辑]
地区偏好 Card    [编辑]
费用与发展 Card  [编辑]

Quota Note
Trust Note

Sticky CTA
[生成正式推荐]
```

---

# 54. High Fidelity Spec — Recommendation Loading

## 54.1 Route

```text
/pages/recommendation/generating
```

结构：

```text
Illustration / subtle motion
Title: 正在生成你的推荐
Stage Text
- 校验考生信息
- 应用年度规则
- 匹配招生计划
- 评估历史可比性
- 生成推荐分层

Note:
不会由 AI 绕过报考资格与招生规则
```

阶段文案是解释性，不表示真实精确进度。

---

# 55. High Fidelity Spec — Recommendation Result

## 55.1 Route

```text
/pages/recommendation/result?id={id}
```

## 55.2 Above the Fold

```text
NavBar

Title: 你的志愿建议
Meta: 2026 · 当前方案
[查看依据]

Warning Panel（条件）

Tier Summary
[冲 8] [稳 12] [保 10] [观察 3]
```

## 55.3 Content

```text
Section: 推荐结果
Filter Chips: 全部 / 冲 / 稳 / 保 / 观察
Sort（谨慎）

Recommendation Cards
```

## 55.4 Bottom

```text
AI 深度分析
依据与版本
免责声明
```

---

# 56. High Fidelity Spec — Recommendation Detail

## 56.1 Route

```text
/pages/recommendation/item-detail
```

结构：

```text
University Header
Tier / Risk

Why Recommended
- 原因 1
- 原因 2

Key Risks

Historical Data

Plan Constraints

Eligibility Status

Evidence Summary

[查看完整依据]
[AI 深度解释]
```

---

# 57. High Fidelity Spec — Evidence

## 57.1 Route

```text
/pages/recommendation/evidence
```

结构：

```text
Title: 本次推荐依据
Intro

Candidate Snapshot
Rule Applicability
Data Versions
Historical Comparability
Risk Factors
Eligibility Status
Technical Details (collapsed)
```

---

# 58. High Fidelity Spec — AI Analysis

## 58.1 Route

```text
/pages/ai/analysis
```

结构：

```text
AI 辅助分析 Badge
Disclosure

核心结论
冲刺策略
稳妥策略
保底策略
专业偏好
地区选择
风险提示
下一步建议

Evidence Link
```

---

# 59. High Fidelity Spec — Membership

## 59.1 Route

```text
/pages/membership/index
```

结构：

```text
Current Status

Value Proposition

Included Entitlements
Not Included / Separate Services
AI Usage Explanation
Human Service Explanation

Product Cards (server-driven)

Gate Status

[Continue]
```

---

# 60. High Fidelity Spec — Payment Confirming

## 60.1 Route

```text
/pages/order/payment-status
```

Confirming：

```text
Spinner
正在确认支付结果
请勿重复支付
Order No（可复制）
```

Confirmed：

```text
Success Icon
支付成功
权益已更新
[查看我的权益]
```

Unknown：

```text
Neutral/Warning Icon
结果暂未确认
[刷新状态]
[查看订单]
```

---

# 61. High Fidelity Spec — Me

## 61.1 Route

```text
/pages/me/index
```

Logged In：

```text
Profile Header
当前考生方案
正式评估次数
我的推荐
我的权益
订单
语言
隐私与账号
反馈
```

Visitor：

```text
Login CTA
本地草稿状态
语言
隐私
```

---

# 62. High Fidelity Spec — Admin Dashboard

## 62.1 Route

```text
/admin/dashboard
```

结构：

```text
Page Header

Operational Summary
- 今日推荐运行
- 推荐失败
- Data Quality Open
- Policy Conflict Open

Critical Risk Zone

Recent Import Jobs

Recommendation Health

Recent High-Risk Operations
```

不得做纯“漂亮数据大屏”。

---

# 63. High Fidelity Spec — Admin PolicyConflict

## 63.1 Route

```text
/admin/policy-conflicts/:id
```

结构：

```text
Header
Status
Affected Year
Affected Scope

Conflict Summary

Source A Card
Source B Card

Difference Matrix

Affected Rules
Affected Recommendation Scope

Resolution Timeline

[Resolve Conflict]
```

---

# 64. High Fidelity Spec — Admin DataVersion

## 64.1 Route

```text
/admin/data-versions/:id
```

结构：

```text
Header + Status
Version Metadata
Source
Record Count
Quality Summary
Open Issues
Import Job
Previous Active Version
Impact Summary

[Publish]
```

Publish 使用 High-Risk Mutation Modal。

---

# 65. High Fidelity Spec — Admin Recommendation Audit

## 65.1 Route

```text
/admin/recommendations/:id
```

结构：

```text
Audit Header
Status
Warnings

Tabs:
Overview
Profiles
Versions
Results
Rule Traces
Snapshots
Warnings
```

Overview 首屏必须回答：

- 谁；
- 何时；
- 用了什么 Profile；
- 用了什么 RuleSet；
- 用了什么 DataVersion；
- 结果是什么；
- 是否有 Warning。

---

# 66. High Fidelity Spec — Admin Translation Review

## 66.1 Route

```text
/admin/translations/:id
```

左右对照：

```text
zh-CN Source
ug-CN Translation
```

下方 Preview：

```text
Mobile LTR Source
Mobile RTL Target
```

状态：

```text
DRAFT
IN_REVIEW
APPROVED
REJECTED
```

---

# 67. Responsive Rules

## 67.1 Mini Program

不做桌面响应式。

适配：

- 小屏手机；
- 常规手机；
- 大屏手机。

## 67.2 Admin

Breakpoints 建议：

```text
< 1024      不作为主要生产后台体验，仅基础兼容
1024–1439   Standard
>= 1440     Wide
```

表格页面利用宽屏，但不把正文无限拉宽。

---

# 68. Iconography

## 68.1 Style

统一 Outline 为主。

关键完成状态可 Filled。

## 68.2 Forbidden

不要使用：

- 赌博筹码；
- 赌场转盘；
- 夸张皇冠；
- “100%”徽章；
- 迷信符号。

---

# 69. Illustration

插图只用于：

- Onboarding；
- Empty；
- Success；
- Degraded。

推荐结果主体不依赖插图占空间。

风格：

- 克制；
- 本地化但不刻板化民族元素；
- 不冒充官方教育机构。

---

# 70. Content Design

## 70.1 Tone

```text
专业
清楚
不居高临下
不制造恐慌
```

## 70.2 Good

> 该结果相对更偏保守配置，但仍受年度招生计划与竞争变化影响。

## 70.3 Bad

> 这个学校你稳了！

## 70.4 AI Disclosure

> AI 用于解释已有推荐结果，不替代官方政策与招生章程。

---

# 71. Privacy UI

## 71.1 Data Collection

敏感字段附近提供：

- 为什么需要；
- 如何使用；
- 是否可稍后补充。

## 71.2 Analytics

不得在 Analytics 事件中直接塞：

- 身份证号；
- 手机号；
- 详细考生敏感信息；
- 完整自由文本隐私内容。

---

# 72. Security UX

## 72.1 Server Truth

以下显示以服务端为准：

- Quota；
- Membership；
- Entitlement；
- Payment Success；
- Eligibility；
- Recommendation Tier。

## 72.2 Optimistic UI

禁止对以下使用不可回滚乐观成功：

- 支付成功；
- RuleSet publish；
- DataVersion publish；
- PolicyConflict resolve；
- Quota adjustment。

---

# 73. Page State Matrix

所有 P0 页面至少考虑：

```text
Loading
Success
Empty
Error
Unauthorized
Forbidden
Degraded
```

列表额外：

```text
Initial Empty
Filtered Empty
Pagination Loading
Pagination End
```

提交页额外：

```text
Idle
Submitting
Success
Retryable Failure
Non-retryable Failure
```

---

# 74. Component State Matrix

## Button

```text
Default
Pressed
Focus(Web)
Disabled
Loading
```

## Input

```text
Empty
Filled
Focus
Disabled
ReadOnly
Error
Success(optional)
```

## Recommendation Card

```text
Default
Pressed
Locked
Warning
Degraded
```

## Payment Status

```text
Pending
Confirming
ServerConfirmed
Failed
Closed
Unknown
```

---

# 75. Analytics UI Event Mapping

保留 Step 6 语义：

```text
home_view
assessment_start
assessment_step_view
assessment_step_complete
assessment_review
login_gate_view
login_success
recommendation_submit
recommendation_success
recommendation_failure
recommendation_result_view
recommendation_evidence_view
paywall_view
product_view
order_create
payment_status_view
ai_analysis_request
ai_analysis_success
locale_switch
feedback_submit
```

UI 组件不得自行加入敏感字段。

---

# 76. Implementation Mapping — Native Mini Program

## 76.1 Suggested Components

```text
components/
├── app-button/
├── app-input/
├── app-select/
├── status-tag/
├── tier-chip/
├── risk-label/
├── warning-panel/
├── evidence-card/
├── recommendation-card/
├── quota-badge/
├── empty-state/
├── error-state/
├── skeleton/
├── step-indicator/
└── locale-switch/
```

## 76.2 Styles

```text
styles/
├── tokens.wxss
├── semantic.wxss
├── rtl.wxss
└── utilities.wxss
```

不要把业务规则写进视觉组件。

---

# 77. Implementation Mapping — Vue Admin

建议：

```text
admin-web/src/
├── components/
│   ├── StatusTag.vue
│   ├── RiskLabel.vue
│   ├── HighRiskConfirm.vue
│   ├── EvidencePanel.vue
│   ├── VersionBadge.vue
│   └── FilterBar.vue
├── layouts/
├── views/
└── styles/
```

Element Plus 作为基础组件库时：

- 使用项目 Semantic Token 包装；
- 不直接让每页各自随意配置颜色；
- 高风险业务组件建立项目级封装。

---

# 78. Design QA Checklist

每个页面 Review：

```text
信息层级是否与 IA 一致？
是否擅自新增业务能力？
是否把 AI 放到 Hard Rule 之前？
是否把 SAFE 写成保证录取？
是否出现伪精确概率？
是否把 UNKNOWN 当 false/true？
是否颜色成为唯一状态编码？
是否有 Loading/Empty/Error？
ug-CN 是否 RTL？
长文本是否溢出？
数字在 RTL 是否正确？
支付是否服务端确认？
Quota 是否服务端事实？
高风险 Admin 操作是否确认？
```

---

# 79. Contract QA Checklist

UI 与 API 联调：

```text
User API 与 Admin API 不混用
User Token 不调用 Admin
Recommendation 重试保持幂等语义
409 Idempotency Conflict 有专门错误 UI
Quota 失败不自行扣次
Payment client success 不显示最终成功
AI Guard Rejected 不展示违规内容
Profile 新版本不覆盖历史 UI 语义
历史 Recommendation 显示当时 Snapshot
```

---

# 80. Explicit Non-Goals

本 Step 不做：

- 修改 64 表领域模型；
- 合并 User / Candidate；
- 引入 `user.vip`；
- Eligibility Boolean 化；
- Recommendation 改成 University 粒度；
- 取消 Profile Versioning；
- 取消 Recommendation immutable 语义；
- AI 绕过 Hard Rule；
- 伪精确录取概率；
- P0 Full RAG；
- Vector DB；
- Kafka / RabbitMQ；
- Microservices；
- Kubernetes；
- 未过 Gate-0 的真实支付承诺；
- 把 P1 志愿模拟/对比/人工服务塞进 P0 主导航；
- 重新设计 IA。

---

# 81. Step 8 Handoff

Step 7 完成后进入：

```text
Checkpoint B
```

Checkpoint B 通过后：

```text
Step 8
Codex Skills
```

Step 8 必须以：

- PRD；
- Business Rules；
- Architecture；
- Database；
- API Contract；
- IA；
- UI Specification；
- Decision Register

为 SSOT。

建议 Codex Skill 至少覆盖：

```text
project-context
backend-conventions
mini-program-ui
admin-web-ui
api-contract
xinjiang-hard-rules
recommendation-safety
bilingual-rtl
payment-safety
migration-database
```

---

# 82. Acceptance Checklist

```text
Conflict Report                                  ✅
不修改冻结决策                                   ✅
不重设计数据库领域模型                           ✅
不重新选择技术栈                                 ✅
不修改 Step 6 IA                                ✅
Design Tokens                                    ✅
Primitive Color                                  ✅
Semantic Color                                   ✅
Typography                                       ✅
Spacing                                          ✅
Radius                                           ✅
Shadow                                           ✅
Motion                                           ✅
Mini Program Layout                              ✅
Admin Layout                                     ✅
Navigation Components                            ✅
Form Components                                  ✅
Assessment Wizard                                ✅
REACH / MATCH / SAFE / WATCH                     ✅
Risk Visual Language                             ✅
颜色非唯一编码                                   ✅
Recommendation Cards                             ✅
Evidence Components                              ✅
AI Analysis                                      ✅
AI Hard Rule Guard UX                            ✅
Membership / Entitlement / Quota 分离            ✅
Payment Server Confirmation                      ✅
Gate-0                                           ✅
Loading / Empty / Error / Degraded               ✅
zh-CN / ug-CN                                    ✅
RTL                                              ✅
Admin Table / Filter / Pagination                ✅
Admin High-Risk Mutation                         ✅
PolicyConflict UI                                ✅
DataVersion UI                                   ✅
Recommendation Audit UI                         ✅
Translation Review UI                            ✅
High Fidelity MP Home                            ✅
High Fidelity Assessment                         ✅
High Fidelity Recommendation                     ✅
High Fidelity Evidence                           ✅
High Fidelity AI                                 ✅
High Fidelity Membership / Payment               ✅
High Fidelity Admin                              ✅
Accessibility                                    ✅
Security UX                                      ✅
Implementation Mapping                           ✅
Design QA                                        ✅
Contract QA                                      ✅
Step 8 Handoff                                   ✅
```

---

# 83. Step 7 Status

```text
STEP 7
UI Specification / High Fidelity V1.0
=
COMPLETED
```

下一节点：

```text
Checkpoint B
```

