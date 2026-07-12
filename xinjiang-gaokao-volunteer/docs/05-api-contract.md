# 新疆高考 AI 志愿助手
# API Contract V1.0

## 0. 文档信息

- **建议文件名：** `05-api-contract.md`
- **版本：** V1.0
- **状态：** Contract Baseline
- **阶段：** Step 5
- **Checkpoint A：** PASSED
- **适用客户端：** 微信原生小程序、Vue 3 Admin Web
- **后端基线：** Java 21 + Spring Boot 4.1.x + Spring Modulith 2.1.x
- **契约方法：** Contract First
- **机器可读契约：** OpenAPI 3.1.x（实施时以 `openapi.yaml` 为接口 SSOT）
- **上游文档：**
  - `00-project-master-context.md`
  - `00-decision-register.md`
  - `00-progress-tracker.md`
  - `01-prd.md`
  - `02-xinjiang-business-rules.md`
  - `03-system-architecture.md`
  - `04-database-design.md`
- **下游文档/实现：**
  - `openapi.yaml`
  - `06-information-architecture.md`
  - `07-ui-specification.md`
  - Mini Program API Client
  - Admin Web API Client
  - Backend Controller / Contract Test
  - Codex Skills

---

# 1. Conflict Report

## 1.1 检查结论

```text
CONFLICT_REPORT_STATUS = NO_BLOCKING_CONFLICT
```

本 Step 未发现需要阻断 API Contract V1.0 的冻结决策冲突。

## 1.2 已识别但不属于本 Step 擅自解决的开放事项

| ID | 事项 | 当前状态 | API Contract 处理 |
|---|---|---|---|
| OD-007 | 支付能力 | GATE-0 OPEN | 保留 Payment Provider Adapter 契约；真实支付前必须通过 Gate-0 |
| OD-009 | 招生数据来源与授权 | CRITICAL OPEN | API 暴露数据版本、质量与来源状态，不假定来源已解决 |
| OD-010 | 2026 单列类政策冲突 | REQUIRES_POLICY_RECONCILIATION | 返回明确 warning / error，不由 AI 或前端自行裁决 |
| OD-003 | AI Provider | OPEN | 外部 API 不暴露具体 Provider，统一通过 Internal AI Gateway |
| OD-006 | Redis 实现 | OPEN | API 正确性不得依赖 Redis |

## 1.3 Contract 中必须保持的冻结决策

- `DR-032`：User 与 Candidate 分离；
- `DR-033`：Exam / Eligibility / Preference Profile 版本化；
- `DR-034`：资格状态禁止 Boolean；
- `DR-037`：推荐最小单位为 AdmissionPlanItem；
- `DR-040`：RecommendationRun 成功后关键版本关联不可变；
- `DR-041`：REACH / MATCH / SAFE / WATCH；
- `DR-042`：MVP 不输出未经校准精确录取概率；
- `DR-043`：QuotaAccount + QuotaLedger；
- `DR-044`：request_hash + idempotency_key；
- `DR-045`：Membership + Entitlement，禁止 `user.vip`；
- `DR-046`：Internal AI Gateway；
- `DR-047`：Prompt 版本化；
- `DR-048`：AI 只解释，不突破 Hard Rule；
- `DR-049`：支付成功必须服务端确认；
- `DR-050`：真实支付前执行 Gate-0；
- `DR-053`：`docs/` 为 SSOT。

---

# 2. API Contract First 原则

## 2.1 SSOT

正式编码前先维护：

```text
docs/05-api-contract.md
        ↓
openapi/openapi.yaml
        ↓
Contract Lint / Contract Test
        ↓
Backend Implementation
Mini Program Client
Admin Web Client
```

禁止：

```text
先写 Controller
↓
再反向生成“看起来像契约”的文档
```

## 2.2 契约变更规则

任何 Breaking Change 必须：

1. 修改本文件；
2. 修改 `openapi.yaml`；
3. 通过 Contract Review；
4. 必要时升级 API Major Version；
5. 前后端不得私自扩展同名字段不同语义。

Breaking Change 包括：

- 删除字段；
- 字段改名；
- 类型改变；
- optional → required；
- enum 删除值；
- 状态码语义改变；
- 同一路径改变资源语义。

非 Breaking Change 通常包括：

- 新增 optional 字段；
- 新增 endpoint；
- 新增可忽略 warning；
- enum 新增值仅在客户端具备 unknown fallback 时允许。

---

# 3. API Namespace 与版本

## 3.1 用户 API

```text
/api/v1/**
```

服务对象：

- 微信小程序；
- 未来受控用户端客户端。

## 3.2 后台 API

```text
/admin-api/v1/**
```

服务对象：

- Vue 3 Admin Web。

## 3.3 支付 Provider Callback

```text
/payment-callback/v1/**
```

说明：

- 不属于用户 API；
- 不属于 Admin API；
- 使用 Provider 验签/验密文机制；
- 不接受 User Access Token 作为可信支付证明。

## 3.4 版本原则

```text
URL Major Version = v1
```

Patch / backward-compatible change 不修改 URL。

---

# 4. Protocol 与通用 Header

## 4.1 传输

```text
HTTPS Only
Content-Type: application/json
Accept: application/json
UTF-8
```

文件上传使用：

```text
multipart/form-data
```

## 4.2 通用请求 Header

| Header | 必填 | 适用 | 说明 |
|---|---:|---|---|
| `Authorization` | 条件 | User/Admin | `Bearer <access_token>` |
| `Accept-Language` | 否 | All | `zh-CN` / `ug-CN` |
| `X-Request-Id` | 否 | All | 客户端请求追踪 ID；服务端仍生成 traceId |
| `Idempotency-Key` | 条件 | Mutation | 推荐、订单创建、支付发起等关键操作必填 |
| `If-Match` | 条件 | Admin | 高风险并发修改可使用版本/Etag |

## 4.3 Locale

支持：

```text
zh-CN
ug-CN
```

默认：

```text
zh-CN
```

客户端必须允许未知 locale fallback；维吾尔语 RTL 属于 UI 层职责，但 API 文本资源必须携带 locale 语义。

---

# 5. Authentication Contract

## 5.1 User Principal

User Access Token 仅用于：

```text
/api/v1/**
```

禁止用于：

```text
/admin-api/v1/**
```

## 5.2 Admin Principal

Admin Access Token 仅用于：

```text
/admin-api/v1/**
```

禁止简单采用：

```text
same_token + role=ADMIN
```

## 5.3 Token 结构原则

建议：

```text
Short-lived Access Token
+
Refresh Mechanism
```

本 Contract 不冻结 JWT / opaque token 具体实现；不得因此改变 User/Admin Principal 隔离。

## 5.4 Object Ownership

所有 `/api/v1/candidates/{candidateId}` 资源必须执行：

```text
candidate.owner_user_id == currentUser.id
```

不得仅因用户知道 `candidateId` 即允许访问。

---

# 6. Standard Response Envelope

## 6.1 成功响应

```json
{
  "code": "OK",
  "message": "success",
  "data": {},
  "traceId": "01J..."
}
```

## 6.2 带警告成功响应

