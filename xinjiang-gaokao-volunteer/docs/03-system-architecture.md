# <a name="新疆高考-ai-志愿助手"></a>新疆高考 AI 志愿助手
# <a name="系统架构设计-v1.0"></a>系统架构设计 V1.0
-----
## <a name="文档信息"></a>0. 文档信息
**项目名称：** 新疆高考 AI 志愿助手
**文档名称：** 系统架构设计
**建议文件名：** 03-system-architecture.md
**版本：** V1.0
**状态：** Architecture Baseline
**适用范围：** MVP 至初期商业化阶段

**上游文档：**

- 01-prd.md
- 02-xinjiang-business-rules.md

**下游文档：**

- 04-database-design.md
- 05-api-contract.md
- 06-information-architecture.md
- 07-ui-specification.md
- 08-ai-architecture.md
- 09-security-privacy.md
- Codex Skills
- Codex Development Tasks
-----
# <a name="架构目标"></a>1. 架构目标
本系统架构必须同时满足以下目标：

1. 个人开发者可以维护。
1. 适合 Codex 多会话协作开发。
1. 支持新疆 2026 年现行业务规则。
1. 为 2027 年“3+1+2”规则切换预留能力。
1. 支持普通类、单列类及后续专项规则扩展。
1. 支持中文与维吾尔语。
1. 支持免费三次推荐机制。
1. 支持会员与支付。
1. 支持 AI 深度分析。
1. 支持人工服务扩展。
1. 推荐结果必须可审计。
1. 数据与规则能够独立版本化。
1. 不依赖大模型决定硬规则。
1. 初期部署成本可控。
1. 未来业务增长时可以渐进式拆分。
-----
# <a name="核心架构原则"></a>2. 核心架构原则
-----
## <a name="原则一模块化单体优先"></a>2.1 原则一：模块化单体优先
本项目第一阶段采用：

Modular Monolith
模块化单体

而不是：

Microservices
微服务

Spring Modulith 官方定位本身就是面向 Spring Boot 的领域模块化应用工具，并支持模块边界、模块交互、测试和事件机制。

本项目采用该思想，但不追求形式主义。

核心目标是：

一个部署单元
\+
多个清晰业务模块

-----
## <a name="原则二一个后端进程"></a>2.2 原则二：一个后端进程
MVP 阶段：

1 个 Spring Boot Application

负责：

- 用户
- 考生画像
- 政策规则
- 招生数据
- 推荐
- 会员
- 支付
- AI
- 内容
- 后台 API

禁止 MVP 设计：

user-service
candidate-service
recommendation-service
payment-service
ai-service

分别部署。

-----
## <a name="原则三业务模块隔离"></a>2.3 原则三：业务模块隔离
虽然是单体：

模块 A

不能随意：

直接调用模块 B 的 Mapper

更不能：

跨模块直接修改数据库表

推荐：

模块 A
↓
模块 B Application API

或者：

模块 A
↓
Domain Event
↓
模块 B

-----
## <a name="原则四数据库是事实层ai-是解释层"></a>2.4 原则四：数据库是事实层，AI 是解释层
核心架构：

官方规则
\+
结构化招生数据
\+
推荐算法
\=
正式推荐结果

然后：

正式推荐结果
\+
用户偏好
\=
AI 深度解释

禁止：

用户 586 分
↓
LLM
↓
推荐大学

-----
## <a name="原则五核心正确性不依赖-redis"></a>2.5 原则五：核心正确性不依赖 Redis
Redis 可以失效。

系统仍必须正确。

因此：

MySQL
\=
业务事实来源

Redis
\=
缓存 / 限流 / 临时状态

禁止把：

- 剩余免费次数
- 支付状态
- 会员状态
- 正式推荐结果

只存在 Redis。

-----
## <a name="原则六年度规则版本化"></a>2.6 原则六：年度规则版本化
系统必须支持：

XJ-2026-V1
XJ-2026-V2
XJ-2027-V1

禁止：

**if** (year == 2026) {
}

散落整个项目。

-----
## <a name="原则七数据版本独立于应用版本"></a>2.7 原则七：数据版本独立于应用版本
必须区分：

Application Version

例如：

v1.3.0

与：

Admission Data Version

例如：

XJ-ADMISSION-2026-20260701

以及：

Rule Set Version

例如：

XJ-RULE-2026-V3

-----
# <a name="最终技术架构决策"></a>3. 最终技术架构决策
-----
## <a name="adr-001仓库模式"></a>ADR-001：仓库模式
决定：

Monorepo

即：

一个 Git 仓库

管理：

- 微信小程序
- Java 后端
- Vue 管理后台
- 数据流水线
- 文档
- 基础设施配置
-----
## <a name="adr-002后端模式"></a>ADR-002：后端模式
决定：

Spring Boot Modular Monolith

-----
## <a name="adr-003后端语言"></a>ADR-003：后端语言
决定：

Java 21

原因：

- 用户已有 Java 开发背景
- 适合长期业务系统
- 推荐规则适合强类型建模
- Codex 对 Java 工程支持成熟
- 与 Spring 技术体系一致
-----
## <a name="adr-004后端框架"></a>ADR-004：后端框架
决定：

Spring Boot 4.1.x

-----
## <a name="adr-005模块化工具"></a>ADR-005：模块化工具
决定：

Spring Modulith 2.1.x

用途：

- 模块边界检查
- 模块测试
- 应用事件
- 架构文档辅助生成

不要求所有代码深度绑定 Modulith。

-----
## <a name="adr-006数据库访问"></a>ADR-006：数据库访问
决定：

MyBatis-Plus 3.5.x

复杂查询继续允许：

Mapper XML

原则：

简单 CRUD
→ MyBatis-Plus

复杂推荐 SQL
→ XML / 手写 SQL

禁止使用大量 Wrapper 拼接复杂推荐算法 SQL。

-----
## <a name="adr-007数据库"></a>ADR-007：数据库
决定：

MySQL 8.4 LTS

-----
## <a name="adr-008数据库迁移"></a>ADR-008：数据库迁移
决定：

