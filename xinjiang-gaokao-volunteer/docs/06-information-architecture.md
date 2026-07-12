# 新疆高考 AI 志愿助手
# Information Architecture V1.0

- **建议文件名：** `06-information-architecture.md`
- **版本：** V1.0
- **状态：** Step 6 Complete
- **适用端：** 微信原生小程序 / Admin Web
- **上游 SSOT：** `00-project-master-context.md`、`00-decision-register.md`、`00-progress-tracker.md`、`01-prd.md`、`02-xinjiang-business-rules.md`、`03-system-architecture.md`、`04-database-design.md`、`05-api-contract.md`
- **下游输入：** Step 7 `07-ui-specification.md`

---

# 0. 文档目的

本文件定义产品信息架构（Information Architecture, IA），负责回答：

1. 用户和管理员能看到哪些信息空间；
2. 页面、导航、入口与层级如何组织；
3. 用户如何从“进入产品”走到“完成正式推荐”；
4. 哪些步骤允许游客访问，哪些步骤必须登录；
5. 2026 / 2027、普通类 / 单列类、资格三态如何驱动动态信息结构；
6. 免费次数、会员转化、支付确认如何进入用户流程；
7. 中文 `zh-CN` 与维吾尔语 `ug-CN`、LTR 与 RTL 如何在 IA 层保持同构；
8. Admin Web 如何映射政策、数据、推荐审计、商业与 AI 治理能力；
9. 页面如何映射 Step 5 API Contract，而不重新设计 API、数据库或技术栈。

本文件不定义：

- 视觉色板；
- 字体字号最终值；
- 组件像素级样式；
- 高保真稿；
- 动画细节；
- 数据库表结构；
- API Request / Response Schema；
- 推荐算法公式；
- 新技术栈。

上述 UI 视觉问题进入 Step 7。

---

# 1. Conflict Report

## 1.1 结论

```text
CONFLICT_REPORT_STATUS = NO_BLOCKING_CONFLICT
```

在当前上游 SSOT 与 Step 5 API Contract 之间，未发现阻断 Step 6 的冲突。

## 1.2 必须保留的开放事项

以下事项保持 OPEN，不在 IA 阶段擅自关闭：

| ID | 事项 | IA 处理 |
|---|---|---|
| OD-001 | 产品正式名称 | 页面使用产品工作名/可配置名称，不冻结品牌名 |
| OD-002 | 永久会员价格 | 会员页保留 SKU 动态展示，不写死价格 |
| OD-003 | AI Provider | 前台不暴露 Provider，后台保持 Gateway 抽象 |
| OD-006 | Redis 实现 | 与 IA 无关，不决策 |
| OD-007 | 支付能力 | 保留 Gate-0；真实支付入口受能力开关控制 |
| OD-008 | 维吾尔语人工审校资源 | Admin 保留翻译审校队列 |
| OD-009 | 招生数据来源与授权 | 数据来源/版本/质量后台保留一级入口 |
| OD-010 | 2026 单列类政策冲突 | 前台不得给出未经解决的确定性资格结论；后台保留 PolicyConflict |

## 1.3 冻结决策保持性

本 IA 不改变：

- 新疆单省定位；
- “规则 + 数据 + 算法 + AI 解释”；
- 新用户 3 次正式评估基线；
- 免费展示冲/稳/保各 1 所；
- 永久基础会员与 AI 无限调用分离；
- 中文 / 维吾尔语；
- 维吾尔语 RTL；
- 2026 `TRADITIONAL_WENLI`；
- 2027 `XJ_3_1_2`；
- Profile 版本化；
- Eligibility 禁止 Boolean；
- `REACH / MATCH / SAFE / WATCH`；
- 不输出未经校准精确概率；
- `request_hash + idempotency_key`；
- `Membership + Entitlement`；
- AI 只解释、不突破 Hard Rule；
- 支付成功必须服务端确认；
- User / Admin API 与 Principal 分离。

---

# 2. IA Design Principles

## 2.1 Decision First，不以“功能堆砌”为首页结构

首页首要任务不是展示所有模块，而是帮助用户进入核心决策路径：

```text
我是谁 / 我的高考路径
↓
我能报什么
↓
哪些计划项可进入候选池
↓
冲 / 稳 / 保 / 观察
↓
为什么
↓
下一步怎么办
```

## 2.2 Rule First

页面不得通过文案或交互暗示用户可以绕过 Hard Rule。

例如：

```text
专项资格 = UNKNOWN
```

不得显示：

```text
“系统默认您符合资格”
```

应显示：

```text
“资格尚未确认；相关计划可能无法进入正式推荐。”
```

## 2.3 Progressive Disclosure

不在首屏一次询问所有信息。

采用：

```text
基础考试信息
↓
条件动态展开
↓
专项资格
↓
偏好
↓
确认
```

## 2.4 Browse Before Login

遵守 PRD：不强制用户进入首页立即登录。

允许游客：

- 浏览首页；
- 浏览院校；
- 浏览专业；
- 浏览政策内容；
- 开始填写本地临时高考信息。

在需要创建服务端用户资产、生成正式推荐、保存结果或消耗 Quota 时进入登录闸门。

## 2.5 Evidence Visible

推荐结果必须让用户理解：

- 使用哪个考生画像版本；
- 使用哪个年度规则；
- 使用哪些数据年份/版本；
- 主要风险来源；
- 资格不确定项；
- 为什么属于冲/稳/保/观察。

## 2.6 AI Is Secondary

AI 解释入口只能依附于成功的结构化推荐事实。

```text
RecommendationRun SUCCEEDED
↓
Result + Evidence
↓
AI Explanation
```

禁止 IA 暗示：

```text
“问 AI → AI 自己选学校”
```

## 2.7 Stable IA Across Locales

`zh-CN` 与 `ug-CN` 使用同一业务信息架构：

- 页面 ID 相同；
- 路由语义相同；
- 权限相同；
- 页面层级相同；
- 业务状态相同。

仅：

- 文案本地化；
- 方向切换；
- 图标方向性适配；
- 排版适配。

---

# 3. Product Surface Map

```text
新疆高考 AI 志愿助手
├── 微信原生小程序（User Surface）
│   ├── 首页 / 决策入口
│   ├── 智能评估
│   ├── 推荐结果
│   ├── 院校库
│   ├── 专业库
│   ├── 政策与资讯
│   ├── 会员与权益
│   └── 我的
│
├── Admin Web（Admin Surface）
│   ├── 工作台
│   ├── 用户与考生
│   ├── 政策与规则
│   ├── 数据治理
│   ├── 招生数据
│   ├── 推荐审计
│   ├── 会员与商业
│   ├── AI 与 Prompt
│   ├── 内容与翻译
│   └── 审计日志
│
└── 非页面 Surface
    ├── Payment Provider Callback
    ├── Offline Data Pipeline
    └── Internal Service / Job
```

Payment Provider Callback 不是用户页面，不进入小程序路由。

---

# 4. 微信小程序一级导航

## 4.1 P0 TabBar

建议 P0 固定 4 个一级 Tab：

```text
首页
院校
推荐
我的
```

语义 ID：

```text
home
universities
recommendations
me
```

### 原因

- 首页承载核心入口与政策内容；
- 院校库是高频独立探索场景；
- 推荐承担历史与当前结果资产；
- 我的承担 Candidate、Quota、Membership、Order、Settings；
- 专业库通过首页快捷入口与院校详情/搜索进入，避免 P0 TabBar 过载；
- P1 志愿模拟不提前成为 P0 Tab。

## 4.2 不进入 P0 TabBar

以下页面不做一级 Tab：

- 登录；
- 考生信息填写；
- 资格填写；
- 偏好填写；
- 推荐生成中；
- 推荐详情；
- AI 深度分析；
- 会员购买；
- 订单；
- 专业库；
- 政策文章详情；
- 反馈；
- 注销账号。

这些属于任务流或二级信息空间。

## 4.3 P1 / P2 不污染 P0 IA

P1：