```json
{
  "code": "OK",
  "message": "success",
  "data": {},
  "warnings": [
    {
      "code": "XJ_WARN_001",
      "message": "部分专项资格待确认",
      "field": "eligibilities.NATIONAL_SPECIAL",
      "severity": "WARNING"
    }
  ],
  "traceId": "01J..."
}
```

## 6.3 错误响应

```json
{
  "code": "XJ_RULE_004",
  "message": "单列类考生必须提供考试语言路径",
  "details": [
    {
      "field": "examLanguagePath",
      "reason": "REQUIRED"
    }
  ],
  "traceId": "01J..."
}
```

## 6.4 原则

- `code` 是稳定机器码；
- `message` 是面向当前 locale 的可读文本；
- 客户端不得根据 `message` 做业务判断；
- `traceId` 必须可用于日志追踪；
- 不返回 Java exception class、SQL、stack trace。

---

# 7. HTTP Status Contract

| HTTP | 语义 |
|---:|---|
| 200 | 查询成功、幂等重放返回既有结果 |
| 201 | 资源创建成功 |
| 202 | 异步任务已接受 |
| 204 | 删除/撤销成功且无 body |
| 400 | 请求格式/参数错误 |
| 401 | 未认证或 Token 无效 |
| 403 | 已认证但无权限/无权益 |
| 404 | 资源不存在或对当前主体不可见 |
| 409 | 并发冲突、状态冲突、Idempotency Key 冲突 |
| 412 | 条件请求失败 |
| 422 | 结构合法但违反业务规则 |
| 429 | 限流 |
| 500 | 未分类服务端错误 |
| 502 | 外部 Provider 异常 |
| 503 | 服务暂不可用 |

---

# 8. Pagination / Sort / Filter

## 8.1 列表分页

默认 page-based：

```text
page = 1
pageSize = 20
```

限制：

```text
1 <= pageSize <= 100
```

响应：

```json
{
  "items": [],
  "page": 1,
  "pageSize": 20,
  "total": 238,
  "totalPages": 12
}
```

## 8.2 排序

示例：

```text
sort=publishedAt,desc
```

只允许 endpoint 白名单字段，禁止把任意字段名直接拼接 SQL。

## 8.3 时间

- API 时间：RFC 3339 / ISO 8601 带 offset；
- 示例：`2026-07-04T21:30:00+08:00`；
- 业务年度字段仍为整数 `examYear`。

---

# 9. ID Contract

外部核心资源使用：

```text
public_id
```

API 字段统一：

```text
id: string
```

建议值：ULID 26 字符。

禁止向外暴露数据库自增 `BIGINT id` 作为核心公共 ID。

---

# 10. Idempotency Contract

## 10.1 必须幂等的操作

至少：

- `POST /api/v1/recommendations`；
- `POST /api/v1/orders`；
- `POST /api/v1/orders/{orderId}/payment-attempts`；
- 支付 Provider callback；
- Admin 发布 DataVersion；
- Admin 发布 RuleSet；
- Admin 解决 PolicyConflict 的最终提交。

## 10.2 Idempotency-Key

格式：

```text
Idempotency-Key: <client-generated opaque key>
```

建议：UUID/ULID。

服务端作用域：

```text
principal + operation + idempotency_key
```

推荐数据库冻结约束：

```text
UNIQUE(user_id, idempotency_key)
```

## 10.3 Key 重放

相同 Key + 相同规范化请求：

```text
返回原业务结果
不重复执行
不重复扣次数
```

相同 Key + 不同规范化请求：

```text
HTTP 409
IDEMPOTENCY_002
IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_REQUEST
```

## 10.4 Recommendation 双层幂等

推荐必须同时使用：

```text
idempotency_key
+
request_hash
```

`request_hash` 至少覆盖：

- candidateId；
- examProfileId / version；
- eligibilityProfileId / version；
- preferenceProfileId / version；
- resolved RuleSet version；
- Admission Plan DataVersion；
- Admission History DataVersion；
- Control Line DataVersion；
- algorithmVersion；
- 影响正式推荐的请求参数。

## 10.5 Quota 防重复扣次

Quota Ledger 业务键建议：

```text
RECOMMENDATION:{requestHash}:{ruleVersion}:{dataVersionSet}
```

必须满足：

```text
同一正式推荐业务事实最多扣 1 次
```

---

# 11. Error Code Namespace

## 11.1 通用

```text
COMMON_001 INVALID_REQUEST
COMMON_002 VALIDATION_FAILED
COMMON_003 RESOURCE_NOT_FOUND
COMMON_004 STATE_CONFLICT
COMMON_005 RATE_LIMITED
COMMON_500 INTERNAL_ERROR
```

## 11.2 Auth

```text
AUTH_001 UNAUTHENTICATED
AUTH_002 ACCESS_TOKEN_EXPIRED
AUTH_003 REFRESH_TOKEN_INVALID
AUTH_004 FORBIDDEN
AUTH_005 PRINCIPAL_TYPE_MISMATCH
AUTH_006 WECHAT_CODE_INVALID
AUTH_007 SESSION_REVOKED
```

## 11.3 Candidate

```text
CANDIDATE_001 NOT_FOUND
CANDIDATE_002 NOT_OWNER
CANDIDATE_003 EXAM_PROFILE_REQUIRED
CANDIDATE_004 ELIGIBILITY_PROFILE_REQUIRED
CANDIDATE_005 PREFERENCE_PROFILE_REQUIRED
CANDIDATE_006 PROFILE_VERSION_CONFLICT
CANDIDATE_007 INVALID_PROFILE_STATUS
```

## 11.4 新疆规则

冻结业务错误：

```text
XJ_RULE_001 EXAM_YEAR_UNSUPPORTED
XJ_RULE_002 EXAM_REGIME_MISMATCH
XJ_RULE_003 PLAN_TYPE_UNKNOWN
XJ_RULE_004 SINGLE_COLUMN_PATH_REQUIRED
XJ_RULE_005 SPECIAL_ELIGIBILITY_UNKNOWN
XJ_RULE_006 APPLICATION_SCOPE_UNKNOWN
XJ_RULE_007 NO_ELIGIBLE_PLAN
XJ_RULE_008 POLICY_CONFLICT_REVIEW_REQUIRED
XJ_RULE_009 HISTORICAL_DATA_NOT_COMPARABLE
XJ_RULE_010 SUBJECT_REQUIREMENT_NOT_MET
```

## 11.5 Recommendation

```text
RECOMMEND_001 REQUEST_INVALID
RECOMMEND_002 RUN_NOT_FOUND
RECOMMEND_003 RUN_FAILED
RECOMMEND_004 NO_RESULT_SYSTEM_ERROR
RECOMMEND_005 ACTIVE_RULE_SET_NOT_FOUND
RECOMMEND_006 ACTIVE_DATA_VERSION_NOT_FOUND
RECOMMEND_007 RESULT_IMMUTABLE
RECOMMEND_008 ALGORITHM_VERSION_UNAVAILABLE
RECOMMEND_009 HARD_RULE_CONTEXT_INCOMPLETE
```

## 11.6 Idempotency

```text
IDEMPOTENCY_001 KEY_REQUIRED
IDEMPOTENCY_002 KEY_REUSED_WITH_DIFFERENT_REQUEST
IDEMPOTENCY_003 REQUEST_IN_PROGRESS
```

## 11.7 Quota / Membership