Flyway

所有 Schema 修改必须版本化。

禁止：

开发者直接登录生产数据库手改表

-----
## <a name="adr-009缓存"></a>ADR-009：缓存
决定：

Redis-compatible Cache

使用场景：

- 推荐结果短期缓存
- 请求频率限制
- 登录临时状态
- 热点院校数据
- AI 请求防重复
- 分布式锁的有限场景

但不作为核心业务事实来源。

-----
## <a name="adr-010微信端"></a>ADR-010：微信端
决定：

原生微信小程序
\+
TypeScript

不采用第一版：

uni-app
Taro
Flutter

原因：

产品只面向微信小程序时，原生方案减少跨平台抽象层。

-----
## <a name="adr-011管理后台"></a>ADR-011：管理后台
决定：

Vue 3
\+
TypeScript
\+
Vite
\+
Element Plus

-----
## <a name="adr-012ai-集成"></a>ADR-012：AI 集成
决定：

Spring AI 2.0.x

但通过项目内部：

AI Gateway

再次抽象。

业务模块禁止直接依赖具体模型。

-----
## <a name="adr-013python"></a>ADR-013：Python
决定：

使用

但仅用于：

离线数据流水线

例如：

- Excel 清洗
- PDF 数据解析辅助
- 数据格式转换
- 历史数据统计
- 批量质量检测

禁止 Python 进入 MVP 在线核心请求链路。

-----
## <a name="adr-014rag"></a>ADR-014：RAG
决定：

P0 不建设完整 RAG

P1 再进入。

-----
## <a name="adr-015消息队列"></a>ADR-015：消息队列
决定：

P0 不使用 Kafka
P0 不使用 RabbitMQ

采用：

Application Event
\+
Database Event Publication
\+
Scheduled Worker

-----
## <a name="adr-016搜索引擎"></a>ADR-016：搜索引擎
决定：

P0 不使用 Elasticsearch
P0 不使用 OpenSearch

-----
## <a name="adr-017api-gateway"></a>ADR-017：API Gateway
决定：

P0 不使用

-----
## <a name="adr-018容器编排"></a>ADR-018：容器编排
决定：

P0 不使用 Kubernetes

-----
# <a name="系统总体架构图"></a>4. 系统总体架构图
`                    `┌───────────────────────┐
`                    `│   微信原生小程序       │
`                    `│ TypeScript/WXML/WXSS  │
`                    `└───────────┬───────────┘
`                                `│
`                                `│ HTTPS REST API
`                                `▼
`                     `┌─────────────────────┐
`                     `│   Nginx / Reverse   │
`                     `│       Proxy         │
`                     `└──────────┬──────────┘
`                                `│
`                                `▼
┌──────────────────────────────────────────────────────┐
│                                                     │
│             Spring Boot Modular Monolith            │
│                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐    │
│  │ Identity │ │Candidate │ │ Policy & Rules   │    │
│  └──────────┘ └──────────┘ └──────────────────┘    │
│                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐    │
│  │Admission │ │Recommend │ │ Membership       │    │
│  └──────────┘ └──────────┘ └──────────────────┘    │
│                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐    │
│  │ Payment  │ │ AI       │ │ Content / i18n   │    │
│  └──────────┘ └──────────┘ └──────────────────┘    │
│                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐    │
│  │ Report   │ │ Audit    │ │ Admin            │    │
│  └──────────┘ └──────────┘ └──────────────────┘    │
│                                                     │
└──────────────┬──────────────────┬────────────────────┘
`               `│                  │
`               `▼                  ▼
`        `┌────────────┐      ┌─────────────┐
`        `│ MySQL 8.4 │      │ Redis-compatible │
`        `│    LTS     │      │    Cache     │
`        `└────────────┘      └─────────────┘

`               `│
`               `▼

`       `┌─────────────────┐
`       `│ Object Storage  │
`       `│ Reports / Raw   │
`       `│ Data / Files    │
`       `└─────────────────┘


离线侧：

┌──────────────────────┐
│ Python Data Pipeline │
├──────────────────────┤
│ Raw                  │
│ Staging              │
│ Normalize            │
│ Validate             │
│ Review               │
│ Publish              │
└──────────┬───────────┘
`           `│
`           `▼
`     `MySQL Published Data

-----
# <a name="git-仓库结构"></a>5. Git 仓库结构
结合当前实际仓库：

My-AI-Code-Project/
└── xinjiang-gaokao-volunteer/

建议最终：

xinjiang-gaokao-volunteer/
│
├── README.md
├── AGENTS.md
├── .gitignore
├── .editorconfig
├── docker-compose.yml
│
├── docs/
│   ├── 00-project-charter.md
│   ├── 01-prd.md
│   ├── 02-xinjiang-business-rules.md
│   ├── 03-system-architecture.md
│   ├── 04-database-design.md
│   ├── 05-api-contract.md
│   ├── 06-information-architecture.md
│   ├── 07-ui-specification.md
│   ├── 08-ai-architecture.md
│   ├── 09-security-privacy.md
│   └── adr/
│
├── backend/
│   ├── pom.xml
│   └── src/
│
├── miniprogram/
│   ├── package.json
│   ├── project.config.json
│   └── miniprogram/
│
├── admin-web/
│   ├── package.json
│   └── src/
│
├── data-pipeline/
│   ├── pyproject.toml
│   ├── src/
│   ├── tests/
│   └── pipelines/
│
├── infrastructure/
│   ├── docker/
│   ├── nginx/
│   ├── mysql/
│   └── scripts/
│
├── contracts/
│   ├── openapi/
│   ├── schemas/
│   └── events/
│
├── data/
│   ├── raw/
│   ├── staging/
│   └── samples/
│
└── .codex/
`    `└── skills/

-----
# <a name="为什么采用-monorepo"></a>6. 为什么采用 Monorepo
本项目由一个人维护。

采用：

backend repository
frontend repository
admin repository
data repository

会增加：

- 文档同步
- API 同步
- 版本同步
- Codex 上下文切换
- Git 管理成本

因此选择：