- PDF 报告；
- 志愿表模拟；
- 院校对比；
- 专业对比；
- 人工服务。

P2：

- 家长账号；
- 顾问工作台；
- 多 Agent；
- 自动志愿排序。

在 P0 页面中只允许通过 Feature Flag / Coming Soon 策略预留，不得伪装为已交付。

---

# 5. 微信小程序 Page Map

## 5.1 全量页面树

```text
Mini Program
├── A. Home
│   ├── MP-HOME-001 首页
│   ├── MP-CONTENT-001 政策/资讯列表
│   ├── MP-CONTENT-002 政策/资讯详情
│   └── MP-SEARCH-001 全局搜索（可选 P0-B）
│
├── B. Assessment Wizard
│   ├── MP-ASSESS-001 评估引导
│   ├── MP-ASSESS-010 基础考试信息
│   ├── MP-ASSESS-020 单列类路径信息（条件页）
│   ├── MP-ASSESS-030 专项资格
│   ├── MP-ASSESS-040 专业偏好
│   ├── MP-ASSESS-050 地区与院校偏好
│   ├── MP-ASSESS-060 费用与发展偏好
│   ├── MP-ASSESS-070 信息确认
│   ├── MP-ASSESS-080 登录闸门
│   ├── MP-ASSESS-090 推荐提交
│   └── MP-ASSESS-100 推荐生成中
│
├── C. Recommendation
│   ├── MP-REC-001 推荐中心/历史
│   ├── MP-REC-010 推荐结果总览
│   ├── MP-REC-020 冲列表
│   ├── MP-REC-030 稳列表
│   ├── MP-REC-040 保列表
│   ├── MP-REC-050 观察列表
│   ├── MP-REC-060 结果项详情
│   ├── MP-REC-070 证据与版本
│   ├── MP-REC-080 风险与资格提示
│   ├── MP-REC-090 AI 分析入口
│   └── MP-REC-100 AI 分析详情
│
├── D. University
│   ├── MP-UNI-001 院校列表
│   ├── MP-UNI-010 院校筛选
│   ├── MP-UNI-020 院校详情
│   └── MP-UNI-030 院校招生计划
│
├── E. Major
│   ├── MP-MAJOR-001 专业列表
│   ├── MP-MAJOR-010 专业详情
│   └── MP-MAJOR-020 相关招生计划
│
├── F. Membership & Commerce
│   ├── MP-MEMBER-001 会员与权益
│   ├── MP-MEMBER-010 商品详情
│   ├── MP-ORDER-001 确认订单
│   ├── MP-ORDER-010 支付处理中
│   ├── MP-ORDER-020 支付结果确认
│   ├── MP-ORDER-030 我的订单
│   └── MP-ORDER-040 订单详情
│
├── G. Me
│   ├── MP-ME-001 我的首页
│   ├── MP-CAND-001 考生方案列表
│   ├── MP-CAND-010 考生方案详情
│   ├── MP-PROFILE-001 考试画像版本
│   ├── MP-PROFILE-010 资格画像版本
│   ├── MP-PROFILE-020 偏好画像版本
│   ├── MP-QUOTA-001 免费次数/Quota
│   ├── MP-QUOTA-010 扣次记录
│   ├── MP-FAV-001 收藏
│   ├── MP-SET-001 设置
│   ├── MP-SET-010 语言设置
│   ├── MP-PRIVACY-001 隐私与账号
│   ├── MP-PRIVACY-010 注销账号
│   └── MP-FEEDBACK-001 反馈
│
└── H. Auth & System
    ├── MP-AUTH-001 微信登录
    ├── MP-SYS-001 空状态
    ├── MP-SYS-010 网络错误
    ├── MP-SYS-020 系统错误
    ├── MP-SYS-030 维护/数据不可用
    └── MP-SYS-040 功能 Gate 未开放
```

---

# 6. 微信小程序 Route Baseline

> 路由是 IA 基线，不是最终代码强制命名。Step 7 和编码阶段可在不改变信息语义的前提下按微信小程序工程约束调整文件路径。

| Page ID | 建议 Route | Auth | P0 |
|---|---|---:|---:|
| MP-HOME-001 | `/pages/home/index` | No | Yes |
| MP-UNI-001 | `/pages/universities/index` | Optional | Yes |
| MP-UNI-020 | `/pages/universities/detail` | Optional | Yes |
| MP-MAJOR-001 | `/pages/majors/index` | Optional | Yes |
| MP-MAJOR-010 | `/pages/majors/detail` | Optional | Yes |
| MP-CONTENT-001 | `/pages/content/index` | No | Yes |
| MP-CONTENT-002 | `/pages/content/detail` | No | Yes |
| MP-ASSESS-001 | `/pages/assessment/start` | No | Yes |
| MP-ASSESS-010 | `/pages/assessment/exam` | No/Local Draft | Yes |
| MP-ASSESS-020 | `/pages/assessment/single-column` | No/Local Draft | Yes |
| MP-ASSESS-030 | `/pages/assessment/eligibility` | No/Local Draft | Yes |
| MP-ASSESS-040 | `/pages/assessment/major-preference` | No/Local Draft | Yes |
| MP-ASSESS-050 | `/pages/assessment/location-school` | No/Local Draft | Yes |
| MP-ASSESS-060 | `/pages/assessment/cost-career` | No/Local Draft | Yes |
| MP-ASSESS-070 | `/pages/assessment/review` | No/Local Draft | Yes |
| MP-AUTH-001 | `/pages/auth/login` | No | Yes |
| MP-ASSESS-090 | `/pages/assessment/submit` | User | Yes |
| MP-ASSESS-100 | `/pages/assessment/running` | User | Yes |
| MP-REC-001 | `/pages/recommendations/index` | User | Yes |
| MP-REC-010 | `/pages/recommendations/detail` | User | Yes |
| MP-REC-060 | `/pages/recommendations/item-detail` | User | Yes |
| MP-REC-070 | `/pages/recommendations/evidence` | User | Yes |
| MP-REC-100 | `/pages/ai-analysis/detail` | User | Yes |
| MP-MEMBER-001 | `/pages/membership/index` | Optional/User | Yes |
| MP-ORDER-001 | `/pages/orders/confirm` | User | Gate |
| MP-ORDER-020 | `/pages/orders/payment-status` | User | Gate |
| MP-ME-001 | `/pages/me/index` | Optional/User | Yes |
| MP-CAND-001 | `/pages/candidates/index` | User | Yes |
| MP-QUOTA-001 | `/pages/quota/index` | User | Yes |
| MP-ORDER-030 | `/pages/orders/index` | User | Gate |
| MP-SET-001 | `/pages/settings/index` | Optional/User | Yes |
| MP-PRIVACY-001 | `/pages/privacy/index` | User | Yes |
| MP-FEEDBACK-001 | `/pages/feedback/index` | Optional/User | Yes |

---

# 7. Home IA

## 7.1 首页目标

首页只承担 5 个核心任务：

1. 让用户快速开始评估；
2. 显示当前关键信息状态；
3. 提供院校/专业探索；
4. 提供新疆政策与招生动态；
5. 提供语言切换与会员/Quota 状态。

## 7.2 首页信息顺序

```text
[Top App Bar]
产品名称 / Logo
语言切换：中文 | ئۇيغۇرچە

[Primary Hero]
标题：新疆高考志愿决策辅助
说明：规则 + 数据 + 算法 + AI解释
CTA：开始智能评估

[User State Strip]
游客：登录后保存方案与结果
已登录：当前 Candidate 摘要
Quota：剩余正式评估次数
Membership：当前权益摘要

[Quick Actions]
智能推荐
院校库
专业库
政策资讯

[Continue Block]
存在草稿：继续填写
存在运行中推荐：查看进度
存在最近成功推荐：查看最近结果

[Policy / Announcement]
重要公告
新疆高考政策
最新招生动态

[Trust / Disclaimer]
数据版本 / 更新提示
辅助决策声明
```

## 7.3 首页状态化