```text
QUOTA_001 INSUFFICIENT_QUOTA
QUOTA_002 ACCOUNT_NOT_FOUND
QUOTA_003 CONCURRENT_UPDATE_CONFLICT
MEMBERSHIP_001 ENTITLEMENT_REQUIRED
MEMBERSHIP_002 MEMBERSHIP_INACTIVE
```

## 11.8 Payment

```text
PAYMENT_001 GATE_0_NOT_PASSED
PAYMENT_002 ORDER_NOT_PAYABLE
PAYMENT_003 PROVIDER_UNAVAILABLE
PAYMENT_004 NOTIFICATION_SIGNATURE_INVALID
PAYMENT_005 AMOUNT_MISMATCH
PAYMENT_006 CURRENCY_MISMATCH
PAYMENT_007 PROVIDER_TRANSACTION_CONFLICT
PAYMENT_008 PAYMENT_NOT_SERVER_CONFIRMED
PAYMENT_009 ORDER_STATE_CONFLICT
```

## 11.9 AI

```text
AI_001 ENTITLEMENT_REQUIRED
AI_002 ANALYSIS_NOT_FOUND
AI_003 SOURCE_RECOMMENDATION_REQUIRED
AI_004 SOURCE_RECOMMENDATION_NOT_SUCCEEDED
AI_005 PROVIDER_UNAVAILABLE
AI_006 OUTPUT_SCHEMA_INVALID
AI_007 HARD_RULE_GUARD_REJECTED
AI_008 PROMPT_VERSION_UNAVAILABLE
AI_009 RATE_LIMITED
```

## 11.10 Admin

```text
ADMIN_001 UNAUTHENTICATED
ADMIN_002 FORBIDDEN
ADMIN_003 VERSION_PUBLISH_CONFLICT
ADMIN_004 RULE_SET_ACTIVATION_CONFLICT
ADMIN_005 POLICY_CONFLICT_UNRESOLVED
ADMIN_006 AUDIT_REASON_REQUIRED
```

---

# 12. User API Endpoint Catalog

## 12.1 Auth

| Method | Path | Auth | 说明 |
|---|---|---|---|
| POST | `/api/v1/auth/wechat/login` | No | 微信临时凭证换本系统登录态 |
| POST | `/api/v1/auth/refresh` | Refresh | 刷新 Access Token |
| POST | `/api/v1/auth/logout` | User | 撤销当前 Session |
| GET | `/api/v1/me` | User | 当前用户 |
| PATCH | `/api/v1/me/preferences` | User | locale 等用户偏好 |

## 12.2 Candidate

| Method | Path | Auth | 说明 |
|---|---|---|---|
| GET | `/api/v1/candidates` | User | 我的考生方案列表 |
| POST | `/api/v1/candidates` | User | 创建 Candidate |
| GET | `/api/v1/candidates/{candidateId}` | User | Candidate 聚合摘要 |
| PATCH | `/api/v1/candidates/{candidateId}` | User | 修改 displayName/status |
| DELETE | `/api/v1/candidates/{candidateId}` | User | 逻辑停用 |

## 12.3 Exam Profile

| Method | Path | Auth | 说明 |
|---|---|---|---|
| GET | `/api/v1/candidates/{candidateId}/exam-profiles` | User | 历史版本 |
| POST | `/api/v1/candidates/{candidateId}/exam-profiles` | User | 创建新版本 |
| GET | `/api/v1/candidates/{candidateId}/exam-profiles/{profileId}` | User | 读取版本 |
| POST | `/api/v1/candidates/{candidateId}/exam-profiles/{profileId}/activate` | User | 激活指定版本 |

## 12.4 Eligibility Profile

| Method | Path | Auth | 说明 |
|---|---|---|---|
| GET | `/api/v1/candidates/{candidateId}/eligibility-profiles` | User | 历史版本 |
| POST | `/api/v1/candidates/{candidateId}/eligibility-profiles` | User | 创建新版本 |
| GET | `/api/v1/candidates/{candidateId}/eligibility-profiles/{profileId}` | User | 读取版本 |
| POST | `/api/v1/candidates/{candidateId}/eligibility-profiles/{profileId}/activate` | User | 激活版本 |

## 12.5 Preference Profile

| Method | Path | Auth | 说明 |
|---|---|---|---|
| GET | `/api/v1/candidates/{candidateId}/preference-profiles` | User | 历史版本 |
| POST | `/api/v1/candidates/{candidateId}/preference-profiles` | User | 创建新版本 |
| GET | `/api/v1/candidates/{candidateId}/preference-profiles/{profileId}` | User | 读取版本 |
| POST | `/api/v1/candidates/{candidateId}/preference-profiles/{profileId}/activate` | User | 激活版本 |

## 12.6 Recommendation

| Method | Path | Auth | 幂等 | 说明 |
|---|---|---|---|---|
| POST | `/api/v1/recommendations` | User | **Required** | 创建正式推荐 |
| GET | `/api/v1/recommendations` | User | N/A | 推荐历史 |
| GET | `/api/v1/recommendations/{recommendationId}` | User | N/A | 推荐运行摘要 |
| GET | `/api/v1/recommendations/{recommendationId}/results` | User | N/A | 结果项 |
| GET | `/api/v1/recommendations/{recommendationId}/evidence` | User | N/A | 可见证据链 |

## 12.7 Admission Query

| Method | Path | Auth | 说明 |
|---|---|---|---|
| GET | `/api/v1/universities` | Optional | 院校搜索/筛选 |
| GET | `/api/v1/universities/{universityId}` | Optional | 院校详情 |
| GET | `/api/v1/universities/{universityId}/admission-plans` | Optional | 年度招生计划 |
| GET | `/api/v1/majors` | Optional | 专业搜索 |
| GET | `/api/v1/majors/{majorId}` | Optional | 专业详情 |
| GET | `/api/v1/admission-plan-items/{itemId}` | Optional | 招生计划项详情 |

## 12.8 Membership / Quota

| Method | Path | Auth | 说明 |
|---|---|---|---|
| GET | `/api/v1/memberships/me` | User | 会员状态 |
| GET | `/api/v1/entitlements/me` | User | 权益集合 |
| GET | `/api/v1/quotas/me` | User | 次数账户 |
| GET | `/api/v1/quotas/me/ledger` | User | 用户可见扣次记录 |
| GET | `/api/v1/products` | Optional | 可售 SKU |

## 12.9 Order / Payment

| Method | Path | Auth | 幂等 | 说明 |
|---|---|---|---|---|
| POST | `/api/v1/orders` | User | Required | 创建订单 |
| GET | `/api/v1/orders` | User | N/A | 我的订单 |
| GET | `/api/v1/orders/{orderId}` | User | N/A | 订单详情 |
| POST | `/api/v1/orders/{orderId}/payment-attempts` | User | Required | 发起支付 |
| GET | `/api/v1/orders/{orderId}/payment-status` | User | N/A | 查询服务端支付状态 |

## 12.10 AI Analysis

| Method | Path | Auth | 说明 |
|---|---|---|---|
| POST | `/api/v1/recommendations/{recommendationId}/ai-analyses` | User | 基于成功推荐创建 AI 分析 |
| GET | `/api/v1/ai-analyses/{analysisId}` | User | 查询状态/结果 |