一个仓库
多个应用

-----
# <a name="backend-不采用-maven-多模块"></a>7. Backend 不采用 Maven 多模块
这是一个重要决定。

虽然整体系统是：

模块化单体

但第一版不建议：

backend/
├── identity-module/
├── candidate-module/
├── recommendation-module/
├── payment-module/
└── ...

每个成为独立 Maven module。

第一阶段采用：

一个 Maven Project
\+
Package Based Modules

-----
# <a name="backend-包结构"></a>8. Backend 包结构
根包：

com.xjgaokao

建议：

com.xjgaokao
│
├── identity
├── candidate
├── policy
├── admission
├── recommendation
├── membership
├── payment
├── ai
├── content
├── report
├── feedback
├── audit
├── admin
└── shared

-----
# <a name="每个业务模块内部结构"></a>9. 每个业务模块内部结构
例如：

recommendation/
├── api/
├── application/
├── domain/
└── infrastructure/

-----
## <a name="api"></a>9.1 api
负责：

- Controller
- Request DTO
- Response DTO
-----
## <a name="application"></a>9.2 application
负责：

- Use Case
- Application Service
- Transaction Boundary
-----
## <a name="domain"></a>9.3 domain
负责：

- Domain Model
- Domain Service
- Rule
- Value Object
- Domain Event
-----
## <a name="infrastructure"></a>9.4 infrastructure
负责：

- Mapper
- Database
- External API
- Provider Adapter
-----
# <a name="禁止传统全局分层"></a>10. 禁止传统全局分层
禁止：

controller/
service/
mapper/
entity/
dto/

整个项目共用。

因为最终会出现：

controller/
├── UserController
├── RecommendationController
├── PaymentController
├── PolicyController
└── 80个Controller

无法形成领域边界。

-----
# <a name="identity-模块"></a>11. Identity 模块
职责：

identity

管理：

- 微信登录
- 手机绑定
- 用户身份
- Token
- 账号状态
- 注销
- 登录审计

核心对象：

User
UserIdentity
WechatIdentity
PhoneIdentity
Session

-----
# <a name="candidate-模块"></a>12. Candidate 模块
职责：

- 考生主体
- 考试画像
- 资格画像
- 偏好画像
- 模拟方案

对象：

Candidate
CandidateExamProfile
CandidateEligibilityProfile
CandidatePreferenceProfile

-----
# <a name="policy-模块"></a>13. Policy 模块
这是新疆特色核心模块。

职责：

- 政策来源
- 年度规则集
- 规则版本
- 资格规则
- 批次规则
- 兼报规则
- 政策冲突

对象：

PolicySource
RuleSet
BusinessRule
PolicyConflict
BatchRule
EligibilityRule

-----
# <a name="admission-模块"></a>14. Admission 模块
职责：

- 大学
- 专业
- 招生计划
- 招生计划项
- 历史录取
- 控制线
- 数据版本

对象：

University
Major
AdmissionPlan
AdmissionPlanItem
AdmissionHistory
ControlScoreLine
DataVersion

-----
# <a name="recommendation-模块"></a>15. Recommendation 模块
系统核心模块。

职责：

Profile Validation

Rule Resolution

Hard Filtering

Historical Comparability

Risk Scoring

Preference Ranking

Tier Assignment

输出：

REACH
MATCH
SAFE
WATCH

-----
# <a name="membership-模块"></a>16. Membership 模块
职责：

- 免费次数
- 会员权益
- 永久会员
- AI 权益
- 使用记录

对象：

Membership
Entitlement
UsageQuota
FreeAssessmentQuota

-----
# <a name="payment-模块"></a>17. Payment 模块
职责：

- 创建订单
- 支付请求
- 支付回调
- 退款
- 对账
- 支付状态机

对象：

Order
Payment
PaymentAttempt
Refund
PaymentNotification

-----
# <a name="ai-模块"></a>18. AI 模块
职责：

- 模型 Provider
- Prompt Version
- AI 请求
- JSON 输出
- 成本统计
- 超时
- 重试
- 降级

对象：

AiProvider
AiModel
PromptTemplate
PromptVersion
AiRequest
AiResponse
AiUsage

-----
# <a name="content-模块"></a>19. Content 模块
职责：

- 政策资讯
- 公告
- 院校介绍
- 专业介绍
- 双语内容
-----
# <a name="report-模块"></a>20. Report 模块
职责：

- VIP 深度报告
- PDF 任务
- 报告版本
- 文件存储

第一版可以先：

HTML Report

后续再：

PDF

-----
# <a name="audit-模块"></a>21. Audit 模块
职责：

- 推荐审计
- 管理员操作
- 数据发布
- 规则修改
- AI 调用
-----
# <a name="shared-模块限制"></a>22. Shared 模块限制
shared

只能保存真正跨模块基础能力：

- Result
- ErrorCode
- Clock
- ID 类型
- 基础异常
- TraceId
- PageResult

禁止把所有公共代码扔进去。

特别禁止：

shared/
└── utils/
`    `├── UserUtils
`    `├── RecommendationUtils
`    `├── PaymentUtils
`    `└── EverythingUtils

-----
# <a name="模块调用原则"></a>23. 模块调用原则
允许：

Recommendation
↓
Candidate Public API

允许：

Recommendation
↓
Admission Query API

禁止：

RecommendationService
↓
CandidateMapper

禁止：

PaymentService
↓
MembershipMapper.insert(...)

-----
# <a name="模块事件"></a>24. 模块事件
例如支付成功：

Payment Module
↓
PaymentSucceededEvent
↓
Membership Module
↓
Grant Entitlement

而不是：

paymentService {
`    `membershipMapper.updateVip();
}

-----
# <a name="推荐完整请求链路"></a>25. 推荐完整请求链路
微信小程序
↓
POST /api/v1/recommendations
↓
Authentication
↓
Idempotency Check
↓
Candidate Profile Load
↓
Rule Set Resolve
↓
Application Scope Filter
↓
Plan Compatibility Filter
↓
Batch Filter
↓
Special Qualification Filter
↓
Program Constraint Filter
↓
Historical Comparability
↓
Risk Score
↓
Preference Score
↓
Tier Assignment
↓
Persist Recommendation
↓
Free Quota Transaction
↓
返回基础结果