### 游客

主 CTA：

```text
开始智能评估
```

不显示虚构 Quota 数字；可显示：

```text
登录后可获得新用户正式评估权益（以账户实际权益为准）
```

### 已登录、无 Candidate

```text
创建我的考生方案
```

### 已登录、有 Candidate、资料不完整

```text
继续完善信息
```

### 已登录、资料完整

```text
生成智能推荐
```

### 有运行中 Recommendation

```text
推荐生成中 · 查看进度
```

### 有成功 Recommendation

```text
查看最近推荐
重新评估
```

“重新评估”必须提示可能产生新正式评估与 Quota 影响，不得把读取历史结果误导为重新扣次。

---

# 8. Login Timing & Auth Gate

## 8.1 原则

```text
不在进入首页时强制登录
```

## 8.2 游客可完成

- 首页浏览；
- 院校搜索；
- 院校详情；
- 专业搜索；
- 专业详情；
- 政策文章；
- 在客户端临时填写评估草稿；
- 切换语言。

## 8.3 必须登录的动作

- 创建 Candidate；
- 创建 Profile Version；
- 激活 Profile Version；
- 提交正式 Recommendation；
- 查看 Recommendation 历史；
- 查看私有结果；
- 创建 AI Analysis；
- 查看 Membership / Entitlement 个人状态；
- 查看 Quota 与 Ledger；
- 创建订单；
- 发起支付；
- 查看订单；
- 管理个人数据；
- 注销账号。

## 8.4 推荐流程登录时机

采用：

```text
打开小程序
↓
浏览首页
↓
开始评估
↓
填写基础信息
↓
填写条件信息
↓
填写偏好
↓
确认信息
↓
点击“生成正式推荐”
↓
若未登录 → 微信登录闸门
↓
服务端创建/同步 Candidate + Profile Versions
↓
正式提交 Recommendation
```

这样兼顾：

- 降低首屏流失；
- 不在客户端假装已经完成正式推荐；
- 正式推荐前建立可审计主体与版本。

## 8.5 登录失败

登录失败不得丢失本地草稿。

```text
Login Failed
↓
保留 Local Draft
↓
允许重试
```

---

# 9. Assessment Wizard IA

## 9.1 总体结构

```text
Step A 基础考试信息
↓
Step B 路径信息（条件）
↓
Step C 专项资格
↓
Step D 专业偏好
↓
Step E 地区/学校偏好
↓
Step F 费用/发展偏好
↓
Step G 确认与风险提示
↓
Login Gate（如需要）
↓
正式提交
```

## 9.2 Step A：基础考试信息

P0 必填：

- 高考年份；
- 总分；
- 全区位次；
- 考试制度派生字段；
- 科类 / 首选科目；
- 招生计划类型。

### 2026

```text
examYear = 2026
examRegime = TRADITIONAL_WENLI
subjectTrack = LITERATURE_HISTORY | SCIENCE_ENGINEERING
planType = NORMAL | SINGLE_COLUMN
```

### 2027

```text
examYear = 2027
examRegime = XJ_3_1_2
firstChoiceSubject = PHYSICS | HISTORY
secondChoiceSubjects = 2 items from allowed set
```

P0 支持范围仍优先 2026；2027 IA 仅按冻结模型预留，不等于宣称 2027 完整推荐已上线。

## 9.3 Step B：单列类路径信息

仅当：

```text
planType = SINGLE_COLUMN
```

动态出现。

字段语义：

```text
FOREIGN_LANGUAGE
ETHNIC_LANGUAGE
UNKNOWN
```

不得将“单列类”直接等价为某一种语言路径。

对于 OD-010：

- 若涉及“兼报普通类条件”；
- 当前 RuleSet 无法给出已验证确定结论；

页面必须显示：

```text
政策条件存在待核验项
```

不得由 AI 自动判定。

## 9.4 Step C：专项资格

UI 文案可以呈现：

```text
是
否
不确定
```

但业务映射必须保留非 Boolean 状态语义。

至少包含：

- 国家专项；
- 地方专项；
- 南疆单列；
- 对口援疆相关；
- 高校专项相关；
- 其他政策资格。

### UNKNOWN UX

选择“不确定”后：

```text
显示政策解释
显示“不会自动视为符合资格”
允许继续
在推荐确认页再次提示
```

## 9.5 Step D：专业偏好

支持：

- 指定专业；
- 专业大类；
- 多个意向专业；
- 暂无明确偏好。

信息层级：

```text
已选偏好
搜索专业
热门/分类探索
排除项（若 API/模型支持）
```

## 9.6 Step E：地区与院校偏好

地区：

- 新疆优先；
- 西北地区；
- 城市；
- 省份/区域；
- 不限。

院校属性：

- 985；
- 211；
- 双一流；
- 公办；
- 民办可接受；
- 中外合作可接受。

IA 不把这些 Soft Preference 伪装成 Hard Eligibility。

## 9.7 Step F：费用与发展偏好

费用：

- 6000；
- 10000；
- 20000；
- 不限；
- 自定义（若契约支持）。

发展：

- 本科就业；
- 考研；
- 考公；
- 事业单位；
- 教师；
- 医疗；
- 国企；
- 出国；
- 尚未确定。

## 9.8 Step G：确认页

必须分组展示：

```text
考试信息
招生路径
资格信息
专业偏好
地区/学校偏好
费用/发展偏好
```

每组提供：

```text
编辑
```

必须显示：

- 当前正式评估可能消耗的 Quota；
- 相同请求重放不会重复扣次的用户友好说明（不暴露内部 hash 细节）；
- UNKNOWN 资格提示；
- 数据/规则适用年度；
- 辅助决策声明。

---

# 10. Candidate & Profile Version IA

## 10.1 用户可理解模型

数据库与 API 使用 Profile Version；前台必须用用户可理解语言表达。

建议：

```text
当前方案
历史版本
```

而不是直接显示：

```text
ExamProfile v7
```

高级详情可以显示版本号。

## 10.2 我的考生方案

```text
我的考生方案
├── 当前方案摘要
│   ├── 年份
│   ├── 分数
│   ├── 位次
│   ├── 科类/选科
│   └── 计划类型
├── 考试信息
├── 资格信息
├── 偏好信息
└── 历史版本
```

## 10.3 修改语义

用户点击“修改考试信息”：

```text
读取当前激活版本
↓
编辑
↓
保存为新版本
↓
激活新版本
```

不得在 IA 中暗示原历史推荐引用被覆盖。

## 10.4 与历史 Recommendation 的关系

历史推荐详情显示：

```text
本次推荐使用的是当时的考生信息快照
```

即使当前 Profile 已更新，也不得把历史推荐页面替换成新 Profile。

---

# 11. Recommendation Submission IA

## 11.1 提交前条件

```text
Authenticated User
+
Owned Candidate
+
Active Exam Profile
+
Active Eligibility Profile
+
Active Preference Profile
+
Resolved RuleSet
+
Resolved Data Versions
```

## 11.2 用户动作

主 CTA：

```text
生成正式推荐
```

客户端必须为一次用户确认动作生成/持有稳定的 Idempotency Key，并在不改变业务请求时重试复用。

## 11.3 提交中状态

页面：`MP-ASSESS-100`

允许状态：

```text
正在校验报考范围
正在匹配招生计划
正在分析历史可比性
正在生成风险分层
正在整理推荐结果
```

这些是 UX 阶段文案，不应泄露内部敏感实现，也不保证逐项实时进度。

## 11.4 禁止行为

- 用户重复点击导致重复创建；
- 失败后自动使用新 Idempotency Key 无限重试；
- 把 AI 超时显示成“推荐失败并已扣次”；
- 客户端自己减少剩余次数；
- 客户端自己计算冲稳保。

---

# 12. Recommendation Result IA

## 12.1 结果总览