## 12.11 Content / Feedback

| Method | Path | Auth | 说明 |
|---|---|---|---|
| GET | `/api/v1/content/articles` | Optional | 政策/指南/公告 |
| GET | `/api/v1/content/articles/{articleId}` | Optional | 文章详情 |
| POST | `/api/v1/feedback` | Optional/User | 提交反馈 |

---

# 13. Auth API Detailed Contract

## 13.1 微信登录

```http
POST /api/v1/auth/wechat/login
```

Request：

```json
{
  "code": "wx-temporary-login-code",
  "device": {
    "deviceId": "client-opaque-device-id",
    "platform": "WECHAT_MINI_PROGRAM"
  }
}
```

Response `200`：

```json
{
  "code": "OK",
  "message": "success",
  "data": {
    "accessToken": "...",
    "accessTokenExpiresAt": "2026-07-04T22:00:00+08:00",
    "refreshToken": "...",
    "refreshTokenExpiresAt": "2026-08-03T21:30:00+08:00",
    "user": {
      "id": "01J...",
      "preferredLocale": "zh-CN",
      "status": "ACTIVE"
    }
  },
  "traceId": "01J..."
}
```

安全规则：

- App Secret server-side only；
- 前端不得提交 `openid` 作为可信身份；
- 后端通过微信侧接口验证临时 code；
- `openid` 不返回给普通业务 UI。

---

# 14. Candidate Profile Contract

## 14.1 创建 Candidate

```http
POST /api/v1/candidates
```

Request：

```json
{
  "displayName": "我的 2026 方案"
}
```

Response `201`：

```json
{
  "code": "OK",
  "message": "success",
  "data": {
    "id": "01J...",
    "displayName": "我的 2026 方案",
    "status": "ACTIVE",
    "activeExamProfileId": null,
    "activeEligibilityProfileId": null,
    "activePreferenceProfileId": null
  },
  "traceId": "01J..."
}
```

## 14.2 创建 Exam Profile 新版本

```http
POST /api/v1/candidates/{candidateId}/exam-profiles
```

### 2026 Request

```json
{
  "examYear": 2026,
  "examRegime": "TRADITIONAL_WENLI",
  "rawScore": 586,
  "policyBonusScore": 0,
  "effectiveSubmissionScore": 586,
  "rankValue": 8120,
  "rankScopeCode": "XJ_REGION",
  "planType": "NORMAL",
  "subjectTrack": "SCIENCE_ENGINEERING",
  "examLanguagePath": null,
  "foreignLanguageType": "ENGLISH",
  "applicationScope": "NORMAL_ONLY",
  "sourceType": "USER_DECLARED",
  "activate": true
}
```

### 2026 Single Column Request

```json
{
  "examYear": 2026,
  "examRegime": "TRADITIONAL_WENLI",
  "rawScore": 520,
  "effectiveSubmissionScore": 520,
  "rankValue": 12000,
  "rankScopeCode": "XJ_REGION",
  "planType": "SINGLE_COLUMN",
  "subjectTrack": "SCIENCE_ENGINEERING",
  "examLanguagePath": "FOREIGN_LANGUAGE",
  "foreignLanguageType": "ENGLISH",
  "applicationScope": "UNKNOWN",
  "sourceType": "USER_DECLARED",
  "activate": true
}
```

规则：

- `SINGLE_COLUMN` 时不能省略 `examLanguagePath`；
- `applicationScope=UNKNOWN` 必须保留未知语义；
- 对 2026 单列类兼报普通类冲突不得由 API Controller 自行推断；
- 新提交创建新版本，不覆盖旧 Profile。

### 2027 Request

```json
{
  "examYear": 2027,
  "examRegime": "XJ_3_1_2",
  "rawScore": 610,
  "effectiveSubmissionScore": 610,
  "rankValue": 6500,
  "rankScopeCode": "XJ_REGION",
  "planType": "NORMAL",
  "firstChoiceSubject": "PHYSICS",
  "secondChoiceSubjects": ["CHEMISTRY", "BIOLOGY"],
  "applicationScope": "NORMAL_ONLY",
  "sourceType": "USER_DECLARED",
  "activate": true
}
```

禁止用 2026 `subjectTrack` 错误表达 2027 选科体系。

## 14.3 Eligibility Profile

```http
POST /api/v1/candidates/{candidateId}/eligibility-profiles
```

Request：

```json
{
  "examYear": 2026,
  "verificationLevel": "USER_DECLARED",
  "items": [
    {
      "eligibilityType": "NATIONAL_SPECIAL",
      "status": "UNKNOWN",
      "regionCode": null,
      "verificationSource": "USER_DECLARED",
      "notes": null
    },
    {
      "eligibilityType": "SOUTH_XINJIANG_SINGLE",
      "status": "VERIFIED_INELIGIBLE",
      "regionCode": null,
      "verificationSource": "USER_DECLARED",
      "notes": null
    }
  ],
  "activate": true
}
```

资格状态禁止 Boolean。最小允许状态集：

```text
UNKNOWN
SELF_DECLARED_ELIGIBLE
SELF_DECLARED_INELIGIBLE
VERIFIED_ELIGIBLE
VERIFIED_INELIGIBLE
PENDING_VERIFICATION
```

## 14.4 Preference Profile

```http
POST /api/v1/candidates/{candidateId}/preference-profiles
```

Request：

```json
{
  "adjustmentAcceptance": "ACCEPT",
  "maxTuition": 30000.00,
  "schoolPriorityWeight": 0.4,
  "majorPriorityWeight": 0.4,
  "cityPriorityWeight": 0.2,
  "futurePlan": "POSTGRADUATE",
  "items": [
    {
      "type": "MAJOR_CATEGORY",
      "targetCode": "COMPUTER_SCIENCE",
      "priority": 1,
      "mode": "PREFER"
    },
    {
      "type": "PROVINCE",
      "targetCode": "44",
      "priority": 2,
      "mode": "PREFER"
    }
  ],
  "activate": true
}
```

Soft Rule 仅影响排序，不得突破 Hard Rule。

---

# 15. Recommendation API Contract

## 15.1 创建正式推荐

```http
POST /api/v1/recommendations
Authorization: Bearer <user-token>
Idempotency-Key: 01J-CLIENT-KEY
```

Request：

```json
{
  "candidateId": "01J-CANDIDATE",
  "examProfileId": "01J-EXAM-PROFILE",
  "eligibilityProfileId": "01J-ELIGIBILITY-PROFILE",
  "preferenceProfileId": "01J-PREFERENCE-PROFILE",
  "locale": "zh-CN",
  "options": {
    "tiers": ["REACH", "MATCH", "SAFE", "WATCH"],
    "maxResultsPerTier": 20
  }
}
```

说明：

- 客户端可以显式指定 Profile version；
- 未指定时可由服务端解析 Candidate active profile，但必须把最终解析版本持久化；
- 客户端不得指定 `ruleSetId`、`dataVersionId` 绕过服务端 active/published 解析；
- 内部调试版本选择只允许 Admin/受控环境。

## 15.2 推荐执行顺序

契约语义固定为：