-----
# <a name="ai-不进入核心同步推荐链路"></a>26. AI 不进入核心同步推荐链路
建议：

推荐引擎
↓
先返回结构化结果

然后：

VIP用户
↓
AI Analysis

原因：

避免：

- LLM 超时导致无推荐
- 模型故障导致主功能不可用
- Token 成本失控
-----
# <a name="免费三次架构"></a>27. 免费三次架构
核心事实保存在：

MySQL

流程：

Begin Transaction

↓

检查 request\_hash

↓

检查是否已有成功结果

↓

若重复
返回旧结果
不扣次数

↓

若新请求
检查剩余次数

↓

生成推荐

↓

保存 RecommendationRun

↓

成功后扣减次数

↓

Commit

-----
# <a name="redis-在免费次数中的角色"></a>28. Redis 在免费次数中的角色
Redis 只负责：

短时间重复点击保护

例如：

lock:recommendation:{userId}:{requestHash}

不能负责最终次数。

-----
# <a name="rule-engine-架构"></a>29. Rule Engine 架构
这是本项目非常重要的决定。

P0 不使用：

Drools

也不允许数据库存储任意：

SpEL
Groovy
JavaScript

然后在线执行。

原因：

- 安全风险
- 调试困难
- Codex 容易生成不可控表达式
- 规则复杂后维护困难
-----
# <a name="p0-规则模型"></a>30. P0 规则模型
采用：

Typed Java Rule
\+
Database Rule Metadata

例如：

**interface** EligibilityRule {
`    `RuleResult evaluate(RuleContext context);
}

具体：

SingleColumnCompatibilityRule
SouthXinjiangEligibilityRule
ApplicationScopeRule
BatchEligibilityRule

-----
# <a name="数据库保存什么"></a>31. 数据库保存什么
数据库保存：

rule\_code
rule\_version
source
status
priority
effective\_from
effective\_to
parameters

Java 保存：

真正执行逻辑

-----
# <a name="为什么不完全动态规则"></a>32. 为什么不完全动态规则
例如：

XJ-2026-PLAN-002

可以在数据库：

enabled = true

priority = 100

effectiveYear = 2026

但不能让管理员随便输入：

candidate.getXXX() && runtime.exec(...)

-----
# <a name="推荐引擎内部结构"></a>33. 推荐引擎内部结构
RecommendationEngine
│
├── ProfileValidator
├── RuleSetResolver
├── CandidatePoolBuilder
├── HardRulePipeline
├── ComparabilityService
├── RiskScorer
├── PreferenceScorer
├── TierClassifier
└── ExplanationContextBuilder

-----
# <a name="candidate-pool-builder"></a>34. Candidate Pool Builder
第一步使用 SQL 缩小范围。

例如：

exam\_year
plan\_type
subject\_track
batch

先查询。

禁止：

把全部全国院校数据加载到 Java 内存

-----
# <a name="hard-rule-pipeline"></a>35. Hard Rule Pipeline
采用：

Ordered Rule Chain

例如：

ApplicationScopeRule
↓
PlanTypeRule
↓
BatchRule
↓
SpecialEligibilityRule
↓
SubjectRequirementRule
↓
ProgramConstraintRule

-----
# <a name="risk-scorer"></a>36. Risk Scorer
输入：

Candidate Rank
Historical Rank
Quota
Volatility
Comparability
Data Quality
Plan Change

输出：

RiskScore
RiskLevel
ReasonCodes

-----
# <a name="ai-gateway"></a>37. AI Gateway
架构：

Business Module
↓
AiUseCase
↓
AiGateway
↓
Provider Adapter

例如：

DeepAnalysisUseCase
↓
AiGateway
├── OpenAICompatibleAdapter
├── DeepSeekAdapter
└── FutureAdapter

-----
# <a name="禁止业务层直接调用模型-sdk"></a>38. 禁止业务层直接调用模型 SDK
禁止：

RecommendationService {
`    `openAiClient.chat(**...**);
}

正确：

RecommendationAnalysisService {
`    `aiGateway.generate(**...**);
}

-----
# <a name="ai-use-case"></a>39. AI Use Case
定义业务场景：

RECOMMENDATION\_EXPLANATION

DEEP\_REPORT

MAJOR\_COMPARISON

CITY\_ANALYSIS

STUDY\_PATH\_ADVICE

TRANSLATION\_DRAFT

POLICY\_SUMMARY

每种场景独立：

- Prompt
- 模型
- Token 上限
- 超时
- 成本
- 输出 Schema
-----
# <a name="ai-输出"></a>40. AI 输出
必须：

Structured Output

例如：

{
`  `"summary": "...",
`  `"strengths": [],
`  `"risks": [],
`  `"advice": []
}

收到结果以后：

JSON Schema Validation

失败：

Retry
↓
Fallback

-----
# <a name="ai-模型路由"></a>41. AI 模型路由
不把系统写死：

所有任务 = 一个最贵模型

建议：

基础摘要
→ 低成本模型

VIP深度报告
→ 高质量模型

维语初译
→ 支持能力较好的模型

JSON修复
→ 低成本模型

-----
# <a name="ai-prompt-版本化"></a>42. AI Prompt 版本化
保存：

prompt\_code
prompt\_version
locale
template
status
created\_at

例如：

RECOMMENDATION\_DEEP\_ANALYSIS
V1

-----
# <a name="p0-不建设完整-rag"></a>43. P0 不建设完整 RAG
这是正式架构决定。

第一版用户最核心需求是：

志愿推荐

其主要依据是：

结构化数据
\+
规则

不是全文知识库。

因此第一版不引入：

- Vector DB
- Embedding Pipeline
- Chunking Framework
- Retriever
- Reranker
-----
# <a name="rag-进入-p1"></a>44. RAG 进入 P1
以下需求成熟后：

新疆政策问答