```text
[Header]
推荐时间
考生方案摘要
规则年度

[Critical Warnings]
资格不确定
政策冲突相关提示
数据不足
不可比历史

[Tier Summary]
冲 REACH
稳 MATCH
保 SAFE
观察 WATCH

[Result Preview]
按权益展示结果池

[Evidence Summary]
数据年份
规则版本
主要依据

[AI Explanation]
在结构化结果成功后可进入

[Actions]
查看完整结果（受权益控制）
查看证据
重新评估
```

## 12.2 Tier 命名

中文：

```text
冲
稳
保
观察
```

内部：

```text
REACH
MATCH
SAFE
WATCH
```

不得加入：

```text
“录取概率 82%”
```

除非未来完成概率校准、决策变更并形成新版本。

## 12.3 免费用户

基线：

```text
冲 1 所
稳 1 所
保 1 所
```

同时提供：

- 历史位次；
- 数据年份；
- 简单风险提示。

锁定区可以展示：

```text
更多匹配院校
完整专业推荐
高级筛选
多方案能力（仅已上线时）
AI 深度建议（按独立权益）
```

不得把“永久基础会员”描述成“永久无限 AI”。

## 12.4 WATCH

WATCH 不属于“保底失败项”，而是：

- 数据不足；
- 可比性弱；
- 风险需额外观察；
- 其他规则允许但不适合直接进入冲稳保的情况。

## 12.5 Result Item Detail

建议顺序：

```text
院校 + 专业/计划项
↓
Tier / Risk Level
↓
为什么推荐
↓
历史依据
↓
招生计划信息
↓
Hard Rule 通过摘要
↓
资格/数据警告
↓
证据来源
```

推荐最小单位保持：

```text
AdmissionPlanItem
```

页面可以聚合展示，但不得丢失计划项语义。

---

# 13. Evidence & Explainability IA

## 13.1 用户可见证据页

```text
本次推荐依据
├── 考生信息快照
├── 规则适用信息
├── 招生数据版本
├── 历史录取年份
├── 主要风险因子
├── 资格状态
└── 重要提示
```

## 13.2 版本信息层级

普通用户默认：

```text
规则年度：2026
招生计划数据：2026
历史数据：近若干可用年度
```

高级展开：

```text
ruleSetVersion
admissionPlanDataVersion
admissionHistoryDataVersion
controlLineDataVersion
algorithmVersion
```

## 13.3 不暴露

- 内部安全规则细节；
- 可被滥用的风控参数；
- Prompt 私密内容；
- 其他用户数据；
- 管理员备注。

---

# 14. AI Analysis IA

## 14.1 Entry Condition

```text
RecommendationRun = SUCCEEDED
```

才允许出现 AI 分析入口。

## 14.2 页面结构

```text
AI 个性化分析
├── 本次分析基于什么
├── 核心结论
├── 冲刺策略
├── 稳妥策略
├── 保底策略
├── 专业偏好分析
├── 地区选择分析
├── 风险提示
└── 下一步建议
```

实际开放章节由 Product / Entitlement / Prompt Version 决定。

## 14.3 Guard UX

当 AI 输出被 Hard Rule Guard 拒绝：

不得直接显示原始违规内容。

显示：

```text
本次 AI 解释未通过规则一致性检查，请稍后重试。
```

结构化 Recommendation 结果保持可用。

## 14.4 AI Failure

```text
AI Timeout / Failed
≠
Recommendation Failed
```

页面必须区分。

---

# 15. University IA

## 15.1 院校列表

```text
搜索
筛选
排序
结果列表
```

建议筛选：

- 地区；
- 院校属性；
- 办学性质；
- 关键词。

仅展示 API / 数据层真实支持的字段。

## 15.2 院校详情

```text
基础信息
院校标签
所在地
招生计划入口
相关专业
数据更新时间
```

## 15.3 招生计划

必须允许用户感知：

- 年度；
- 计划类型；
- 科类/选科路径；
- 批次；
- 专业/计划项。

不得把不同年度计划混为一个“永久招生计划”。

---

# 16. Major IA

## 16.1 专业列表

```text
搜索
分类浏览
结果列表
```

## 16.2 专业详情

建议：

```text
专业名称
专业分类
基础介绍（有可信内容时）
相关院校
相关招生计划
```

AI 生成内容若存在，必须与事实字段区分。

---

# 17. Content & Policy IA

## 17.1 内容类型

```text
POLICY
ADMISSION_NEWS
GUIDE
ANNOUNCEMENT
```

具体 Enum 以 API / 内容模型为准。

## 17.2 列表层级

```text
重要公告
政策
招生动态
填报指南
```

## 17.3 政策详情

必须优先展示：

- 标题；
- 发布状态；
- 适用年度；
- 来源；
- 更新时间；
- 正文；
- 翻译状态（必要时）。

高风险政策文本在 `ug-CN` 未完成审校时，不应伪装成人工确认翻译。

---

# 18. Membership / Entitlement IA

## 18.1 核心原则

前台不使用：

```text
user.vip = true
```

用户信息结构：

```text
Membership Status
+
Entitlements
+
Quota
```

## 18.2 会员页

```text
当前状态
当前权益
可购买商品
基础会员说明
AI 服务说明
人工服务说明（仅已上线）
常见问题
```

## 18.3 必须明确分离

```text
永久基础会员
≠
永久无限 AI
≠
永久无限人工服务
```

## 18.4 Paywall

当用户点击锁定结果：

```text
当前可见内容
↓
为什么被锁定
↓
解锁后获得什么
↓
价格（来自 Product API）
↓
购买 CTA（Gate-0 通过后）
```

不得使用虚假倒计时或伪造原价。

---

# 19. Order & Payment IA

## 19.1 Gate-0

真实支付入口只有在：

```text
Payment Capability Gate = OPEN
```

后开放。

Gate 未通过：

- 可展示会员价值；
- 可展示“支付能力暂未开放”；
- 不得伪造支付成功流程。

## 19.2 Order Flow

```text
选择 Product
↓
确认订单
↓
创建 Order
↓
创建 Payment Attempt
↓
调用客户端支付能力
↓
客户端返回
↓
进入“支付结果确认中”
↓
查询服务端 Payment Status
↓
serverConfirmed = true
↓
展示支付成功与权益
```

## 19.3 Client Success

客户端支付 success 回调：

```text
不是最终成功页
```

只进入：

```text
MP-ORDER-010 支付处理中
```

## 19.4 Payment Status

### Pending

```text
支付结果确认中
```

### Server Confirmed Success

```text
支付成功
权益已发放 / 正在刷新
```

### Failed / Closed

显示真实服务端状态。

### Unknown / Timeout

```text
暂未确认支付结果，请稍后刷新
```

不得要求用户盲目重复付款。

---

# 20. Quota IA

## 20.1 用户可见

```text
剩余正式评估次数
总获得次数
已使用次数
最近扣次记录
```

具体可见字段受 API Contract 控制。

## 20.2 Ledger Friendly Display

内部 Ledger 可映射为：

```text
2026-07-04  完成一次正式推荐  -1
2026-07-05  活动赠送            +1
```

## 20.3 失败处理

若 Recommendation 因系统原因失败：

页面不得先行显示：

```text
剩余次数 -1
```

Quota 只信任服务端事实。

---

# 21. Me IA

## 21.1 我的首页

```text
登录状态/头像
当前 Candidate
最近推荐
会员与权益
免费次数
收藏
我的订单
设置
反馈
隐私与账号
```

## 21.2 未登录

```text
登录后保存考生方案、推荐历史与权益
[微信登录]
```

仍允许：

- 语言设置；
- 隐私说明；
- 反馈（若 API 支持 Optional）。

---

# 22. Privacy & Account IA

## 22.1 页面

```text
隐私与账号
├── 个人信息
├── 数据使用说明
├── AI 数据最小化说明
├── 推荐历史管理
├── 删除部分记录（按实际能力）
└── 注销账号
```

## 22.2 不默认收集

前台 IA 不新增：

- 身份证号；
- 准考证号；
- 家庭详细地址；
- 父母姓名；
- 父母单位；
- 精确家庭收入。