```text
Authentication
↓
Object Ownership
↓
Idempotency Check
↓
Candidate Profile Load
↓
Rule Set Resolve
↓
Data Version Resolve
↓
Request Hash
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
Quota Transaction
↓
Return Structured Result
```

AI 不进入核心同步推荐链路。

## 15.3 成功 Response `201`

```json
{
  "code": "OK",
  "message": "success",
  "data": {
    "id": "01J-RECOMMENDATION",
    "requestId": "01J-REQUEST",
    "runStatus": "SUCCEEDED",
    "requestHash": "sha256:...",
    "candidateId": "01J-CANDIDATE",
    "profiles": {
      "examProfileId": "01J-EXAM-PROFILE",
      "examProfileVersion": 3,
      "eligibilityProfileId": "01J-ELIGIBILITY-PROFILE",
      "eligibilityProfileVersion": 2,
      "preferenceProfileId": "01J-PREFERENCE-PROFILE",
      "preferenceProfileVersion": 5
    },
    "versions": {
      "ruleSet": "XJ-RULE-2026-V3",
      "admissionPlanData": "XJ-PLAN-2026-20260701",
      "admissionHistoryData": "XJ-HISTORY-2026-20260620",
      "controlLineData": "XJ-LINE-2026-20260625",
      "algorithmVersion": "REC-ALG-V1.0"
    },
    "summary": {
      "candidatePoolCount": 3200,
      "hardFilteredCount": 2780,
      "finalResultCount": 84
    },
    "quota": {
      "quotaType": "FREE_ASSESSMENT",
      "consumed": true,
      "remainingCount": 2
    },
    "freeView": {
      "reach": ["01J-RESULT-1"],
      "match": ["01J-RESULT-2"],
      "safe": ["01J-RESULT-3"]
    },
    "completedAt": "2026-07-04T21:35:12+08:00"
  },
  "warnings": [],
  "traceId": "01J..."
}
```

## 15.4 幂等重放 Response `200`

Header 可返回：

```text
Idempotent-Replay: true
```

Body 返回原 Recommendation 业务结果；不得再次扣次数。

## 15.5 Recommendation Result Item

```json
{
  "id": "01J-RESULT",
  "admissionPlanItemId": "01J-PLAN-ITEM",
  "university": {
    "id": "01J-UNIVERSITY",
    "name": "示例大学"
  },
  "major": {
    "id": "01J-MAJOR",
    "name": "计算机科学与技术"
  },
  "tier": "MATCH",
  "riskLevel": "MEDIUM",
  "riskScore": 0.42,
  "preferenceScore": 0.86,
  "overallScore": 0.74,
  "comparabilityScore": 0.81,
  "rankOrder": 1,
  "visibleFree": true,
  "reasonSummary": "历史位次接近，专业偏好匹配",
  "dataQuality": "VERIFIED_OFFICIAL",
  "warnings": []
}
```

关键限制：

- `riskScore` 是内部风险评分，不得包装为未经校准的“录取概率”；
- 禁止响应字段 `admissionProbability: 82%` 之类伪精确值；
- Tier 固定使用 `REACH / MATCH / SAFE / WATCH / UNCLASSIFIED`；
- 推荐最小事实对象为 `AdmissionPlanItem`。

## 15.6 Hard Rule Guard

Hard Rule 未满足：

```text
必须 FILTERED
不得因 preferenceScore 高重新加入
不得因 AI 建议重新加入
```

证据项示例：

```json
{
  "ruleCode": "SUBJECT_REQUIREMENT",
  "resultType": "FILTERED",
  "reasonCode": "XJ_RULE_010",
  "scope": "ITEM"
}
```

## 15.7 UNKNOWN 资格

`UNKNOWN` 不等于 `false`，也不等于 `true`。

可根据规则：

- 阻断已确认专项推荐；
- 返回 `WATCH` / warning；
- 提示用户补充核验。

不得声称用户已经具备专项资格。

## 15.8 推荐失败与扣次

以下情况不得扣正式免费次数：

- 规则解析失败；
- 数据版本缺失；
- 系统异常；
- 推荐结果为空且属于系统问题；
- AI 超时（AI 本就不应决定结构化推荐成功）；
- Idempotent replay。

---

# 16. University / Major Query Contract

## 16.1 院校列表

```http
GET /api/v1/universities?keyword=大学&provinceCode=31&page=1&pageSize=20
```

Response data：

```json
{
  "items": [
    {
      "id": "01J...",
      "nationalCode": "...",
      "name": "示例大学",
      "provinceCode": "31",
      "cityCode": "3101",
      "institutionType": "COMPREHENSIVE",
      "ownershipType": "PUBLIC",
      "educationLevel": "UNDERGRADUATE",
      "doubleFirstClass": true
    }
  ],
  "page": 1,
  "pageSize": 20,
  "total": 1,
  "totalPages": 1
}
```

## 16.2 招生计划查询

必须显式支持：

- `examYear`；
- `planType`；
- `subjectTrack`（2026）；
- 2027 选科维度；
- `dataVersion` 展示。

不得将不同 Grain 历史数据混成同一精度。

---

# 17. Membership / Quota Contract

## 17.1 当前权益

```http
GET /api/v1/entitlements/me
```

Response：

```json
{
  "code": "OK",
  "message": "success",
  "data": {
    "entitlements": [
      {
        "code": "FULL_RECOMMENDATION",
        "status": "ACTIVE",
        "startsAt": "2026-07-04T21:00:00+08:00",
        "expiresAt": null
      }
    ]
  },
  "traceId": "01J..."
}
```

禁止：

```json
{"vip": true}
```

作为正式权益模型。

## 17.2 当前 Quota

```http
GET /api/v1/quotas/me
```

Response：

```json
{
  "code": "OK",
  "message": "success",
  "data": {
    "accounts": [
      {
        "type": "FREE_ASSESSMENT",
        "totalGranted": 3,
        "totalConsumed": 1,
        "remainingCount": 2
      }
    ]
  },
  "traceId": "01J..."
}
```

---

# 18. Order Contract

## 18.1 创建订单

```http
POST /api/v1/orders
Idempotency-Key: 01J-ORDER-KEY
```

Request：

```json
{
  "items": [
    {
      "skuId": "01J-SKU",
      "quantity": 1
    }
  ]
}
```

Response `201`：

```json
{
  "code": "OK",
  "message": "success",
  "data": {
    "id": "01J-ORDER",
    "orderNo": "XJ20260704...",
    "status": "CREATED",
    "originalAmount": 199.00,
    "discountAmount": 0.00,
    "payableAmount": 199.00,
    "paidAmount": 0.00,
    "currency": "CNY"
  },
  "traceId": "01J..."
}
```

价格原则：

- 服务端根据 `product_sku` 计算；
- 不相信客户端提交金额；
- Order Item 保存 SKU/权益快照。

---

# 19. Payment Contract

## 19.1 Gate-0

真实支付上线前：

```text
主体资格核验
商户资格核验
服务类目核验
支付产品能力核验
```

未通过时：

```text
Payment Module = Interface + Mock
```

生产真实支付 endpoint 可以返回：

```text
HTTP 422
PAYMENT_001 GATE_0_NOT_PASSED
```

## 19.2 发起支付

```http
POST /api/v1/orders/{orderId}/payment-attempts
Idempotency-Key: 01J-PAY-KEY
```

Request：