招生章程问答

学校政策查询

再加入 RAG。

-----
# <a name="不使用-redis-vector-作为-p0-rag"></a>45. 不使用 Redis Vector 作为 P0 RAG
即使缓存系统未来具备向量能力，也不能因为：

已经有 Redis

就强行把它当知识库。

向量检索技术选型在 P1 单独评估。

-----
# <a name="python-data-pipeline"></a>46. Python Data Pipeline
Python 项目：

data-pipeline/

不对互联网用户提供 API。

-----
# <a name="数据流水线"></a>47. 数据流水线
Source
↓
Raw
↓
Staging
↓
Normalize
↓
Validate
↓
Conflict Detection
↓
Manual Review
↓
Publish

-----
# <a name="raw-layer"></a>48. Raw Layer
原始数据不得覆盖。

保存：

- 原始 Excel
- 原始 CSV
- 原始 PDF
- 原始 HTML 快照
- 来源元数据
-----
# <a name="staging-layer"></a>49. Staging Layer
将不同格式转为：

统一临时格式

例如：

university\_raw
major\_raw
admission\_plan\_raw

-----
# <a name="normalize-layer"></a>50. Normalize Layer
完成：

学校名称标准化
专业名称标准化
地区代码标准化
计划类型标准化
批次标准化

-----
# <a name="validate-layer"></a>51. Validate Layer
检测：

缺失
重复
异常位次
异常分数
年份冲突
学校名称冲突
专业名称冲突

-----
# <a name="publish-layer"></a>52. Publish Layer
只有：

APPROVED

数据可以进入：

Published Admission Data

推荐引擎默认只读 Published。

-----
# <a name="数据发布不能直接覆盖"></a>53. 数据发布不能直接覆盖
流程：

Data Version A
↓
Data Version B Draft
↓
Review
↓
Publish B

然后：

active\_version = B

如发现问题：

rollback → A

-----
# <a name="微信小程序架构"></a>54. 微信小程序架构
建议：

miniprogram/
├── app.ts
├── app.json
├── app.wxss
│
├── pages/
├── components/
├── services/
├── stores/
├── locales/
├── utils/
├── types/
└── config/

-----
# <a name="pages"></a>55. Pages
初步：

pages/
├── home/
├── login/
├── exam-profile/
├── eligibility/
├── preference/
├── recommendation/
├── recommendation-detail/
├── university/
├── major/
├── favorites/
├── membership/
├── order/
├── profile/
└── settings/

最终以第 6 步页面信息架构为准。

-----
# <a name="api-client"></a>56. API Client
统一：

services/http.ts

禁止每个页面自己：

wx.request(...)

-----
# <a name="frontend-state"></a>57. Frontend State
第一版不引入复杂 Redux 风格框架。

状态分：

Auth State
Candidate Draft
Locale State
Recommendation Draft

-----
# <a name="中文-维吾尔语"></a>58. 中文 / 维吾尔语
静态资源：

locales/
├── zh-CN.ts
└── ug-CN.ts

-----
# <a name="direction"></a>59. Direction
zh-CN
→ LTR

ug-CN
→ RTL

-----
# <a name="不做简单字符串翻译"></a>60. 不做简单字符串翻译
组件必须支持：

direction

例如：

PageContainer
FormRow
NavigationBar
ResultCard

根据 locale 切换布局。

-----
# <a name="数字与-rtl-混排"></a>61. 数字与 RTL 混排
特殊测试：

586

8,120

2026

985

在 RTL 页面必须单独验证。

-----
# <a name="动态内容翻译"></a>62. 动态内容翻译
数据库内容不能只有：

title

长期设计：

content
\+
content\_translation

例如：

entity\_type
entity\_id
locale
field\_name
translated\_text
review\_status

-----
# <a name="ai-维语内容"></a>63. AI 维语内容
流程：

中文可信结构化结果
↓
维语生成/翻译
↓
质量状态

政策高风险文本：

AI Draft
↓
Human Review
↓
Published

-----
# <a name="管理后台架构"></a>64. 管理后台架构
admin-web/
├── src/
│   ├── api/
│   ├── views/
│   ├── components/
│   ├── stores/
│   ├── router/
│   ├── locales/
│   └── types/

-----
# <a name="admin-模块"></a>65. Admin 模块
包括：

Dashboard

User Management

Candidate Profiles

Admission Data

Policy Sources

Rule Sets

Policy Conflicts

Recommendation Audit

Membership

Orders

Payments

AI Logs

Prompt Versions

Translation Review

Feedback

System Config

-----
# <a name="用户-api-与后台-api-分离"></a>66. 用户 API 与后台 API 分离
用户：

/api/v1/\*\*

后台：

/admin-api/v1/\*\*

-----
# <a name="用户认证与管理员认证分离"></a>67. 用户认证与管理员认证分离
禁止：

同一套 Token
\+
role=ADMIN

简单混用。

应区分：

User Principal

与：

Admin Principal

-----
# <a name="微信登录架构"></a>68. 微信登录架构
逻辑：

Mini Program
↓
获得临时登录凭证
↓
POST Backend
↓
Backend 与微信侧交互
↓
解析业务身份
↓
创建/查询 User
↓
生成本系统登录态

-----
# <a name="app-secret"></a>69. App Secret
必须：

Server Side Only

禁止：

- 小程序代码
- Git 仓库
- 前端配置文件
- Codex Prompt

出现生产 Secret。

-----
# <a name="手机号"></a>70. 手机号
手机号绑定与微信身份分离：

User
├── WechatIdentity
└── PhoneIdentity

这样用户可以：

微信登录
\+
手机号绑定

而不是创建两个用户。

-----
# <a name="token"></a>71. Token
建议：

Short-lived Access Token
\+
Refresh Mechanism

第一版也可以采用受控简化方案，但接口层必须预留刷新能力。

-----
# <a name="ai-隐私隔离"></a>72. AI 隐私隔离
发送模型：

score
rank
planType
preferences

不发送：

phone
openid
name
身份证

-----
# <a name="payment-架构"></a>73. Payment 架构
支付模块采用：