民族信息不作为普通用户默认必填。

## 22.3 注销

注销必须：

```text
风险说明
↓
再次确认
↓
身份确认（按实现）
↓
提交注销
```

不得把“退出登录”与“注销账号”混为一项。

---

# 23. Error / Empty / Degraded IA

## 23.1 网络错误

```text
网络连接失败
[重试]
```

不得自动创建新的正式推荐业务请求。

## 23.2 数据版本不可用

```text
当前年度招生数据尚未准备完成
```

禁止回退到错误年度并静默推荐。

## 23.3 RuleSet 不可用

```text
当前年度规则暂不可用于正式推荐
```

## 23.4 Empty Result

区分：

### Legitimate Empty

Hard Rule 后没有可推荐项。

```text
根据当前信息，没有找到满足硬性条件的计划项。
```

### System Empty

数据/系统异常。

```text
本次未能正常生成结果，不应扣减正式评估次数。
```

## 23.5 Policy Conflict

当未解决冲突影响结论：

```text
相关政策条件仍在核验中
```

不得让 AI 选边站。

---

# 24. Bilingual IA

## 24.1 Locale

```text
zh-CN
ug-CN
```

## 24.2 切换入口

至少：

- 首页顶部；
- 设置页。

## 24.3 Locale Persistence

游客：

```text
Local Preference
```

已登录：

```text
Local Preference
+
PATCH /api/v1/me/preferences
```

冲突时以明确产品策略同步，不能每次打开随机跳变。

## 24.4 Route Stability

语言切换时：

```text
当前页面语义保持
```

例如：

```text
院校详情 zh-CN
↓ switch
同一院校详情 ug-CN
```

而不是返回首页。

---

# 25. RTL IA Rules

## 25.1 Direction

```text
zh-CN = LTR
ug-CN = RTL
```

## 25.2 必须镜像

- 页面主要水平流向；
- 返回箭头；
- 面包屑方向（Admin 若支持 ug-CN 时）；
- 步骤条方向；
- 列表中方向性图标；
- 左右语义的抽屉/滑动。

## 25.3 不机械镜像

- 数字；
- 年份；
- 分数；
- 位次；
- API ID；
- URL；
- 技术版本号；
- 院校代码；
- 需要保持原方向的图表坐标。

## 25.4 逻辑属性

Step 7 / 实现阶段优先使用逻辑方向语义：

```text
start / end
inline-start / inline-end
```

而不是到处硬编码：

```text
left / right
```

## 25.5 Mixed Content

维吾尔语页面中的：

- `586`；
- `8120`；
- `2026`；
- `REACH`；
- 院校代码；

需要按混合双向文本测试，不依靠肉眼假设。

---

# 26. Admin Web Top-Level IA

## 26.1 一级导航

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

## 26.2 原则

- Admin 是治理系统，不是“小程序大屏版”；
- 高风险发布动作与普通 CRUD 分离；
- RuleSet / DataVersion 发布必须明显；
- PolicyConflict 为一级对象；
- Recommendation Audit 为一级能力；
- AI Log 与 Prompt Version 分离；
- Payment Notification 可审计；
- User Principal 与 Admin Principal 不共用。

---

# 27. Admin Page Map

```text
Admin Web
├── AD-DASH Dashboard
│   └── AD-DASH-001 工作台
│
├── AD-UC 用户与考生
│   ├── AD-USER-001 用户列表
│   ├── AD-USER-010 用户详情
│   ├── AD-CAND-001 Candidate 列表
│   └── AD-CAND-010 Candidate/Profile 版本详情
│
├── AD-PR 政策与规则
│   ├── AD-POLICY-001 政策来源列表
│   ├── AD-POLICY-010 政策来源详情
│   ├── AD-POLICY-020 来源快照
│   ├── AD-RULE-001 RuleSet 列表
│   ├── AD-RULE-010 RuleSet 详情
│   ├── AD-RULE-020 RuleSet 发布确认
│   ├── AD-CONFLICT-001 PolicyConflict 列表
│   └── AD-CONFLICT-010 PolicyConflict 详情/解决
│
├── AD-DG 数据治理
│   ├── AD-DV-001 DataVersion 列表
│   ├── AD-DV-010 DataVersion 详情
│   ├── AD-DV-020 DataVersion 发布确认
│   ├── AD-IMPORT-001 ImportJob 列表
│   ├── AD-IMPORT-010 ImportJob 详情
│   ├── AD-DQ-001 DataQualityIssue 列表
│   └── AD-DQ-010 DataQualityIssue 详情
│
├── AD-ADMISSION 招生数据
│   ├── AD-UNI-001 院校管理
│   ├── AD-UNI-010 院校详情
│   ├── AD-MAJOR-001 专业管理
│   ├── AD-MAJOR-010 专业详情
│   ├── AD-PLAN-001 招生计划
│   ├── AD-PLANITEM-001 计划项
│   ├── AD-HISTORY-001 历史录取
│   └── AD-LINE-001 控制线
│
├── AD-RA 推荐审计
│   ├── AD-REC-001 推荐运行列表
│   ├── AD-REC-010 推荐运行详情
│   ├── AD-REC-020 结果项
│   ├── AD-REC-030 Rule Trace
│   └── AD-REC-040 Snapshot Metadata
│
├── AD-COMMERCE 会员与商业
│   ├── AD-MEMBER-001 Membership
│   ├── AD-ENT-001 Entitlement
│   ├── AD-QUOTA-001 Quota Account
│   ├── AD-LEDGER-001 Quota Ledger
│   ├── AD-PRODUCT-001 Product/SKU
│   ├── AD-ORDER-001 Order
│   ├── AD-PAY-001 Payment
│   ├── AD-PAYNOTIFY-001 Payment Notification
│   └── AD-REFUND-001 Refund
│
├── AD-AI AI 与 Prompt
│   ├── AD-AILOG-001 AI Call Log
│   ├── AD-PROMPT-001 Prompt Template
│   ├── AD-PROMPT-010 Prompt Versions
│   └── AD-PROMPT-020 Prompt Publish
│
├── AD-CONTENT 内容与翻译
│   ├── AD-ARTICLE-001 Article List
│   ├── AD-ARTICLE-010 Article Editor
│   ├── AD-TRANS-001 Translation Review Queue
│   ├── AD-TRANS-010 Translation Review Detail
│   └── AD-FEEDBACK-001 Feedback
│
└── AD-AUDIT 系统审计
    └── AD-OPLOG-001 Operation Log
```

---

# 28. Admin Route Baseline

