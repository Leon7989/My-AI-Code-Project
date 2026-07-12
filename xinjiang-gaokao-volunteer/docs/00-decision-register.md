# 新疆高考 AI 志愿助手
# Architecture & Product Decision Register

- **建议文件名：** `00-decision-register.md`
- **版本：** Checkpoint-A-V1
- **状态：** Active

## Frozen / Baseline Decisions

| ID | 决策 | 状态 |
|---|---|---|
| DR-001 | 产品只聚焦新疆 | FROZEN |
| DR-002 | 核心为“规则 + 数据 + 算法 + AI解释” | FROZEN |
| DR-003 | 新用户 3 次正式评估，免费展示冲/稳/保各 1 所 | BASELINE |
| DR-004 | 永久会员与 AI 无限调用分离 | FROZEN |
| DR-005 | 人工服务独立商品 | BASELINE |
| DR-006 | 支持 zh-CN / ug-CN | FROZEN |
| DR-007 | 维吾尔语支持 RTL | FROZEN |
| DR-008 | 2026 使用 TRADITIONAL_WENLI | FROZEN |
| DR-009 | 单列类语言路径独立建模 | FROZEN |
| DR-010 | 2027 使用 XJ_3_1_2 | FROZEN |
| DR-011 | 年度 RuleSet Versioning | FROZEN |
| DR-012 | PolicyConflict 为一级实体 | FROZEN |
| DR-013 | Monorepo | FROZEN |
| DR-014 | Modular Monolith | FROZEN |
| DR-015 | P0 不采用微服务 | FROZEN |
| DR-016 | Java 21 | FROZEN |
| DR-017 | Spring Boot 4.1.x + Spring Modulith 2.1.x | BASELINE |
| DR-018 | MyBatis-Plus + 复杂 SQL 手写/XML | FROZEN |
| DR-019 | MySQL 8.4 LTS | FROZEN |
| DR-020 | Flyway | FROZEN |
| DR-021 | Redis-compatible，只作缓存与临时能力 | FROZEN |
| DR-022 | 原生微信小程序 + TypeScript | FROZEN |
| DR-023 | Vue 3 + TypeScript + Vite + Element Plus | BASELINE |
| DR-024 | Python 仅离线数据流水线 | FROZEN |
| DR-025 | 在线推荐核心使用 Java | FROZEN |
| DR-026 | P0 不做 Full RAG | FROZEN FOR P0 |
| DR-027 | P0 不引入 Vector DB | FROZEN FOR P0 |
| DR-028 | P0 不引入 Kafka / RabbitMQ | FROZEN FOR P0 |
| DR-029 | P0 不引入 Kubernetes | FROZEN FOR P0 |
| DR-030 | Typed Java Rule + Versioned Metadata | FROZEN |
| DR-031 | 禁止数据库执行任意 SpEL/Groovy/JavaScript | FROZEN |
| DR-032 | User 与 Candidate 分离 | FROZEN |
| DR-033 | Exam / Eligibility / Preference Profile 版本化 | FROZEN |
| DR-034 | 资格状态禁止 Boolean | FROZEN |
| DR-035 | AdmissionBatch 年度数据库实体 | FROZEN |
| DR-036 | AdmissionPlanGroup 进入 V1.0 | FROZEN |
| DR-037 | 推荐最小单位为 AdmissionPlanItem | FROZEN |
| DR-038 | 历史数据显式保存 Grain | FROZEN |
| DR-039 | 招生计划/历史/控制线/选科要求独立版本 | FROZEN |
| DR-040 | RecommendationRun 成功后关键版本关联不可变 | FROZEN |
| DR-041 | REACH / MATCH / SAFE / WATCH | FROZEN |
| DR-042 | MVP 不输出未经校准精确概率 | FROZEN |
| DR-043 | QuotaAccount + QuotaLedger | FROZEN |
| DR-044 | request_hash + idempotency_key | FROZEN |
| DR-045 | Membership + Entitlement，禁止 user.vip | FROZEN |
| DR-046 | Internal AI Gateway | FROZEN |
| DR-047 | Prompt 版本化 | FROZEN |
| DR-048 | AI 只解释，不突破 Hard Rule | FROZEN |
| DR-049 | 支付成功必须服务端确认 | FROZEN |
| DR-050 | 真实支付前执行 Gate-0 | OPEN GATE |
| DR-051 | main / dev / feature/* | FROZEN |
| DR-052 | Codex 并行采用 Branch + Git Worktree | FROZEN FOR STEP 9 |
| DR-053 | docs/ 为 SSOT | FROZEN |
| DR-054 | 第一会话完成 Step 1～4 + Checkpoint A | COMPLETED |

## Open Decisions

| ID | 事项 | 状态 |
|---|---|---|
| OD-001 | 产品正式名称 | OPEN |
| OD-002 | 永久会员价格 | OPEN |
| OD-003 | AI Provider | OPEN |
| OD-004 | 云服务商 | OPEN |
| OD-005 | 对象存储厂商 | OPEN |
| OD-006 | Redis 实际实现 | OPEN |
| OD-007 | 支付能力 | GATE-0 OPEN |
| OD-008 | 维吾尔语人工审校资源 | OPEN |
| OD-009 | 招生数据来源与授权路径 | CRITICAL OPEN |
| OD-010 | 2026 单列类政策冲突最终解释 | REQUIRES_POLICY_RECONCILIATION |