Payment Provider Adapter

-----
# <a name="gate-0"></a>74. Gate-0
支付开发前必须完成：

主体资格核验
商户资格核验
服务类目核验
支付产品能力核验

在完成前：

Payment Module
\=
Interface + Mock

-----
# <a name="订单状态机"></a>75. 订单状态机
建议：

CREATED
↓
PAYING
↓
PAID
↓
FULFILLED

异常：

CANCELLED
CLOSED
REFUNDING
REFUNDED
FAILED

-----
# <a name="绝不相信客户端支付成功"></a>76. 绝不相信客户端“支付成功”
禁止：

小程序：
支付成功
↓
直接开 VIP

正确：

服务端确认
↓
订单状态更新
↓
PaymentSucceededEvent
↓
Membership Grant

-----
# <a name="支付幂等"></a>77. 支付幂等
必须：

provider\_transaction\_id

唯一。

重复回调：

不得重复发会员

-----
# <a name="永久会员架构"></a>78. 永久会员架构
权益：

MembershipEntitlement

例如：

FULL\_RECOMMENDATION
ADVANCED\_FILTER
PLAN\_COMPARISON

而不是：

user.vip = true

-----
# <a name="ai-权益独立"></a>79. AI 权益独立
例如：

DEEP\_REPORT\_MONTHLY\_LIMIT

或：

DEEP\_REPORT\_CREDIT

独立于：

PERMANENT\_MEMBERSHIP

这样以后商业模式可以调整。

-----
# <a name="缓存策略"></a>80. 缓存策略
可以缓存：

University Detail
Major Detail
Policy List
Hot Admission Data
Recommendation Result

-----
# <a name="cache-key"></a>81. Cache Key
规范：

xjgaokao:{module}:{version}:{key}

例如：

xjgaokao:admission:v3:university:10001

-----
# <a name="推荐缓存必须包含版本"></a>82. 推荐缓存必须包含版本
错误：

recommendation:user:123

正确：

recommendation:
requestHash:
ruleVersion:
dataVersion

-----
# <a name="异步任务"></a>83. 异步任务
异步场景：

- AI 深度报告
- PDF
- 数据导入
- 数据质量检测
- 通知
- 大批量翻译
-----
# <a name="p0-不上消息队列"></a>84. P0 不上消息队列
采用：

DB Task Table
\+
Worker

例如：

async\_task

字段：

task\_id
task\_type
payload
status
retry\_count
next\_retry\_at

-----
# <a name="应用事件"></a>85. 应用事件
模块之间使用：

Domain / Application Event

例如：

RecommendationCompleted
PaymentSucceeded
MembershipGranted
DataVersionPublished

Spring Modulith 官方推荐应用模块通过事件发布和消费降低直接耦合，并提供事件发布生命周期能力，因此适合本项目在不引入 Kafka 的情况下实现模块解耦。

-----
# <a name="api-设计"></a>86. API 设计
统一：

/api/v1

-----
# <a name="api-contract-first"></a>87. API Contract First
正式开发前：

OpenAPI Contract

确定：

- Request
- Response
- Error Code

前端和后端都依据契约开发。

-----
# <a name="response"></a>88. Response
建议：

{
`  `"code": "OK",
`  `"message": "success",
`  `"data": {},
`  `"traceId": "..."
}

-----
# <a name="error-code"></a>89. Error Code
例如：

AUTH\_001
CANDIDATE\_001
XJ\_RULE\_001
RECOMMEND\_001
PAYMENT\_001
AI\_001

-----
# <a name="数据库架构"></a>90. 数据库架构
第一阶段：

One MySQL Instance
One Logical Database

-----
# <a name="不做-database-per-module"></a>91. 不做 Database Per Module
禁止第一版：

user\_db
candidate\_db
recommendation\_db
payment\_db

-----
# <a name="模块表所有权"></a>92. 模块表所有权
虽然同库：

identity

只负责身份相关表。

recommendation

不得直接写 membership 表。

-----
# <a name="id"></a>93. ID
建议：

BIGINT

内部主键。

对外：

Public ID

可采用：

UUID / ULID

具体在数据库设计阶段最终确定。

-----
# <a name="flyway"></a>94. Flyway
目录：

backend/src/main/resources/db/migration/

例如：

V001\_\_init\_identity.sql
V002\_\_init\_candidate.sql
V003\_\_init\_policy.sql

-----
# <a name="不允许-hibernate-自动建表"></a>95. 不允许 Hibernate 自动建表
禁止生产：

ddl-auto=update

-----
# <a name="object-storage"></a>96. Object Storage
用于：

- 原始政策 PDF
- Excel
- 数据快照
- AI 报告
- 用户上传材料
- 导出文件

通过：

ObjectStoragePort

抽象。

-----
# <a name="本地开发"></a>97. 本地开发
可：

Local File

或本地 S3-compatible 服务。

-----
# <a name="生产"></a>98. 生产
选择具体云对象存储。

业务代码不得绑定具体厂商 SDK。

-----
# <a name="可观测性"></a>99. 可观测性
P0：

Structured Log
\+
Spring Boot Actuator
\+
TraceId
\+
Metrics

Spring Boot 当前官方文档提供 Actuator、Metrics、Tracing、Observability 等生产特性，因此这里直接利用框架现有能力，不自建监控体系。

-----
# <a name="日志字段"></a>100. 日志字段
统一：

trace\_id
user\_id
recommendation\_run\_id
request\_hash
rule\_version
data\_version

-----
# <a name="不记录"></a>101. 不记录
禁止日志：

完整手机号
AppSecret
AccessToken
RefreshToken
AI API Key
支付私钥

-----
# <a name="ai-log"></a>102. AI Log
记录：

use\_case
provider
model
prompt\_version
input\_tokens
output\_tokens
latency
cost\_estimate
status

-----
# <a name="recommendation-audit"></a>103. Recommendation Audit
记录：

candidate\_profile\_version

eligibility\_profile\_version

rule\_set\_version

admission\_data\_version

algorithm\_version

result