| Page ID | Route | Core API |
|---|---|---|
| AD-DASH-001 | `/dashboard` | `/admin-api/v1/dashboard/summary` |
| AD-USER-001 | `/users` | `/admin-api/v1/users` |
| AD-USER-010 | `/users/:id` | `/admin-api/v1/users/{userId}` |
| AD-CAND-001 | `/candidates` | `/admin-api/v1/candidates` |
| AD-CAND-010 | `/candidates/:id` | `/admin-api/v1/candidates/{candidateId}` |
| AD-POLICY-001 | `/policy/sources` | `/admin-api/v1/policy-sources` |
| AD-POLICY-010 | `/policy/sources/:id` | `/admin-api/v1/policy-sources/{id}` |
| AD-RULE-001 | `/policy/rule-sets` | `/admin-api/v1/rule-sets` |
| AD-RULE-010 | `/policy/rule-sets/:id` | `/admin-api/v1/rule-sets/{id}` |
| AD-CONFLICT-001 | `/policy/conflicts` | `/admin-api/v1/policy-conflicts` |
| AD-CONFLICT-010 | `/policy/conflicts/:id` | `/admin-api/v1/policy-conflicts/{id}` |
| AD-DV-001 | `/data/versions` | `/admin-api/v1/data-versions` |
| AD-DV-010 | `/data/versions/:id` | `/admin-api/v1/data-versions/{id}` |
| AD-IMPORT-001 | `/data/import-jobs` | `/admin-api/v1/import-jobs` |
| AD-IMPORT-010 | `/data/import-jobs/:id` | `/admin-api/v1/import-jobs/{id}` |
| AD-DQ-001 | `/data/quality-issues` | `/admin-api/v1/data-quality-issues` |
| AD-UNI-001 | `/admission/universities` | `/admin-api/v1/universities` |
| AD-MAJOR-001 | `/admission/majors` | `/admin-api/v1/majors` |
| AD-PLAN-001 | `/admission/plans` | `/admin-api/v1/admission-plans` |
| AD-PLANITEM-001 | `/admission/plan-items` | `/admin-api/v1/admission-plan-items` |
| AD-HISTORY-001 | `/admission/history` | `/admin-api/v1/admission-history` |
| AD-LINE-001 | `/admission/control-lines` | `/admin-api/v1/control-score-lines` |
| AD-REC-001 | `/recommendation-audit` | `/admin-api/v1/recommendations` |
| AD-REC-010 | `/recommendation-audit/:id` | `/admin-api/v1/recommendations/{id}` |
| AD-MEMBER-001 | `/commerce/memberships` | `/admin-api/v1/memberships` |
| AD-ENT-001 | `/commerce/entitlements` | `/admin-api/v1/entitlements` |
| AD-QUOTA-001 | `/commerce/quota-accounts` | `/admin-api/v1/quota-accounts` |
| AD-LEDGER-001 | `/commerce/quota-ledger` | `/admin-api/v1/quota-ledger` |
| AD-PRODUCT-001 | `/commerce/products` | `/admin-api/v1/products` |
| AD-ORDER-001 | `/commerce/orders` | `/admin-api/v1/orders` |
| AD-PAY-001 | `/commerce/payments` | `/admin-api/v1/payments` |
| AD-PAYNOTIFY-001 | `/commerce/payment-notifications` | `/admin-api/v1/payment-notifications` |
| AD-REFUND-001 | `/commerce/refunds` | `/admin-api/v1/refunds` |
| AD-AILOG-001 | `/ai/call-logs` | `/admin-api/v1/ai-call-logs` |
| AD-PROMPT-001 | `/ai/prompt-templates` | `/admin-api/v1/prompt-templates` |
| AD-ARTICLE-001 | `/content/articles` | `/admin-api/v1/content/articles` |
| AD-TRANS-001 | `/content/translations` | `/admin-api/v1/translations/review-queue` |
| AD-FEEDBACK-001 | `/content/feedback` | `/admin-api/v1/feedback` |
| AD-OPLOG-001 | `/audit/operation-logs` | `/admin-api/v1/operation-logs` |

---

# 29. Admin Dashboard IA

## 29.1 P0 Dashboard

建议只显示可行动信息：

```text
用户摘要
正式推荐摘要
失败/异常推荐
待解决 PolicyConflict
待发布/异常 DataVersion
ImportJob 失败
DataQualityIssue 未解决
AI 调用异常
支付异常（Gate 开放后）
待审翻译
用户反馈
```

## 29.2 不做 Vanity Dashboard

P0 不优先制作：

- 无决策价值的大屏动画；
- 3D 地图；
- 炫技实时滚屏；
- 与治理无关的图表堆叠。

---

# 30. Policy & Rule Admin IA

## 30.1 Policy Source

```text
来源基本信息
官方属性/来源类型
原始 URL/标识
快照历史
关联冲突
关联 RuleSet
```

## 30.2 RuleSet

```text
RuleSet 列表
↓
版本详情
↓
规则元数据
↓
关联来源
↓
校验状态
↓
发布
↓
激活
```

发布与激活是不同高风险动作时，页面必须区分。

## 30.3 PolicyConflict

一级页面：

```text
冲突主题
影响年度
影响范围
来源 A
来源 B
状态
影响规则
处理记录
解决动作
```

OD-010 在这里治理，不交给 AI 页面。

---

# 31. Data Governance Admin IA

## 31.1 DataVersion

按数据域区分：

- 招生计划；
- 历史录取；
- 控制线；
- 选科要求；
- 其他冻结模型定义的数据域。

不得用一个“全局数据版本”覆盖所有独立版本。

## 31.2 ImportJob

```text
任务基本信息
来源
目标数据域
状态
开始/结束时间
统计
错误摘要
关联 DataVersion
```

## 31.3 DataQualityIssue

```text
问题级别
数据域
实体
版本
问题说明
发现时间
状态
解决记录
```

CRITICAL 问题应在 Dashboard 可见。

---

# 32. Admission Admin IA

## 32.1 分离主数据与年度事实

```text
University / Major
≠
AdmissionPlan / AdmissionPlanItem
≠
AdmissionHistory
```

页面不得把它们揉成一个超大 CRUD。

## 32.2 年度筛选优先

招生计划、历史录取、控制线页面应优先提供：

- 年度；
- 计划类型；
- 科类/选科；
- 批次；
- DataVersion。

---

# 33. Recommendation Audit Admin IA

## 33.1 目标

必须回答：

> 为什么在某个时间点，对某个 Candidate Profile Version，使用某个 RuleSet、DataVersion Set 与 Algorithm Version，得到这些结果？

## 33.2 详情页 Tabs

```text
Overview
Profiles
Versions
Results
Rule Traces
Snapshots
Warnings
```

## 33.3 Overview

- Recommendation ID；
- User/Candidate 受控摘要；
- 状态；
- 创建时间；
- request hash 摘要；
- idempotency 信息（受权限控制）；
- Quota 结果；
- RuleSet；
- Algorithm Version。

## 33.4 Results

按：

```text
REACH
MATCH
SAFE
WATCH
```

查看。

## 33.5 Rule Trace

必须支持：

- 过滤 Hard Rule；
- 查看被排除原因；
- 查看通过原因摘要；
- 关联规则版本。

不得提供“管理员手工把被 Hard Rule 过滤项塞回历史成功结果”的入口。

---

# 34. Commerce Admin IA

## 34.1 Membership / Entitlement

分开：

```text
Membership
Entitlement
```

不提供 `user.vip` 开关。

## 34.2 Quota

分开：

```text
QuotaAccount
QuotaLedger
```

任何人工调整若未来开放，必须：

- 权限控制；
- 原因；
- 审计日志；
- 不直接静默改余额。

## 34.3 Payment

Gate 打开后：

```text
Order
Payment
PaymentNotification
Refund
```

分别可审计。

---

# 35. AI & Prompt Admin IA

## 35.1 AI Call Log

```text
时间
业务场景
匿名主体
模型路由摘要
Prompt Version
状态
延迟
Token/Cost（若有）
Guard Result
错误
```

## 35.2 Prompt

```text
Prompt Template
↓
Versions
↓
Draft
↓
Publish
```

禁止直接覆盖历史已用 Prompt Version。

## 35.3 Hard Rule Guard

Admin 可查看 Guard 结果，但不能通过“关闭 Guard”让 AI 突破冻结 Hard Rule 原则。

---

# 36. Content & Translation Admin IA

## 36.1 Article

```text
Draft
Review（如实现）
Published
Archived
```

状态以实际模型/API 为准，不擅自新增后端状态。

## 36.2 Translation Queue

高风险政策文本：

```text
待翻译
↓
AI 初译
↓
人工复核
↓
已发布
```

若现有数据库状态命名不同，UI 映射现有状态，不反向修改模型。

## 36.3 Review Detail

建议双栏/对照：

```text
Source Text
Translated Text
```

并显示：

- 来源；
- 适用年度；
- 风险等级；
- 审校人；
- 审校时间。

---

# 37. User Journey A — First-Time Free Assessment

```text
进入小程序
↓
首页
↓
开始智能评估
↓
基础考试信息
↓
条件页（若单列类）
↓
专项资格
↓
专业偏好
↓
地区/院校偏好
↓
费用/发展偏好
↓
确认
↓
点击生成正式推荐
↓
微信登录（若未登录）
↓
创建/同步 Candidate + Profile Versions
↓
服务端检查 Quota
↓
POST /api/v1/recommendations
Idempotency-Key required
↓
生成中
↓
成功
↓
展示免费结果：冲1 / 稳1 / 保1
↓
证据摘要
↓
完整结果转化入口
```