```json
{
  "provider": "WECHAT_PAY",
  "clientContext": {
    "platform": "WECHAT_MINI_PROGRAM"
  }
}
```

Response `201`：

```json
{
  "code": "OK",
  "message": "success",
  "data": {
    "paymentId": "01J-PAYMENT",
    "orderId": "01J-ORDER",
    "status": "PAYING",
    "provider": "WECHAT_PAY",
    "clientPaymentParams": {
      "timeStamp": "...",
      "nonceStr": "...",
      "package": "...",
      "signType": "RSA",
      "paySign": "..."
    }
  },
  "traceId": "01J..."
}
```

`clientPaymentParams` 只是调用支付 SDK 所需参数，不代表支付成功。

## 19.3 客户端支付完成后的正确动作

客户端：

```text
wx.requestPayment success
```

只能：

```text
显示“支付结果确认中”
↓
GET /api/v1/orders/{orderId}/payment-status
```

禁止：

```text
客户端 success
↓
直接开通会员
```

## 19.4 服务端支付确认

可信路径：

```text
Provider Notification
↓
验签 / 解密 / 商户身份校验
↓
金额与币种校验
↓
provider_transaction_id 唯一校验
↓
更新 payment_record
↓
更新 sales_order
↓
PaymentSucceededEvent
↓
Membership / Entitlement Grant
```

必要时允许：

```text
Server-to-Server Provider Order Query
```

作为补偿确认。

## 19.5 Provider Callback

```http
POST /payment-callback/v1/wechat-pay/notifications
```

规则：

- 不使用 User Token；
- 必须验证 Provider 签名；
- 保存 notification 去重键；
- `notification_id` 唯一；
- `payment_provider + provider_transaction_id` 唯一；
- 重复通知返回 Provider 所需成功确认，但不重复发权益。

## 19.6 金额校验

必须：

```text
provider paid amount
==
payment_record.amount
==
server-side expected payable amount
```

不一致：

```text
PAYMENT_005 AMOUNT_MISMATCH
```

不得发放权益。

## 19.7 Payment Status Query

```http
GET /api/v1/orders/{orderId}/payment-status
```

Response：

```json
{
  "code": "OK",
  "message": "success",
  "data": {
    "orderId": "01J-ORDER",
    "orderStatus": "FULFILLED",
    "paymentStatus": "SUCCEEDED",
    "serverConfirmed": true,
    "entitlementFulfillmentStatus": "COMPLETED"
  },
  "traceId": "01J..."
}
```

只有：

```text
serverConfirmed = true
```

才可在 UI 上展示最终支付成功/权益已开通。

---

# 20. AI Analysis Contract

## 20.1 原则

AI 输入来源：

```text
Succeeded RecommendationRun
+
结构化 Result Items
+
用户 Preference Snapshot
+
受控 Evidence
```

禁止：

```text
score + rank
↓
LLM 自主推荐学校
```

## 20.2 创建分析

```http
POST /api/v1/recommendations/{recommendationId}/ai-analyses
```

Request：

```json
{
  "useCase": "DEEP_RECOMMENDATION_EXPLANATION",
  "locale": "zh-CN"
}
```

Response `202`：

```json
{
  "code": "OK",
  "message": "accepted",
  "data": {
    "id": "01J-AI-ANALYSIS",
    "status": "PENDING",
    "recommendationId": "01J-RECOMMENDATION"
  },
  "traceId": "01J..."
}
```

## 20.3 AI Guard

AI 输出进入用户可见结果前必须校验：

- 只解释 RecommendationRun 中存在的正式结果；
- 不新增被 Hard Rule FILTERED 的 AdmissionPlanItem；
- 不声称 UNKNOWN 资格已确认；
- 不输出未经校准精确录取概率；
- Prompt version 可审计；
- AI call 可追踪到 RecommendationRun。

违反：

```text
AI_007 HARD_RULE_GUARD_REJECTED
```

## 20.4 AI 隐私最小化

允许发送：

- score；
- rank；
- planType；
- preferences；
- 推荐结构化结果。

禁止发送：

- phone；
- openid；
- access token；
- API key；
- 身份证；
- 非必要真实姓名。

---

# 21. Content Contract

## 21.1 文章列表

```http
GET /api/v1/content/articles?type=POLICY_NEWS&locale=ug-CN&page=1&pageSize=20
```

返回：

- `locale`；
- `translationStatus`；
- `source`（允许公开时）；
- `publishedAt`。

`ug-CN` 内容不得把 `AI_DRAFT` 伪装成已人工审校版本。

---

# 22. Admin API Endpoint Catalog

## 22.1 Admin Auth

| Method | Path | 说明 |
|---|---|---|
| POST | `/admin-api/v1/auth/login` | 管理员登录 |
| POST | `/admin-api/v1/auth/refresh` | 刷新 |
| POST | `/admin-api/v1/auth/logout` | 注销 |
| GET | `/admin-api/v1/me` | 当前管理员/角色 |

## 22.2 Dashboard / User / Candidate

| Method | Path | 说明 |
|---|---|---|
| GET | `/admin-api/v1/dashboard/summary` | 运营摘要 |
| GET | `/admin-api/v1/users` | 用户列表 |
| GET | `/admin-api/v1/users/{userId}` | 用户详情 |
| GET | `/admin-api/v1/candidates` | Candidate 审查 |
| GET | `/admin-api/v1/candidates/{candidateId}` | Profile 版本摘要 |

## 22.3 Policy Sources / Rule Sets / Conflicts

| Method | Path | 说明 |
|---|---|---|
| GET | `/admin-api/v1/policy-sources` | 来源列表 |
| POST | `/admin-api/v1/policy-sources` | 创建来源 |
| GET | `/admin-api/v1/policy-sources/{id}` | 来源详情 |
| POST | `/admin-api/v1/policy-sources/{id}/snapshots` | 新文档快照 |
| GET | `/admin-api/v1/rule-sets` | RuleSet 列表 |
| POST | `/admin-api/v1/rule-sets` | 创建草稿版本 |
| GET | `/admin-api/v1/rule-sets/{id}` | 详情 |
| POST | `/admin-api/v1/rule-sets/{id}/publish` | 发布 |
| POST | `/admin-api/v1/rule-sets/{id}/activate` | 激活 |
| GET | `/admin-api/v1/policy-conflicts` | 冲突列表 |
| GET | `/admin-api/v1/policy-conflicts/{id}` | 冲突详情 |
| POST | `/admin-api/v1/policy-conflicts/{id}/resolve` | 解决冲突 |

## 22.4 Data Governance

| Method | Path | 说明 |
|---|---|---|
| GET | `/admin-api/v1/data-versions` | 数据版本列表 |
| POST | `/admin-api/v1/data-versions` | 创建数据版本 |
| GET | `/admin-api/v1/data-versions/{id}` | 详情 |
| POST | `/admin-api/v1/data-versions/{id}/publish` | 发布版本 |
| POST | `/admin-api/v1/import-jobs` | 创建导入任务 |
| GET | `/admin-api/v1/import-jobs` | 导入任务列表 |
| GET | `/admin-api/v1/import-jobs/{id}` | 任务详情 |
| GET | `/admin-api/v1/data-quality-issues` | 质量问题 |
| POST | `/admin-api/v1/data-quality-issues/{id}/resolve` | 解决质量问题 |