-----
# <a name="test-strategy"></a>104. Test Strategy
-----
## <a name="layer-1rule-unit-test"></a>Layer 1：Rule Unit Test
最重要。

例如：

SingleColumnCompatibilityRuleTest

-----
## <a name="layer-2module-test"></a>Layer 2：Module Test
测试：

Recommendation Module

不能非法依赖其他内部模块。

-----
## <a name="layer-3integration-test"></a>Layer 3：Integration Test
真实：

MySQL
Redis-compatible cache

-----
## <a name="layer-4api-contract-test"></a>Layer 4：API Contract Test
检查：

OpenAPI

与实现一致。

-----
## <a name="layer-5frontend-component-test"></a>Layer 5：Frontend Component Test
重点：

- 表单
- RTL
- 冲稳保卡片
-----
## <a name="layer-6end-to-end"></a>Layer 6：End-to-End
核心流程：

登录
↓
填资料
↓
推荐
↓
免费次数
↓
支付
↓
解锁

-----
# <a name="数据测试"></a>105. 数据测试
必须独立存在：

Data Quality Tests

例如：

最低位次不能负数

招生人数不能负数

年份必须一致

同一计划项不能重复

院校代码必须存在

-----
# <a name="开发环境"></a>106. 开发环境
本地：

Mac
↓
Docker Compose

运行：

MySQL
Redis-compatible cache
Backend

前端：

微信开发者工具

后台：

Vite Dev Server

-----
# <a name="环境"></a>107. 环境
定义：

local
test
staging
prod

-----
# <a name="配置"></a>108. 配置
禁止：

application.yml

写生产 Secret。

生产通过：

Environment Variable
Secret File

-----
# <a name="生产部署-v1"></a>109. 生产部署 V1
Internet
↓
HTTPS
↓
Nginx
↓
Spring Boot Container
↓
MySQL
↓
Redis-compatible Cache

-----
# <a name="推荐部署起点"></a>110. 推荐部署起点
个人开发阶段：

单应用服务器
\+
可靠 MySQL
\+
定期备份

不建设：

Cluster

-----
# <a name="docker"></a>111. Docker
应用：

Docker Image

部署。

-----
# <a name="kubernetes"></a>112. Kubernetes
明确：

NOT IN MVP

-----
# <a name="ci-pipeline"></a>113. CI Pipeline
Git Push：

Compile
↓
Unit Test
↓
Module Test
↓
Integration Test
↓
Frontend Type Check
↓
Admin Build
↓
Backend Build

-----
# <a name="git-branch-strategy"></a>114. Git Branch Strategy
结合当前已有：

main
dev

正式定义：

main
\=
生产稳定分支

dev
\=
集成分支

feature/TASK-ID-description
\=
功能分支

-----
# <a name="codex-禁止直接长期操作-main"></a>115. Codex 禁止直接长期操作 main
Codex 任务：

feature/BE-001-wechat-login

完成：

PR
↓
dev

稳定：

dev
↓
main

-----
# <a name="多-codex-会话的-git-原则"></a>116. 多 Codex 会话的 Git 原则
禁止：

Backend Codex
Frontend Codex
AI Codex

同时修改同一个工作目录。

建议未来采用：

不同 Branch
\+
不同 Worktree

例如：

worktrees/
├── backend-be001/
├── frontend-fe001/
└── ai-ai001/

-----
# <a name="为什么-worktree-很重要"></a>117. 为什么 Worktree 很重要
否则：

会话 A 改文件
↓
会话 B 看见未提交修改
↓
误改
↓
冲突

-----
# <a name="codex-单一事实来源"></a>118. Codex 单一事实来源
每个会话必须读取：

docs/

尤其：

01-prd.md
02-xinjiang-business-rules.md
03-system-architecture.md
04-database-design.md
05-api-contract.md

-----
# <a name="codex-无权修改架构基线"></a>119. Codex 无权修改架构基线
发现问题：

Architecture Conflict Report

而不是擅自：

改技术栈
改表
改 API
改规则

-----
# <a name="性能扩展路径"></a>120. 性能扩展路径
-----
## <a name="stage-0"></a>Stage 0
开发：

单实例

-----
## <a name="stage-1"></a>Stage 1
初期上线：

Nginx
1 Backend
MySQL
Redis

-----
## <a name="stage-2"></a>Stage 2
流量增长：

Nginx
2+ Backend Instances
Managed MySQL
Redis

由于后端设计无状态，可横向扩容。

-----
## <a name="stage-3"></a>Stage 3
AI 报告增长：

拆：

AI Worker

-----
## <a name="stage-4"></a>Stage 4
数据导入压力增长：

拆：

Data Processing Worker

-----
## <a name="stage-5"></a>Stage 5
真正高流量后：

再考虑：

Recommendation Service
Payment Service

独立化。

-----
# <a name="微服务拆分触发条件"></a>121. 微服务拆分触发条件
只有出现真实证据才拆。

例如：

模块需要独立扩容

模块发布频率明显不同

模块严重影响主应用稳定性

团队规模增长

数据库负载明显隔离需求

-----
# <a name="不因为高级拆微服务"></a>122. 不因为“高级”拆微服务
禁止：

为了简历

拆微服务。

-----
# <a name="当前技术基线"></a>123. 当前技术基线
建议锁定：

Java
21

Spring Boot
4\.1.x

Spring Modulith
2\.1.x

Spring AI
2\.0.x

MyBatis-Plus
3\.5.x

MySQL
8\.4 LTS

Maven

Vue
3\.x

TypeScript

Vite

Element Plus

Python
3\.12+

Python 精确小版本在 data-pipeline 初始化时锁定。

-----
# <a name="为什么选择-boot-4-而不是-boot-3"></a>124. 为什么选择 Boot 4 而不是 Boot 3
本项目属于：

2026 新建绿地项目

当前相关生态已经具备：

Spring Boot 4
Spring Modulith 2
Spring AI 2
MyBatis-Plus Boot4 Starter

因此选择同代技术基线。