---

# 38. User Journey B — Returning User Reassessment

```text
进入首页/推荐中心
↓
选择 Candidate
↓
查看当前 Profile
↓
修改信息（可选）
↓
保存新 Profile Version
↓
确认
↓
查看 Quota
↓
提交新正式推荐
↓
稳定 Idempotency Key
↓
成功后新增 RecommendationRun
↓
历史 Recommendation 保持不可变
```

---

# 39. User Journey C — Unknown Eligibility

```text
专项资格页
↓
用户选择“不确定”
↓
显示政策解释
↓
明确“不自动视为符合资格”
↓
允许继续
↓
确认页再次提示
↓
Recommendation
↓
Hard Rule / RuleSet 按 UNKNOWN 语义处理
↓
结果页显示相关警告
```

---

# 40. User Journey D — Single Column

```text
2026
↓
planType = SINGLE_COLUMN
↓
动态进入语言路径页
↓
FOREIGN_LANGUAGE / ETHNIC_LANGUAGE / UNKNOWN
↓
如涉及兼报普通类未解决政策条件
↓
显示核验提示
↓
不得由 AI 判定
↓
按已发布 RuleSet 执行
```

---

# 41. User Journey E — Membership Conversion

```text
免费推荐结果
↓
看到冲1 / 稳1 / 保1
↓
查看锁定内容说明
↓
会员与权益页
↓
查看 Membership 与 Entitlements
↓
选择 Product
↓
Gate-0 ?
├── CLOSED → 明确暂不可支付
└── OPEN
    ↓
    创建 Order
    ↓
    Payment Attempt
    ↓
    客户端支付
    ↓
    支付确认中
    ↓
    服务端确认
    ↓
    权益刷新
    ↓
    返回完整结果
```

---

# 42. User Journey F — AI Deep Analysis

```text
成功 Recommendation
↓
AI 分析入口
↓
检查 Entitlement/Quota（按正式商业规则）
↓
POST ai-analyses
↓
处理中
↓
AI Gateway
↓
Hard Rule Guard
├── Pass → 展示分析
└── Reject → 显示一致性检查失败，不展示违规输出
```

---

# 43. Admin Journey A — Publish RuleSet

```text
Admin Login
↓
Policy & Rules
↓
RuleSet List
↓
Open Draft Version
↓
检查来源/元数据/冲突
↓
Publish Confirmation
↓
POST publish
↓
必要时 Activate
↓
Operation Log
```

高风险动作不得在列表页单击即无确认执行。

---

# 44. Admin Journey B — Publish DataVersion

```text
Data Governance
↓
DataVersion
↓
查看 ImportJob
↓
查看 DataQualityIssue
↓
确认版本统计
↓
Publish Confirmation
↓
POST publish
↓
Operation Log
```

CRITICAL DataQualityIssue 未解决时的发布策略必须服从后端契约/业务规则，不由纯前端自行绕过。

---

# 45. Admin Journey C — Resolve PolicyConflict

```text
PolicyConflict List
↓
Conflict Detail
↓
对照来源与快照
↓
记录处理结论
↓
Resolve
↓
如规则改变 → 新 RuleSet Version
↓
Publish / Activate
↓
Operation Log
```

禁止：

```text
修改历史 RuleSet 以“看起来没有发生过冲突”
```

---

# 46. Admin Journey D — Recommendation Audit

```text
Recommendation Audit List
↓
筛选异常/投诉 Recommendation
↓
Open Detail
↓
查看 Profiles
↓
查看 RuleSet + Data Versions
↓
查看 Results
↓
查看 Rule Traces
↓
查看 Snapshots
↓
形成审计结论
```

---

# 47. Page-to-API Mapping — Mini Program

| Page | API |
|---|---|
| 首页 | `GET /api/v1/content/articles`、登录后 Membership/Quota 摘要 API |
| 微信登录 | `POST /api/v1/auth/wechat/login` |
| 我的 | `GET /api/v1/me` |
| Candidate 列表 | `GET /api/v1/candidates` |
| Candidate 详情 | `GET /api/v1/candidates/{candidateId}` |
| 考试 Profile | Exam Profile APIs |
| 资格 Profile | Eligibility Profile APIs |
| 偏好 Profile | Preference Profile APIs |
| 提交推荐 | `POST /api/v1/recommendations` |
| 推荐历史 | `GET /api/v1/recommendations` |
| 推荐详情 | `GET /api/v1/recommendations/{recommendationId}` |
| 结果 | `GET /api/v1/recommendations/{recommendationId}/results` |
| 证据 | `GET /api/v1/recommendations/{recommendationId}/evidence` |
| 院校 | `/api/v1/universities*` |
| 专业 | `/api/v1/majors*` |
| 计划项 | `/api/v1/admission-plan-items/{itemId}` |
| Membership | `GET /api/v1/memberships/me` |
| Entitlement | `GET /api/v1/entitlements/me` |
| Quota | `GET /api/v1/quotas/me` |
| Ledger | `GET /api/v1/quotas/me/ledger` |
| Product | `GET /api/v1/products` |
| Orders | `/api/v1/orders*` |
| Payment Status | `GET /api/v1/orders/{orderId}/payment-status` |
| AI Analysis | Recommendation AI Analysis APIs |
| Content | `/api/v1/content/articles*` |
| Feedback | `POST /api/v1/feedback` |

---

# 48. Page-to-API Mapping — Admin

Admin 页面严格映射 Step 5：

```text
Dashboard       → /admin-api/v1/dashboard/summary
Users           → /admin-api/v1/users
Candidates      → /admin-api/v1/candidates
Policy Sources  → /admin-api/v1/policy-sources
Rule Sets       → /admin-api/v1/rule-sets
Conflicts       → /admin-api/v1/policy-conflicts
Data Versions   → /admin-api/v1/data-versions
Import Jobs     → /admin-api/v1/import-jobs
DQ Issues       → /admin-api/v1/data-quality-issues
Universities    → /admin-api/v1/universities
Majors          → /admin-api/v1/majors
Plans           → /admin-api/v1/admission-plans
Plan Items      → /admin-api/v1/admission-plan-items
History         → /admin-api/v1/admission-history
Control Lines   → /admin-api/v1/control-score-lines
Rec Audit       → /admin-api/v1/recommendations
Membership      → /admin-api/v1/memberships
Entitlement     → /admin-api/v1/entitlements
Quota Account   → /admin-api/v1/quota-accounts
Quota Ledger    → /admin-api/v1/quota-ledger
Products        → /admin-api/v1/products
Orders          → /admin-api/v1/orders
Payments        → /admin-api/v1/payments
Notifications   → /admin-api/v1/payment-notifications
Refunds         → /admin-api/v1/refunds
AI Logs         → /admin-api/v1/ai-call-logs
Prompts         → /admin-api/v1/prompt-templates
Articles        → /admin-api/v1/content/articles
Translations    → /admin-api/v1/translations
Feedback        → /admin-api/v1/feedback
Operation Logs  → /admin-api/v1/operation-logs
```

---

# 49. Access Matrix

## 49.1 Mini Program

| Information Space | Guest | User | Entitled User |
|---|---:|---:|---:|
| 首页 | Yes | Yes | Yes |
| 院校库 | Yes | Yes | Yes |
| 专业库 | Yes | Yes | Yes |
| 政策内容 | Yes | Yes | Yes |
| 本地评估草稿 | Yes | Yes | Yes |
| Candidate 服务端资产 | No | Yes | Yes |
| 正式 Recommendation | No | Quota/Rule | Quota/Rule |
| 推荐历史 | No | Yes | Yes |
| 免费结果 | No | Yes | Yes |
| 完整锁定结果 | No | No/Partial | By Entitlement |
| AI 分析 | No | By Entitlement | By Entitlement |
| Order | No | Yes | Yes |
| Account Privacy | No | Yes | Yes |