## 22.5 Admission Data

| Method | Path | 说明 |
|---|---|---|
| GET/POST | `/admin-api/v1/universities` | 院校管理 |
| GET/PATCH | `/admin-api/v1/universities/{id}` | 院校详情/修改 |
| GET/POST | `/admin-api/v1/majors` | 专业管理 |
| GET/PATCH | `/admin-api/v1/majors/{id}` | 专业详情/修改 |
| GET | `/admin-api/v1/admission-plans` | 招生计划 |
| GET | `/admin-api/v1/admission-plan-items` | 计划项 |
| GET | `/admin-api/v1/admission-history` | 历史录取 |
| GET | `/admin-api/v1/control-score-lines` | 控制线 |

## 22.6 Recommendation Audit

| Method | Path | 说明 |
|---|---|---|
| GET | `/admin-api/v1/recommendations` | 推荐运行列表 |
| GET | `/admin-api/v1/recommendations/{id}` | 版本与执行摘要 |
| GET | `/admin-api/v1/recommendations/{id}/results` | 结果项 |
| GET | `/admin-api/v1/recommendations/{id}/rule-traces` | 规则轨迹 |
| GET | `/admin-api/v1/recommendations/{id}/snapshots` | 快照元数据/受控内容 |

## 22.7 Membership / Commerce / Payment

| Method | Path | 说明 |
|---|---|---|
| GET | `/admin-api/v1/memberships` | 会员列表 |
| GET | `/admin-api/v1/entitlements` | 权益定义 |
| GET | `/admin-api/v1/quota-accounts` | Quota 账户 |
| GET | `/admin-api/v1/quota-ledger` | Ledger 审计 |
| GET | `/admin-api/v1/products` | SKU |
| POST | `/admin-api/v1/products` | 创建 SKU |
| GET | `/admin-api/v1/orders` | 订单 |
| GET | `/admin-api/v1/payments` | 支付记录 |
| GET | `/admin-api/v1/payment-notifications` | Provider 通知 |
| GET | `/admin-api/v1/refunds` | 退款记录 |

## 22.8 AI / Prompt

| Method | Path | 说明 |
|---|---|---|
| GET | `/admin-api/v1/ai-call-logs` | AI 调用审计 |
| GET | `/admin-api/v1/prompt-templates` | Prompt 模板 |
| POST | `/admin-api/v1/prompt-templates` | 创建模板 |
| GET | `/admin-api/v1/prompt-templates/{id}/versions` | Prompt 版本 |
| POST | `/admin-api/v1/prompt-templates/{id}/versions` | 新版本 |
| POST | `/admin-api/v1/prompt-versions/{id}/publish` | 发布 Prompt |

## 22.9 Content / Translation / Feedback

| Method | Path | 说明 |
|---|---|---|
| GET/POST | `/admin-api/v1/content/articles` | 内容管理 |
| GET/PATCH | `/admin-api/v1/content/articles/{id}` | 内容详情/修改 |
| POST | `/admin-api/v1/content/articles/{id}/publish` | 发布 |
| GET | `/admin-api/v1/translations/review-queue` | 翻译审校队列 |
| POST | `/admin-api/v1/translations/{id}/review` | 审校 |
| GET | `/admin-api/v1/feedback` | 用户反馈 |

## 22.10 Admin Audit

| Method | Path | 说明 |
|---|---|---|
| GET | `/admin-api/v1/operation-logs` | 管理操作日志 |

---

# 23. Admin High-Risk Mutation Contract

以下操作必须写 `admin_operation_log`：

- 发布 DataVersion；
- 激活 RuleSet；
- 解决 PolicyConflict；
- 发布 PromptVersion；
- 人工调整订单；
- 修改翻译状态；
- 人工调整 Quota/Entitlement（若未来开放）。

请求建议：

```json
{
  "reason": "根据 2026 年最新正式通知完成规则核验",
  "expectedVersion": 4
}
```

禁止无审计理由执行高风险人工修改。

---

# 24. RuleSet Publish Contract

```http
POST /admin-api/v1/rule-sets/{ruleSetId}/publish
Idempotency-Key: 01J-RULE-PUBLISH
```

发布前至少校验：

- examYear；
- examRegime；
- PolicySource；
- BusinessRule implementation key；
- unresolved blocking PolicyConflict；
- 版本唯一性。

存在阻断冲突：

```text
HTTP 409
ADMIN_005 POLICY_CONFLICT_UNRESOLVED
```

API 不允许 AI 自动 resolve。

---

# 25. DataVersion Publish Contract

```http
POST /admin-api/v1/data-versions/{dataVersionId}/publish
Idempotency-Key: 01J-DATA-PUBLISH
```

发布前至少校验：

- import job 状态；
- CRITICAL data quality issue；
- content hash；
- source linkage；
- dataset type；
- examYear；
- supersedes 关系。

推荐引擎默认只读 Published/Active 版本。

---

# 26. Recommendation Audit Contract

Admin 推荐详情必须能回答：

```text
为什么在某个时间点，
对某个 Candidate Profile Version，
使用某个 RuleSet、Admission Data Version、Algorithm Version，
推荐了某个 AdmissionPlanItem？
```

必须可读取：

- RecommendationRequest；
- RecommendationRun；
- Profile IDs + versions；
- RuleSet；
- DataVersion set；
- AlgorithmVersion；
- ResultItem；
- RuleTrace；
- Snapshot hashes；
- warning codes。

成功 Run 的关键版本引用不可修改。

---

# 27. Async Contract

适用：

- AI 深度报告；
- PDF（P1）；
- 批量翻译；
- 数据导入；
- 质量检测。

异步创建返回：

```text
HTTP 202
```

标准状态：

```text
PENDING
RUNNING
SUCCEEDED
FAILED
CANCELLED
```

查询响应：

```json
{
  "id": "01J-TASK",
  "status": "RUNNING",
  "progress": {
    "current": 120,
    "total": 500
  },
  "error": null
}
```

P0 不因异步任务引入 Kafka/RabbitMQ。

---

# 28. Security Contract

## 28.1 不信任客户端字段

不得信任：

- userId；
- ownerUserId；
- adminId；
- payableAmount；
- paidAmount；
- paymentSuccess；
- membership status；
- entitlement；
- remaining quota；
- ruleSetId（用户推荐）；
- dataVersionId（用户推荐）；
- hardRule pass/fail。

## 28.2 Sensitive Field

普通 API 禁止返回：

- password hash；
- session token hash；
- OpenID（除非明确内部受控需求）；
- provider secret；
- payment private key；
- AI API key；
- raw stack trace。

## 28.3 Rate Limit

至少覆盖：

- 微信登录；
- Token refresh；
- 正式推荐；
- AI Analysis；
- 支付发起；
- Admin Login。

Redis 可用于限流，但 Redis 故障不得改变会员、支付、Quota 等事实状态。

---

# 29. OpenAPI Organization

建议 Monorepo：