-----
# <a name="为什么不用-mysql-5.7"></a>125. 为什么不用 MySQL 5.7
即使开发者工作环境熟悉 MySQL 5.7：

本项目不继承旧生产环境限制

新项目采用：

MySQL 8.4 LTS

-----
# <a name="为什么-ai-不单独微服务"></a>126. 为什么 AI 不单独微服务
第一版：

AI Module

已经可以：

- Provider 抽象
- 独立接口
- 独立成本统计
- 独立任务队列

未来如果需要：

Extract AI Module

即可。

现在拆网络服务只增加复杂度。

-----
# <a name="为什么-python-不负责在线推荐"></a>127. 为什么 Python 不负责在线推荐
推荐核心包含：

- 新疆规则
- Java 业务对象
- 事务
- 用户权益
- 审计

如果在线推荐再调用：

Spring Boot
↓
Python API

会增加：

- 网络故障点
- 两套部署
- 两套日志
- 两套模型
- 数据同步

MVP 没有必要。

-----
# <a name="为什么保留-python"></a>128. 为什么保留 Python
数据处理场景：

Excel
PDF
CSV
统计
批量清洗

Python 更适合作为离线工具。

因此：

Java
\=
在线业务系统

Python
\=
离线数据工程

-----
# <a name="新疆年度变化如何进入架构"></a>129. 新疆年度变化如何进入架构
2026 年新疆招生工作规定包含多种录取批次和不同志愿结构；与此同时，新疆高考改革将在后续年度改变考试画像模型。因此架构把：

ExamRegime
RuleSet
AdmissionDataVersion

作为一级概念，而不是固定字段。新疆教育考试院 2026 年招生规定和改革政策解读分别构成这一设计的现实依据。

-----
# <a name="p0-架构范围"></a>130. P0 架构范围
必须实现：

Monorepo

Spring Boot Modular Monolith

MySQL

微信登录

Candidate Profile

Policy Rule Set

Admission Data

Recommendation Engine

Free Quota

Membership

Payment Abstraction

AI Gateway

中文/维语框架

Admin Web

Audit

-----
# <a name="p0-不实现"></a>131. P0 不实现
Microservices
Kubernetes
Kafka
RabbitMQ
Elasticsearch
Full RAG
Vector DB
Multi-Agent
Real-time Web Search Recommendation
Machine Learning Probability Model

-----
# <a name="p1-架构范围"></a>132. P1 架构范围
增加：

RAG

Policy QA

PDF Report

AI Async Worker

Advanced Data Pipeline

Human Service Workflow

-----
# <a name="p2-架构范围"></a>133. P2 架构范围
增加：

2027 3+1+2 Full Recommendation

Cross-Regime Calibration

Historical Backtesting

Probability Calibration

Advanced Agent Workflow

-----
# <a name="架构风险"></a>134. 架构风险
-----
## <a name="risk-1"></a>Risk 1
数据质量不足。

应对：

Data Version
Data Quality
Review
Publish
Rollback

-----
## <a name="risk-2"></a>Risk 2
规则变化。

应对：

Annual Rule Set

-----
## <a name="risk-3"></a>Risk 3
Codex 多会话冲突。

应对：

Docs
API Contract
Branch
Worktree
Task ID

-----
## <a name="risk-4"></a>Risk 4
AI 成本。

应对：

AI Use Case Routing
Quota
Cache
Cost Log

-----
## <a name="risk-5"></a>Risk 5
永久会员持续成本。

应对：

Membership Entitlement
≠
Unlimited AI

-----
## <a name="risk-6"></a>Risk 6
支付资格。

应对：

Gate-0

-----
## <a name="risk-7"></a>Risk 7
维语翻译质量。

应对：

Translation Status
Review Workflow
RTL Test

-----
# <a name="architecture-decision-summary"></a>135. Architecture Decision Summary
最终决策：

|决策|结果|
| :- | :- |
|Repository|Monorepo|
|Backend|Modular Monolith|
|Language|Java 21|
|Framework|Spring Boot 4.1.x|
|Modularity|Spring Modulith 2.1.x|
|Persistence|MyBatis-Plus|
|Database|MySQL 8.4 LTS|
|Migration|Flyway|
|Cache|Redis-compatible|
|Mini Program|Native + TypeScript|
|Admin|Vue 3 + TypeScript|
|AI|Spring AI + Internal Gateway|
|Python|Offline Data Pipeline Only|
|RAG|P1|
|Vector DB|P1 Evaluation|
|MQ|None in P0|
|Search Engine|None in P0|
|Kubernetes|None in P0|
|API Gateway|None in P0|
|Deployment|Docker-based Simple Deployment|
|Rules|Typed Java Rules + Versioned Metadata|
|Recommendation|Deterministic Java Engine|
|AI Role|Explanation, not hard decision|
|i18n|zh-CN + ug-CN + RTL|
|Git|main/dev/feature|
|Codex|Branch + Worktree + SSOT Docs|

-----
# <a name="architecture-freeze"></a>136. Architecture Freeze
从 V1.0 起，以下进入架构基线：

1. 项目采用 Monorepo。
1. 后端采用模块化单体。
1. MVP 不拆微服务。
1. 后端使用 Java。
1. 核心推荐引擎使用 Java。
1. Python 只承担离线数据处理。
1. MySQL 是业务事实来源。
1. Redis 不承担核心正确性。
1. AI 不执行硬规则判断。
1. AI 不直接生成候选院校池。
1. 推荐规则年度版本化。
1. 数据独立版本化。
1. 规则使用 Typed Java Rule。
1. 禁止数据库任意脚本在线执行。
1. P0 不建设完整 RAG。
1. P0 不建设向量数据库。
1. P0 不引入 Kafka。
1. P0 不引入 Kubernetes。
1. 用户端与后台端认证隔离。
1. 支付成功必须服务端确认。
1. 会员权益模型与 AI 消耗模型分离。
1. 中文与维吾尔语从第一版进入架构。
1. 维吾尔语支持 RTL。
1. Codex 多会话必须遵循 Git 隔离。
1. 所有模块共享 Single Source of Truth 文档。