## 49.2 Admin

具体 RBAC 权限矩阵由后端安全设计继续约束。IA 只规定：

- 未登录无 Admin 页面；
- User Token 不得进入 Admin；
- Admin Token 不得作为普通 User Principal 操作用户私有 API；
- 高风险 publish / resolve / mutation 需独立权限与审计。

---

# 50. Navigation State Rules

## 50.1 Deep Link

进入需要登录的 Deep Link：

```text
保存目标 Route
↓
Login
↓
回到目标 Route
```

前提：用户仍有对象访问权限。

## 50.2 Object Ownership

即使用户修改 URL 参数/Scene 参数：

```text
candidateId / recommendationId / orderId
```

也必须由服务端校验 ownership。

## 50.3 Language Switch

保持：

- 当前 Route；
- 当前对象 ID；
- 当前筛选条件（可安全保持时）；
- 当前流程步骤。

## 50.4 Assessment Draft

语言切换不应清空评估草稿。

---

# 51. Search IA

## 51.1 P0 Search Domains

至少支持独立：

```text
University Search
Major Search
```

## 51.2 Global Search

全局搜索可作为 P0-B，而非 P0-A 强制：

```text
院校
专业
政策内容
```

必须清晰区分结果类型。

---

# 52. Filter IA

## 52.1 原则

筛选器只提供真实数据字段。

## 52.2 URL / State

Admin Web 筛选条件优先进入 URL Query，便于：

- 刷新保持；
- 分享审计视图；
- 返回列表保持状态。

小程序按平台能力保存页面状态。

## 52.3 Reset

所有复杂筛选提供：

```text
重置
```

---

# 53. Status Vocabulary

## 53.1 Recommendation

前台用户友好文案与后端状态映射，不创造冲突状态。

至少区分：

```text
处理中
成功
失败
```

实际 Enum 以 API 为准。

## 53.2 Payment

至少区分：

```text
待支付
确认中
服务端确认成功
失败/关闭
未知
```

## 53.3 AI

至少区分：

```text
处理中
成功
失败
Guard Rejected
```

## 53.4 Translation

保持业务工作流语义：

```text
待翻译
AI 初译
人工复核
已发布
```

若现有后端状态不同，做显示映射。

---

# 54. P0 Page Priority

## 54.1 P0-A — 核心闭环

必须优先：

1. 首页；
2. 微信登录；
3. Assessment Wizard；
4. Candidate/Profile 同步；
5. Recommendation 提交；
6. Recommendation 生成中；
7. Recommendation 结果；
8. Evidence；
9. Recommendation 历史；
10. 院校列表/详情；
11. 专业列表/详情；
12. Membership/Quota；
13. 我的；
14. 语言切换；
15. Privacy/注销基础；
16. Admin Login；
17. Policy/Rule；
18. DataVersion/Import/DQ；
19. Admission Data；
20. Recommendation Audit；
21. AI Logs；
22. Content/Translation；
23. Operation Logs。

## 54.2 P0-B — Gate / 商业闭环

- Product；
- Order；
- Payment；
- Payment Status；
- Payment Admin；
- Refund View；
- AI 深度分析商业入口。

受 OD-007 / Gate-0 约束。

## 54.3 P1

- PDF 报告；
- 志愿模拟；
- 院校对比；
- 专业对比；
- 人工服务。

---

# 55. Page State Acceptance Baseline

每个 P0 页面进入 Step 7 时至少设计：

```text
Loading
Success
Empty
Error
Unauthorized（适用）
Forbidden（适用）
Degraded（适用）
```

列表页额外：

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

# 56. Analytics Event Baseline

IA 仅定义事件语义，不选择 Analytics 厂商。

建议：

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

禁止把敏感个人字段直接塞入 Analytics Event。

---

# 57. Accessibility & Comprehension Baseline

Step 7 必须考虑：

- 颜色不是冲稳保唯一编码；
- 错误不只靠红色；
- 表单字段有明确 Label；
- UNKNOWN 有文字解释；
- 点击区域适合移动端；
- RTL 键盘与混合文本；
- 大数字（位次）可读；
- 风险提示避免营销化恐吓；
- “辅助决策”与“保证录取”明确区分。

---

# 58. Security UX Baseline

## 58.1 不信任客户端

页面显示不得成为业务真相来源：

- Quota；
- Membership；
- Entitlement；
- Payment Success；
- Eligibility；
- Recommendation Tier。

均以服务端为准。

## 58.2 Admin High-Risk Action

至少：

- RuleSet publish；
- RuleSet activate；
- DataVersion publish；
- PolicyConflict resolve；
- Prompt publish；
- Content publish；
- 未来人工 Quota 调整。

必须有清晰确认与审计语义。

---

# 59. Explicit Non-Goals

Step 6 不做：

- 重构 64 表领域模型；
- 合并 Candidate 与 User；
- 新增 `user.vip`；
- 把 Eligibility 改 Boolean；
- 把 Recommendation 最小单位改成 University；
- 取消 Profile Versioning；
- 取消 Recommendation Immutable 语义；
- 用 AI 替代 Hard Rule；
- 用实时联网搜索作为推荐核心数据；
- 引入微服务；
- 引入 Kafka / RabbitMQ；
- 引入 Vector DB；
- 引入 Kubernetes；
- P0 Full RAG；
- 伪精确录取概率；
- 未通过 Gate-0 的真实支付承诺；
- 把 P1/P2 全部塞进 P0 导航。

---

# 60. Step 7 Handoff

Step 7 `07-ui-specification.md` 必须以本 IA 为上游，至少覆盖：

```text
Design Tokens
Color
Typography
Spacing
Grid
Mini Program Layout
Admin Layout
Navigation Components
Form Components
Assessment Wizard
Recommendation Cards
REACH / MATCH / SAFE / WATCH Visual Language
Risk Visual Language
Evidence Components
Membership / Paywall
Payment Confirmation States
AI Analysis
Table / Filter / Pagination
Admin High-Risk Mutation
Bilingual Typography
RTL
Loading / Empty / Error
High Fidelity Page Specs
```

Step 7 不得改变本文件中的业务信息层级；若要改变，先回写 IA 版本并记录决策。

---

# 61. Acceptance Checklist

```text
Conflict Report                                  ✅
不修改冻结决策                                   ✅
不重设计数据库领域模型                           ✅
不重新选择技术栈                                 ✅
Mini Program / Admin Web 双端                    ✅
User / Admin 信息空间分离                        ✅
P0 TabBar                                         ✅
完整 Page Map                                     ✅
Route Baseline                                    ✅
登录时机                                          ✅
游客浏览                                          ✅
Assessment Wizard                                 ✅
2026 TRADITIONAL_WENLI                            ✅
2026 SINGLE_COLUMN 动态路径                       ✅
2027 XJ_3_1_2 预留                                ✅
Eligibility UNKNOWN                               ✅
Profile Versioning                                ✅
Recommendation Idempotency UX                     ✅
Quota 防误扣 UX                                   ✅
REACH / MATCH / SAFE / WATCH                      ✅
不输出伪精确概率                                  ✅
Evidence / Version                                ✅
AI after structured recommendation                ✅
AI Hard Rule Guard                                ✅
Membership / Entitlement 分离                     ✅
Payment Server Confirmation                       ✅
Gate-0                                            ✅
zh-CN / ug-CN                                     ✅
RTL                                               ✅
PolicyConflict Admin                              ✅
DataVersion Admin                                 ✅
Recommendation Audit                              ✅
Translation Review                                ✅
Page-to-API Mapping                               ✅
P0 / P1 边界                                      ✅
Step 7 Handoff                                    ✅
```

---

# 62. Step 6 Status

```text
STEP 6
Information Architecture V1.0
=
COMPLETED
```

下一步：

```text
Step 7
UI Specification / High Fidelity

建议文件：
07-ui-specification.md
```

完成 Step 7 后进入：

```text
Checkpoint B
```