```text
openapi/
├── openapi.yaml
├── paths/
│   ├── user-auth.yaml
│   ├── user-candidates.yaml
│   ├── user-recommendations.yaml
│   ├── user-admission.yaml
│   ├── user-membership.yaml
│   ├── user-commerce.yaml
│   ├── user-ai.yaml
│   ├── user-content.yaml
│   ├── admin-auth.yaml
│   ├── admin-policy.yaml
│   ├── admin-data.yaml
│   ├── admin-admission.yaml
│   ├── admin-recommendation.yaml
│   ├── admin-commerce.yaml
│   ├── admin-ai.yaml
│   └── payment-callback.yaml
└── components/
    ├── schemas.yaml
    ├── responses.yaml
    ├── parameters.yaml
    ├── headers.yaml
    └── security-schemes.yaml
```

---

# 30. OpenAPI Root Skeleton

```yaml
openapi: 3.1.1
info:
  title: Xinjiang Gaokao AI Volunteer Assistant API
  version: 1.0.0
servers:
  - url: /api/v1
    description: User API
  - url: /admin-api/v1
    description: Admin API

tags:
  - name: Auth
  - name: Candidate
  - name: Recommendation
  - name: Admission
  - name: Membership
  - name: Commerce
  - name: AI
  - name: Content
  - name: Admin

components:
  securitySchemes:
    UserBearerAuth:
      type: http
      scheme: bearer
    AdminBearerAuth:
      type: http
      scheme: bearer
```

注意：实际机器契约应将 User/Admin operation 分别声明正确 security scheme，不能仅靠 URL 约定。

---

# 31. Core Schema Baseline

## 31.1 RecommendationTier

```text
REACH
MATCH
SAFE
WATCH
UNCLASSIFIED
```

## 31.2 RiskLevel

```text
VERY_HIGH
HIGH
MEDIUM
LOW
VERY_LOW
INSUFFICIENT_DATA
NON_COMPARABLE
```

## 31.3 ExamRegime

```text
TRADITIONAL_WENLI
XJ_3_1_2
SPECIAL_THREE_SCHOOL
OTHER_SPECIAL
```

## 31.4 PlanType

```text
NORMAL
SINGLE_COLUMN
```

## 31.5 SubjectTrack (2026)

```text
LITERATURE_HISTORY
SCIENCE_ENGINEERING
```

## 31.6 ExamLanguagePath

```text
FOREIGN_LANGUAGE
ETHNIC_LANGUAGE
UNKNOWN
```

## 31.7 FirstChoiceSubject (2027)

```text
PHYSICS
HISTORY
```

## 31.8 SecondChoiceSubject (2027)

```text
CHEMISTRY
BIOLOGY
POLITICS
GEOGRAPHY
```

---

# 32. Client Compatibility Rules

微信小程序与 Admin Web 生成/手写 Client 时必须：

- 以 machine-readable contract 为准；
- enum 必须有 unknown fallback；
- 不依赖 `message` 逻辑判断；
- 金额使用 decimal string 或明确 decimal schema，禁止浮点误差驱动支付；
- 日期统一解析 offset；
- 维吾尔语文本按 locale 显示；
- 不把 Admin DTO 复用于 User DTO 泄露内部字段。

---

# 33. Contract Test Baseline

必须覆盖：

## 33.1 User/Admin 隔离

```text
User Token -> /admin-api/v1/** = rejected
Admin Token -> /api/v1/** user principal operation = rejected
```

## 33.2 Recommendation Idempotency

```text
same key + same request
=> same business result
=> quota charged once
```

```text
same key + different request
=> 409 IDEMPOTENCY_002
```

## 33.3 Profile Versioning

```text
create new profile
=> old version still readable
=> RecommendationRun points to exact used version
```

## 33.4 Hard Rule

```text
Hard Rule fail + very high preference
=> still FILTERED
```

## 33.5 Unknown Eligibility

```text
UNKNOWN special eligibility
=> never represented as confirmed eligible
```

## 33.6 Payment

```text
client says success
=> membership NOT granted
```

```text
valid server-confirmed payment
=> PaymentSucceededEvent
=> entitlement granted once
```

```text
duplicate provider notification
=> no duplicate membership/entitlement
```

## 33.7 Recommendation Immutable Version

```text
SUCCEEDED Run
=> cannot mutate ruleSet/dataVersion/algorithmVersion
```

## 33.8 Free Quota

```text
system recommendation failure
=> no quota deduction
```

---

# 34. P0 Endpoint Priority

## P0-A 必须先实现

1. User WeChat Login；
2. Candidate CRUD；
3. Exam Profile Version；
4. Eligibility Profile Version；
5. Preference Profile Version；
6. Recommendation Create / Read；
7. Quota；
8. University / Major / Plan Item Query；
9. Membership / Entitlement；
10. Product / Order；
11. Payment Interface + Mock（Gate-0 前）；
12. AI Analysis；
13. Content；
14. Admin Auth；
15. Admin Policy / RuleSet / Conflict；
16. Admin DataVersion / Import / Quality；
17. Recommendation Audit；
18. AI Log / Prompt Version。

## P0-B Gate 后实现

- 真实微信支付 Provider Adapter；
- 真实支付 callback；
- Server-to-Server payment query compensation。

---

# 35. Explicit Non-Goals

本 Contract 不引入：

```text
Microservices
API Gateway Product
Kafka
RabbitMQ
Kubernetes
Elasticsearch
OpenSearch
Full RAG
Vector DB
Multi-Agent Runtime
Real-time Web Search Recommendation
```

本 Contract 不允许：

- AI 自主补充推荐学校；
- 客户端指定 Hard Rule 结果；
- 客户端确认支付成功后直接开会员；
- 把 Candidate Profile 字段塞回 User；
- 用 Boolean 表达复杂资格；
- 修改成功 RecommendationRun 的关键版本引用；
- 把 `user.vip` 作为正式商业模型；
- 免费次数只放 Redis。

---

# 36. Step 5 Acceptance Checklist

| 检查项 | 状态 |
|---|---|
| Contract First | ✅ |
| User API `/api/v1/**` | ✅ |
| Admin API `/admin-api/v1/**` | ✅ |
| User/Admin Principal 隔离 | ✅ |
| Request / Response Envelope | ✅ |
| Error Code | ✅ |
| Auth | ✅ |
| Pagination | ✅ |
| Version | ✅ |
| Idempotency | ✅ |
| Recommendation `request_hash + idempotency_key` | ✅ |
| Quota 防重复扣次 | ✅ |
| 支付不信任客户端 | ✅ |
| Provider callback 幂等 | ✅ |
| AI 不突破 Hard Rule | ✅ |
| Profile Versioning | ✅ |
| RecommendationRun 不可变语义 | ✅ |
| OpenAPI 组织方案 | ✅ |
| Mini Program API | ✅ |
| Admin Web API | ✅ |
| Contract Test Baseline | ✅ |

---

# 37. Step 5 Status

```text
STEP 5
API Contract V1.0
=
COMPLETED
```

下一步：

```text
Step 6
《Information Architecture V1.0》
建议文件名：06-information-architecture.md
```

---

# 38. External Standards Note

本 Contract 的 HTTP method/status/idempotency语义遵循 HTTP 标准语义；机器可读契约采用 OpenAPI 3.1.x。支付 Provider 的具体签名、通知解密与查单字段必须在 Gate-0 后以当时有效的官方支付平台文档为准，不能把本设计文档当作 Provider 协议替代品。
