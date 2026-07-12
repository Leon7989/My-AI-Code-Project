# 新疆高考 AI 志愿助手
# Project Master Context
# Checkpoint A

- **建议文件名：** `00-project-master-context.md`
- **版本：** Checkpoint-A-V1
- **生成节点：** Step 4 完成后
- **用途：** ChatGPT / Codex / 后续 AI 会话快速恢复项目上下文

## 1. 当前会话命名

第一阶段：

> 新疆高考AI志愿助手-第一阶段-产品规则架构与数据库

第二阶段：

> 新疆高考AI志愿助手-第二阶段-API与UI

## 2. 项目定位

不是“AI 根据分数猜学校”。

正式定位：

> 面向新疆高考考生与家长，以年度招生规则、可信招生数据、推荐算法为核心，以 AI 负责解释和个性化分析的本地化志愿决策辅助系统。

核心公式：

```text
新疆年度规则
+
可信招生数据
+
推荐算法
+
用户偏好
+
AI解释
+
人工服务扩展
```

## 3. 产品形态

```text
微信原生小程序
+
Spring Boot 后端
+
Vue 管理后台
+
Python 离线数据流水线
```

## 4. 商业模型

免费用户初始 3 次正式志愿评估。

免费展示：

```text
冲 1 所
稳 1 所
保 1 所
```

永久基础会员与 AI 无限调用分离。

人工服务独立收费。

## 5. 产品语言

```text
zh-CN
ug-CN
```

中文 LTR，维吾尔语 RTL。

## 6. 已确认新疆业务模型

### 2026

```text
TRADITIONAL_WENLI
```

计划类型：

```text
NORMAL
SINGLE_COLUMN
```

科类：

```text
LITERATURE_HISTORY
SCIENCE_ENGINEERING
```

单列类路径：

```text
FOREIGN_LANGUAGE
ETHNIC_LANGUAGE
UNKNOWN
```

### 2027

```text
XJ_3_1_2
```

首选：

```text
PHYSICS
HISTORY
```

再选：

```text
CHEMISTRY
BIOLOGY
POLITICS
GEOGRAPHY
```

志愿模式预留：

```text
院校 + 专业组
```

## 7. 核心业务原则

- 年度规则版本化；
- 数据版本化；
- AI 不是数据源；
- Hard Rule 优先；
- AI 无权突破 Hard Rule；
- MVP 不输出伪精确录取概率；
- 冲稳保采用 REACH / MATCH / SAFE / WATCH；
- 推荐结果必须可审计。

## 8. 已知政策冲突

主题：

```text
2026 单列类兼报普通类
```

状态：

```text
REQUIRES_POLICY_RECONCILIATION
```

工程处理：

1. 保存全部官方来源；
2. 不由 AI 决定；
3. 上线前再次核验；
4. 后台维护 PolicyConflict；
5. 规则产生新版本。

## 9. 技术架构冻结

Repository：

```text
Monorepo
```

Backend：

```text
Java 21
Spring Boot 4.1.x
Spring Modulith 2.1.x
MyBatis-Plus 3.5.x
Flyway
```

Database：

```text
MySQL 8.4 LTS
```

Cache：

```text
Redis-compatible
```

Mini Program：

```text
原生微信小程序 + TypeScript
```

Admin：

```text
Vue 3
TypeScript
Vite
Element Plus
```

AI：

```text
Spring AI
+
Internal AI Gateway
```

Python：

```text
Offline Data Pipeline Only
```

## 10. 明确不采用

P0 禁止：

```text
Microservices
Kubernetes
Kafka
RabbitMQ
Elasticsearch
OpenSearch
Full RAG
Vector DB
Multi-Agent Runtime
Real-time Web Search Recommendation
```

## 11. Backend 模块

```text
identity
candidate
policy
admission
recommendation
membership
payment
ai
content
report
feedback
audit
admin
shared
```

## 12. Git 结构

当前：

```text
My-AI-Code-Project/
└── xinjiang-gaokao-volunteer/
```

分支：

```text
main
dev
feature/*
```

未来 Codex 并行：

```text
Branch
+
Git Worktree
```

## 13. Monorepo 结构

```text
xinjiang-gaokao-volunteer/
│
├── README.md
├── AGENTS.md
├── docs/
├── backend/
├── miniprogram/
├── admin-web/
├── data-pipeline/
├── infrastructure/
├── contracts/
├── data/
└── .codex/
    └── skills/
```

## 14. 数据库核心决策

- User 与 Candidate 分离；
- Candidate Profile 版本化；
- 2026 与 2027 通过 ExamRegime 共存；
- 2027 预留 AdmissionPlanGroup；
- 推荐最小单位为 AdmissionPlanItem；
- 招生事实绑定 DataVersion；
- RuleSet 独立版本化；
- RecommendationRun 固定规则和数据版本；
- 免费次数采用 QuotaAccount + QuotaLedger；
- Membership 与 AI Quota 分离；
- 支付服务端确认；
- Prompt 版本化；
- 中维双语内容独立翻译表。

## 15. 当前逻辑数据库规模

V1.0：

```text
64 张逻辑表
```

分阶段实施，不一次性创建全部空表。

## 16. 当前推荐 Pipeline

```text
Profile Validation
↓
Rule Set Resolution
↓
Application Scope Filter
↓
Plan Compatibility Filter
↓
Batch Filter
↓
Special Qualification Filter
↓
Program Hard Constraint Filter
↓
Historical Comparability
↓
Risk Scoring
↓
Preference Ranking
↓
Tier Assignment
↓
AI Explanation
```

## 17. P0 支持范围

优先：

```text
2026 新疆普通高考
普通类
单列类
文史类
理工类
本科一批
本科二批
高职普通批
基础专项资格模型
冲稳保推荐
```

## 18. 当前已完成文档

```text
01-prd.md
✅ V0.1

02-xinjiang-business-rules.md
✅ V1.0

03-system-architecture.md
✅ V1.0

04-database-design.md
✅ V1.0
```

## 19. 下一阶段

```text
Step 5 API Contract
Step 6 Information Architecture
Step 7 UI Specification / High Fidelity
Checkpoint B
Step 8 Codex Skills
Step 9 Codex Sessions
Step 10 Coding
```

## 20. 新会话恢复指令

```text
继续“新疆高考 AI 志愿助手”项目。

当前项目已完成：
Step 1 PRD
Step 2 新疆高考业务规则模型
Step 3 系统架构设计
Step 4 数据库 ER 设计
Checkpoint A

请以项目内历史会话和以下 SSOT 文档为准：

00-project-master-context.md
00-decision-register.md
00-progress-tracker.md
01-prd.md
02-xinjiang-business-rules.md
03-system-architecture.md
04-database-design.md

现在进入 Step 5 API 契约设计。

不得擅自修改已冻结的业务规则、架构基线和数据库领域边界。
发现冲突时先输出 Conflict Report。
```

## 21. Master Principle

> ChatGPT 负责思考。  
> 文档负责记忆。  
> Git 负责历史。  
> Codex 负责执行。  
> 人负责最终决策。
