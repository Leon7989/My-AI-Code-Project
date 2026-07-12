# <a name="新疆高考-ai-志愿助手"></a>新疆高考 AI 志愿助手
# <a name="新疆高考业务规则模型-v1.0"></a>新疆高考业务规则模型 V1.0
-----
## <a name="文档信息"></a>0. 文档信息
**项目名称：** 新疆高考 AI 志愿助手
**文档名称：** 新疆高考业务规则模型
**建议文件名：** 02-xinjiang-business-rules.md
**版本：** V1.0
**状态：** Architecture Baseline
**适用范围：** 新疆普通高考志愿推荐系统
**当前重点年份：** 2026
**前瞻适配年份：** 2027 及以后
**上游文档：** 01-prd.md
**下游文档：**

- 03-system-architecture.md
- 04-database-design.md
- 05-api-contract.md
- 06-information-architecture.md
- 08-ai-architecture.md
-----
# <a name="文档目标"></a>1. 文档目标
本文件负责把新疆高考政策、招生计划、投档逻辑、考生资格与志愿推荐需求，从自然语言政策转化为：

- 可存储的数据结构
- 可执行的业务规则
- 可测试的判断条件
- 可审计的推荐链路
- 可版本化的年度规则
- 可供 Codex 实现的工程规范

本系统的核心原则是：

不允许前端、后端、数据库和 AI 模块分别理解新疆高考规则。

所有模块必须共同依赖本业务规则模型。

-----
# <a name="最核心架构决策规则必须年度版本化"></a>2. 最核心架构决策：规则必须年度版本化
## <a name="禁止永久硬编码新疆高考模式"></a>2.1 禁止永久硬编码“新疆高考模式”
新疆高考制度正在发生年度切换。

2026 年报名规定仍按文史类、理工类及相应考试科目体系运行；新疆教育考试院已经明确，2027 年普通高考实行“3+1+2”模式。

因此禁止设计：

**enum** SubjectCategory {
`    `LIBERAL\_ARTS,
`    `SCIENCE
}

然后永久使用。

正确设计必须是：

ExamYear
`    `↓
ExamRegime
`    `↓
对应年度 Candidate Profile
`    `↓
对应年度 Admission Plan
`    `↓
对应年度 Rule Set

-----
## <a name="考试制度模型"></a>2.2 考试制度模型
定义：

ExamRegime

建议枚举：

TRADITIONAL\_WENLI
XJ\_3\_1\_2
SPECIAL\_THREE\_SCHOOL
OTHER\_SPECIAL

年度绑定示例：

2026
→ TRADITIONAL\_WENLI

2027
→ XJ\_3\_1\_2

注意：

该映射必须存储在数据库或配置中心中。

禁止：

**if** (year >= 2027) {
`    `**...**
}

长期散落在业务代码中。

-----
# <a name="政策来源层级模型"></a>3. 政策来源层级模型
所有规则必须有来源。

定义：

PolicySource

至少包含：

source\_id
title
issuer
source\_type
publication\_date
effective\_from
effective\_to
source\_location
content\_hash
retrieved\_at
review\_status

-----
## <a name="建议来源类型"></a>3.1 建议来源类型
OFFICIAL\_ANNUAL\_ADMISSION\_RULE
OFFICIAL\_REGISTRATION\_RULE
OFFICIAL\_ADMISSION\_PLAN\_CATALOG
OFFICIAL\_VOLUNTEER\_FILLING\_NOTICE
OFFICIAL\_SPECIAL\_PROGRAM\_NOTICE
OFFICIAL\_UNIVERSITY\_CHARTER
OFFICIAL\_SCORE\_LINE
OFFICIAL\_ADMISSION\_RESULT
OFFICIAL\_POLICY\_INTERPRETATION
OTHER

-----
## <a name="来源优先级原则"></a>3.2 来源优先级原则
建议系统默认采用：

当年度正式招生计划目录
`        `↓
当年度最新专项通知
`        `↓
当年度普通高校招生工作规定
`        `↓
当年度报名工作规定
`        `↓
新疆教育考试院正式政策解读
`        `↓
高校正式招生章程
`        `↓
历史年度规则
`        `↓
第三方资料

但该优先级不是机械覆盖。

当出现：

- 后发布文件
- 更具体专项文件
- 更具体资格规则
- 同级来源冲突

必须进入：

POLICY\_CONFLICT\_REVIEW

不得让 AI 自己决定。

-----
# <a name="已识别的真实政策冲突风险"></a>4. 已识别的真实政策冲突风险
2026 年官方报名规定明确区分单列类考试科目路径：

- 选择外语科目的考生，可兼报普通类；
- 选择民族语文科目的考生，不兼报普通类。

而后续 2026 年普通高校招生工作规定使用了更加概括的表述，即单列类招生计划考生可兼报普通类。

因此系统不得简单写：

**if** (planType == SINGLE\_COLUMN) {
`    `canApplyNormal = **true**;
}

V1.0 采用：

规则状态：
REQUIRES\_POLICY\_RECONCILIATION

工程策略：

1. 保存两个官方来源；
1. 保留规则粒度差异；
1. 2026 推荐时优先使用更加具体的考试科目路径约束；
1. 上线前以当年度正式志愿填报系统、正式招生计划目录及最新官方说明进行再次核验；
1. 后台允许管理员调整最终生效规则；
1. 每次修改必须产生新规则版本。
-----
# <a name="核心领域对象"></a>5. 核心领域对象
整个推荐系统至少包含以下核心对象：

Candidate
CandidateExamProfile
CandidateEligibilityProfile
CandidatePreferenceProfile

ExamRegime
PlanType
SubjectTrack
ExamLanguagePath

AdmissionBatch
AdmissionPlan
AdmissionPlanItem
University
Major

EligibilityRule
CompatibilityRule
BatchRule
ProgramConstraintRule

AdmissionHistory
ControlScoreLine
RankingSnapshot

RecommendationRequest
RecommendationRun
RecommendationCandidate
RecommendationResult

-----
# <a name="candidate考生主体"></a>6. Candidate：考生主体
定义：

Candidate

建议仅保存账号主体信息。

字段：

candidate\_id
user\_id
created\_at
updated\_at

不要把：

- 分数
- 位次
- 科类
- 年份
- 单列类
- 专项资格

直接永久写进 user 表。

原因：

同一个用户可能：

- 修改数据
- 帮家人模拟
- 复读后再次参加
- 创建多个方案
- 进行不同偏好模拟
-----
# <a name="candidateexamprofile考试画像"></a>7. CandidateExamProfile：考试画像
建议设计：

CandidateExamProfile

字段：

profile\_id

candidate\_id

exam\_year

exam\_regime

exam\_path

score

rank

plan\_type

subject\_track

first\_choice\_subject

second\_choice\_subject\_1

second\_choice\_subject\_2

exam\_language\_path

foreign\_language

province

profile\_status

created\_at
updated\_at

-----
# <a name="年考试画像模型"></a>8. 2026 年考试画像模型
2026 年新疆官方规则仍需要支持：

文史类
理工类

同时招生计划类型为：

普通类
单列类

2026 年官方报名规定明确，两类招生计划及单列类考试科目路径存在差异。

-----
## <a name="plantype"></a>8.1 PlanType
定义：

PlanType

枚举：

NORMAL
SINGLE\_COLUMN

禁止加入：

BILINGUAL
ART
SPORT

原因：

这些不是同一个业务维度。

艺术、体育应作为：

CandidateTrack

或者：

SpecialExamCategory

独立建模。

-----
## <a name="subjecttrack"></a>8.2 2026 SubjectTrack
定义：

SubjectTrack

2026：

LITERATURE\_HISTORY
SCIENCE\_ENGINEERING

-----
## <a name="单列类考试语言路径"></a>8.3 单列类考试语言路径
定义：

ExamLanguagePath

建议：

FOREIGN\_LANGUAGE
ETHNIC\_LANGUAGE
NOT\_APPLICABLE
UNKNOWN

对普通类：

NOT\_APPLICABLE

对单列类：

FOREIGN\_LANGUAGE
ETHNIC\_LANGUAGE
UNKNOWN

-----
## <a name="外语语种"></a>8.4 外语语种
定义：

ForeignLanguageType

2026 官方报名规定列明普通类外语语种包括英语、俄语、日语、法语、德语、西班牙语。

枚举：

ENGLISH
RUSSIAN
JAPANESE
FRENCH
GERMAN
SPANISH
OTHER
UNKNOWN

注意：

高校专业限制应独立匹配招生章程。

不得仅凭：

foreign\_language

自动判断专业一定可报。

-----
# <a name="年考试画像模型-1"></a>9. 2027 年考试画像模型
2027 年新疆普通高考实行：

3 + 1 + 2

其中：

- 3：语文、数学、外语
- 1：物理或历史
- 2：从思想政治、地理、化学、生物学中选择两门

且考生填报专业时，需要满足高校专业选考科目要求。

-----
## <a name="firstchoicesubject"></a>9.1 FirstChoiceSubject
PHYSICS
HISTORY

-----
## <a name="secondchoicesubject"></a>9.2 SecondChoiceSubject
POLITICS
GEOGRAPHY
CHEMISTRY
BIOLOGY

-----
## <a name="专业选科要求"></a>9.3 专业选科要求
定义：

MajorSubjectRequirement

字段建议：

requirement\_id
exam\_year

university\_id
major\_id

first\_choice\_requirement

required\_second\_subjects

requirement\_mode

source\_id
version

-----
## <a name="推荐硬过滤"></a>9.4 推荐硬过滤
2027 年：

用户选科
`    `↓
专业选科要求
`    `↓
不满足
`    `↓
直接排除

禁止：

不满足选科要求
\+
AI认为专业适合
\=
继续推荐

-----
# <a name="跨-2026-2027-历史数据断点"></a>10. 跨 2026 → 2027 历史数据断点
这是系统必须特别处理的问题。

由于 2027 年考试模式切换为“3+1+2”，从产品设计角度推断，不能简单认为：

2026 理工类第 8000 名
\=
2027 物理组第 8000 名

这是基于考试制度变化作出的工程判断，而不是官方直接给出的等价关系。制度变化本身有官方依据。

因此建立：

HistoricalComparabilityGroup

示例：

XJ\_TRADITIONAL\_SCIENCE
XJ\_TRADITIONAL\_ARTS
XJ\_312\_PHYSICS
XJ\_312\_HISTORY

默认规则：

不同 ComparabilityGroup
不得直接进行位次差值计算

-----
## <a name="冷启动策略"></a>10.1 2027 冷启动策略
2027 第一届新高考期间：

禁止直接：

2026最低位次
\-
2027用户位次
\=
风险值

建议：

历史院校层级
\+
历史招生稳定性
\+
新年度招生计划
\+
选科要求
\+
招生计划变化
\+
控制线相对位置
\+
分位指标
\+
人工校准

生成较高不确定度结果。

结果必须显示：

数据不确定性：较高
原因：考试制度切换

-----
# <a name="candidateeligibilityprofile资格画像"></a>11. CandidateEligibilityProfile：资格画像
定义：

CandidateEligibilityProfile

字段：

eligibility\_profile\_id

candidate\_id
exam\_year

national\_special\_status
local\_special\_status
south\_xinjiang\_special\_status
counterpart\_assistance\_status
university\_special\_status

high\_level\_sports\_status

art\_exam\_status
sports\_exam\_status

military\_eligibility\_status
police\_eligibility\_status

application\_scope

verification\_level

source\_type

created\_at
updated\_at

-----
# <a name="所有资格必须采用多态状态"></a>12. 所有资格必须采用多态状态
禁止 boolean：

true
false

因为真实用户经常“不知道”。

统一采用：

EligibilityStatus

枚举：

VERIFIED\_ELIGIBLE
SELF\_DECLARED\_ELIGIBLE
UNKNOWN
VERIFIED\_INELIGIBLE
EXPIRED
REQUIRES\_REVIEW

-----
## <a name="为什么不能只有-truefalse"></a>12.1 为什么不能只有 true/false
例如用户问：

我不知道自己有没有南疆单列资格。

系统不能：

false

正确：

UNKNOWN

然后：

不参与正式专项推荐
\+
提供政策说明
\+
提示用户确认

-----
# <a name="禁止根据民族自动推断资格"></a>13. 禁止根据民族自动推断资格
2026 年官方计划类型确实存在明确的招生对象规则，但产品不应仅通过用户民族自动推断最终招生资格；应优先使用考生本人已确认的计划类型、考试路径或官方审核资格。相关计划类型规则来自新疆官方报名规定。

因此禁止：

**if** (ethnicity == XXX) {
`    `planType = SINGLE\_COLUMN;
}

正确：

用户确认计划类型
\+
官方资格信息
\+
年度规则

-----
# <a name="applicationscope可报范围"></a>14. ApplicationScope：可报范围
这是前面方案遗漏的一个重大业务维度。

2026 年新疆报名规则对部分来疆务工人员随迁子女，根据实际就读、学籍等条件，存在不同院校层次和地域报考范围。官方规则中存在：

- 区内外高职（专科）
- 区内本科 + 区内外高职（专科）
- 区内外本专科

等不同范围。

因此定义：

ApplicationScope

建议枚举：

ALL\_REGION\_ALL\_LEVELS

XINJIANG\_UNDERGRADUATE
\_PLUS\_ALL\_REGION\_VOCATIONAL

ALL\_REGION\_VOCATIONAL\_ONLY

XINJIANG\_ONLY

CUSTOM

UNKNOWN

-----
## <a name="mvp-处理原则"></a>14.1 MVP 处理原则
MVP 不负责自行审查复杂户籍学籍资格。

用户填写：

你的官方报考范围是否受到限制？

○ 不受限制
○ 仅部分范围
○ 不确定

如果：

UNKNOWN

则：

- 给出提醒
- 不声称拥有全部资格
- 允许用户继续模拟
- 推荐结果标记“资格待确认”
-----
# <a name="南疆相关规则模型"></a>15. 南疆相关规则模型
2026 年官方规定明确：

- 未在南疆四地州高级中等教育阶段连续三年实际就读的考生，不享受南疆照顾政策；
- 对口援疆政策还与受援地报名有关；
- 往年通过部分专项或南疆单列计划录取后放弃入学资格或退学的考生，可能失去相关再次报考资格。

因此南疆资格不能设计为：

isSouthXinjiang = true

正确拆分：

SouthXinjiangEligibility

包括：

status

continuous\_study\_years

registration\_region

officially\_confirmed

previous\_special\_admission\_history

source

-----
# <a name="对口援疆规则模型"></a>16. 对口援疆规则模型
官方 2026 年招生规则明确，对口援疆计划限对口援疆受援地区相关考生报考；相关定向就业计划还可能涉及协议要求。

定义：

CounterpartAssistanceEligibility

字段：

status
registration\_region
assistance\_region\_code
officially\_confirmed
agreement\_required

禁止仅根据：

current\_city

推断资格。

-----
# <a name="admissionbatch录取批次"></a>17. AdmissionBatch：录取批次
2026 年新疆官方普通高校招生工作规定设置 9 个主要录取批次。

定义：

AdmissionBatch

2026 建议枚举：

UNDERGRADUATE\_EARLY

SPECIAL\_PLAN\_UNDERGRADUATE\_1

HIGH\_LEVEL\_SPORTS\_UNDERGRADUATE\_1

UNDERGRADUATE\_1

SPECIAL\_PLAN\_UNDERGRADUATE\_2

HIGH\_LEVEL\_SPORTS\_UNDERGRADUATE\_2

UNDERGRADUATE\_2

VOCATIONAL\_EARLY

VOCATIONAL\_GENERAL

另建特殊考试批次：

THREE\_SCHOOL\_TO\_VOCATIONAL

-----
# <a name="batchrule批次规则"></a>18. BatchRule：批次规则
不得仅保存：

batch\_name

必须保存：

batch\_rule\_id

exam\_year
batch\_code

submission\_mode

max\_school\_choices
max\_major\_choices\_per\_school

parallel\_group\_count

eligibility\_requirement

allow\_cross\_category

sequence\_order

source\_id

effective\_from
effective\_to

version

-----
# <a name="批次志愿结构"></a>19. 2026 批次志愿结构
根据 2026 年官方招生工作规定：
## <a name="本科一批次"></a>19.1 本科一批次
18 个平行志愿
每个志愿 6 个专业
## <a name="本科二批次"></a>19.2 本科二批次
18 个平行志愿
每个志愿 6 个专业
## <a name="国家及地方专项南疆单列对口援疆计划本科一批次"></a>19.3 国家及地方专项、南疆单列、对口援疆计划本科一批次
6 个平行志愿
每个志愿 6 个专业
## <a name="国家及地方专项南疆单列对口援疆计划本科二批次"></a>19.4 国家及地方专项、南疆单列、对口援疆计划本科二批次
6 个平行志愿
每个志愿 6 个专业
## <a name="高职专科批次"></a>19.5 高职（专科）批次
18 个平行志愿
每个志愿 6 个专业

其他提前批、艺术类和特殊类型具有不同结构。

因此：

18

绝不能硬编码为新疆统一志愿数量。

-----
# <a name="submissionmode投档模式"></a>20. SubmissionMode：投档模式
定义：

SubmissionMode

枚举：

PARALLEL
SEQUENTIAL
SPECIAL

-----
## <a name="平行志愿"></a>20.1 2026 平行志愿
2026 官方规则明确，部分批次采用平行志愿，原则为：

分数优先
遵循志愿

包括本科一批次、本科二批次、相关专项批次、高职普通批次等。

-----
## <a name="顺序志愿"></a>20.2 2026 顺序志愿
部分提前批及高水平运动队等采用顺序志愿，原则为：

志愿优先
遵循分数

具体范围依据当年度规则。

-----
# <a name="平行志愿模拟原则"></a>21. 平行志愿模拟原则
系统必须理解：

A志愿
B志愿
C志愿
D志愿

不是：

A、B、C、D同时投档

而是按照考生排序后，对其志愿顺序逐一检索，出现符合投档条件的院校时进行投档。2026 官方规则同时明确平行志愿一次性投档、不补充投档，未完成计划通过征集志愿处理。

因此未来“志愿模拟器”必须区分：

候选院校推荐

与：

志愿顺序模拟

它们不是同一功能。

-----
# <a name="单列类兼报投档顺序"></a>22. 单列类兼报投档顺序
2026 年招生工作规定明确描述了单列类兼报场景下的投档顺序：

先投普通类
↓
若录取
↓
取消单列类志愿

若未录取
↓
继续投单列类

因此未来模拟系统不得把：

普通类池
单列类池

完全独立计算。

需要：

CompatibilityPath

-----
## <a name="compatibilitypath"></a>22.1 CompatibilityPath
建议：

NORMAL\_ONLY

SINGLE\_ONLY

NORMAL\_THEN\_SINGLE

REQUIRES\_REVIEW

-----
# <a name="admissionplan招生计划"></a>23. AdmissionPlan：招生计划
这是推荐系统的核心。

定义：

AdmissionPlan

表示：

某年度，某高校，在新疆，某计划类型、某批次下的一组招生计划。

字段：

admission\_plan\_id

exam\_year

province\_code

university\_id

plan\_type

batch\_code

subject\_track

exam\_regime

plan\_category

total\_quota

source\_id

data\_version

status

-----
# <a name="admissionplanitem招生计划项"></a>24. AdmissionPlanItem：招生计划项
推荐真正最小单位：

AdmissionPlanItem

表示：

某大学某专业，在某年度新疆某计划类型、某批次中的招生项。

字段：

plan\_item\_id

admission\_plan\_id

university\_id

major\_id

major\_group\_id

exam\_year

plan\_type

batch\_code

subject\_track

quota

tuition

duration\_years

major\_note

special\_requirement

foreign\_language\_requirement

physical\_requirement

gender\_requirement\_if\_lawful

subject\_requirement

agreement\_requirement

source\_id

data\_version

-----
# <a name="为什么不能只推荐-university"></a>25. 为什么不能只推荐 University
错误：

推荐：
四川大学

正确：

四川大学
\+
2026 新疆招生
\+
理工类
\+
普通类
\+
本科一批
\+
某具体专业或专业组

因为同一高校的不同专业可能拥有不同：

- 批次
- 招生人数
- 录取位次
- 身体限制
- 外语要求
- 定向协议
- 专项资格

2026 官方规则也明确高校不同专业在符合条件时可能处于不同批次，因此推荐模型必须至少保留专业和批次维度。

-----
# <a name="推荐规则执行顺序"></a>26. 推荐规则执行顺序
系统推荐必须严格按照：

Step 1
数据完整性验证

↓

Step 2
考试年度规则加载

↓

Step 3
考试制度匹配

↓

Step 4
报考范围校验

↓

Step 5
计划类型兼容性

↓

Step 6
批次资格校验

↓

Step 7
专项资格过滤

↓

Step 8
专业硬条件过滤

↓

Step 9
历史数据可比性判断

↓

Step 10
风险计算

↓

Step 11
用户偏好排序

↓

Step 12
冲稳保分层

↓

Step 13
AI解释

↓

Step 14
生成结果

-----
# <a name="硬规则与软规则必须分离"></a>27. 硬规则与软规则必须分离
## <a name="hard-rules"></a>27.1 Hard Rules
不满足直接排除。

例如：

不具备专项资格

不满足选科要求

超出官方可报范围

计划类型不兼容

专业明确要求未满足

-----
## <a name="soft-rules"></a>27.2 Soft Rules
用于排序。

例如：

城市偏好

专业偏好

学费预算

985/211偏好

是否接受中外合作

考研倾向

-----
## <a name="禁止做法"></a>27.3 禁止做法
禁止：

硬规则不满足
\+
用户非常喜欢
\=
仍然推荐

AI 不拥有突破 Hard Rule 的权限。

-----
# <a name="专业限制规则"></a>28. 专业限制规则
定义：

ProgramConstraintRule

可能包含：

SUBJECT\_REQUIREMENT
PHYSICAL\_REQUIREMENT
LANGUAGE\_REQUIREMENT
INTERVIEW\_REQUIREMENT
POLITICAL\_REVIEW\_REQUIREMENT
ART\_EXAM\_REQUIREMENT
SPORT\_EXAM\_REQUIREMENT
AGREEMENT\_REQUIREMENT
REGION\_REQUIREMENT
OTHER

2026 官方招生规则明确，部分军警公安及提前批专业涉及专门的思想政治品德考核、体检和面试等要求；高校最终录取还须依据招生章程及专业培养要求。

-----
# <a name="特殊类型不得自动放入普通推荐池"></a>29. 特殊类型不得自动放入普通推荐池
以下类型默认：

SPECIAL\_HANDLING

例如：

- 军队
- 公安
- 消防
- 定向培养军士
- 艺术类
- 体育类
- 公费师范生
- 优师专项
- 农村订单定向医学生
- 高水平运动队
- 高校专项
- 定向就业
- 对口援疆

2026 官方规则对多类提前批和特殊项目有独立要求。

-----
# <a name="推荐风险模型"></a>30. 推荐风险模型
MVP 禁止直接输出未经验证的：

录取概率 87%

采用：

RiskLevel

枚举：

VERY\_HIGH
HIGH
MEDIUM
LOW
VERY\_LOW
INSUFFICIENT\_DATA
NON\_COMPARABLE

-----
# <a name="冲稳保模型"></a>31. 冲稳保模型
定义：

RecommendationTier

枚举：

REACH
MATCH
SAFE
WATCH
UNCLASSIFIED

其中：

REACH
= 冲

MATCH
= 稳

SAFE
= 保

新增：

WATCH

用于：

- 数据波动过大
- 招生人数突变
- 制度切换
- 专业首次招生
- 历史数据缺失
-----
# <a name="冲稳保不是固定百分比"></a>32. 冲稳保不是固定百分比
禁止：

位次差 5%
= 稳

建议综合：

用户位次

历史最低位次

历史录取中位趋势

招生人数

年份波动

计划变化

专业热度变化

批次

计划类型

数据完整度

考试制度可比性

-----
# <a name="admissionhistory历史录取数据"></a>33. AdmissionHistory：历史录取数据
字段：

history\_id

exam\_year

university\_id

major\_id

plan\_type

batch\_code

subject\_track

exam\_regime

quota

lowest\_score
lowest\_rank

average\_score
average\_rank

highest\_score
highest\_rank

control\_line

source\_id

data\_version

quality\_status

-----
# <a name="历史数据必须同维度比较"></a>34. 历史数据必须同维度比较
禁止：

2025 普通类

与：

2026 单列类

直接比较。

禁止：

本科一批

与：

专项一批

直接比较。

禁止：

院校最低位次

直接冒充：

某专业最低位次

-----
# <a name="数据可比性评分"></a>35. 数据可比性评分
定义：

ComparabilityScore

建议范围：

0 - 100

考虑：

同计划类型
同科类/选科组
同批次
同专业粒度
同考试制度
招生人数稳定度
年度连续性
数据来源可靠性

-----
## <a name="示例"></a>35.1 示例
同一专业
同一计划类型
同一科类
连续3年
官方数据

→ 高可比

只有学校级数据
专业级数据缺失

→ 中可比

跨2026/2027考试制度

→ 低可比或不可直接比较

-----
# <a name="dataqualitystatus"></a>36. DataQualityStatus
定义：

VERIFIED\_OFFICIAL
VERIFIED\_SECONDARY
MANUALLY\_REVIEWED
UNVERIFIED
CONFLICTED
INCOMPLETE

推荐引擎默认：

CONFLICTED

数据不得直接进入高置信推荐。

-----
# <a name="加分信息模型"></a>37. 加分信息模型
2026 新疆招生工作规定存在不同政策加分情形，并规定同一考生符合多项增加分数投档条件时，只取幅度最大的一项，且存在适用范围限制。

因此禁止：

bonus1 + bonus2 + bonus3

设计：

CandidateBonusProfile

字段：

bonus\_item
officially\_verified
raw\_bonus\_value
applicable\_scope
effective\_bonus\_value
source

-----
## <a name="mvp-原则"></a>37.1 MVP 原则
系统不自行认定加分资格。

用户输入：

官方确认投档加分：15分

或：

未知

推荐时同时保留：

raw\_score
投档参考分

-----
# <a name="score-与-rank-必须分开"></a>38. Score 与 Rank 必须分开
定义：

raw\_score
policy\_bonus
effective\_submission\_score
rank

禁止：

score = 用户高考分 + 所有加分

因为：

- 加分存在适用范围
- 高校可能有不同使用规则
- 位次口径可能不同

系统必须保存原始值。

-----
# <a name="控制线模型"></a>39. 控制线模型
定义：

ControlScoreLine

字段：

exam\_year
plan\_type
subject\_track
batch\_code
score\_line
source\_id
data\_version

控制线主要用于：

- 批次资格过滤
- 相对位置分析
- 风险解释

但不能单独代替位次分析。

-----
# <a name="推荐核心流水线"></a>40. 推荐核心流水线
正式定义：

RecommendationPipeline

-----
## <a name="stage-1profile-validation"></a>Stage 1：Profile Validation
检查：

examYear
score
rank
examRegime
planType
subjectTrack

-----
## <a name="stage-2rule-set-resolution"></a>Stage 2：Rule Set Resolution
加载：

rule\_set(exam\_year)

例如：

XJ-2026-V1

-----
## <a name="stage-3application-scope-filter"></a>Stage 3：Application Scope Filter
排除不可报地域或层次。

-----
## <a name="stage-4plan-compatibility-filter"></a>Stage 4：Plan Compatibility Filter
生成：

EligiblePlanPool

-----
## <a name="stage-5batch-filter"></a>Stage 5：Batch Filter
根据：

- 控制线
- 用户资格
- 批次类型

处理。

-----
## <a name="stage-6special-qualification-filter"></a>Stage 6：Special Qualification Filter
过滤：

- 国家专项
- 地方专项
- 南疆单列
- 对口援疆

等。

-----
## <a name="stage-7program-hard-constraint-filter"></a>Stage 7：Program Hard Constraint Filter
检查：

- 专业资格
- 选科
- 体检
- 语言
- 面试
- 协议
-----
## <a name="stage-8historical-comparability"></a>Stage 8：Historical Comparability
计算：

ComparabilityScore

-----
## <a name="stage-9risk-scoring"></a>Stage 9：Risk Scoring
生成：

RiskScore

-----
## <a name="stage-10preference-ranking"></a>Stage 10：Preference Ranking
综合：

专业
地区
学校层次
费用
未来规划

-----
## <a name="stage-11tier-assignment"></a>Stage 11：Tier Assignment
输出：

REACH
MATCH
SAFE
WATCH

-----
## <a name="stage-12ai-explanation"></a>Stage 12：AI Explanation
AI 只读取结构化结果。

-----
# <a name="ai-输入结构"></a>41. AI 输入结构
AI 不允许直接读取：

用户586分
推荐学校

正确：

{
`  `"candidate": {
`    `"examYear": 2026,
`    `"score": 586,
`    `"rank": 8120,
`    `"planType": "NORMAL",
`    `"subjectTrack": "SCIENCE\_ENGINEERING"
`  `},
`  `"ruleContext": {
`    `"ruleSetVersion": "XJ-2026-V1"
`  `},
`  `"candidatePlans": [
`    `{
`      `"universityName": "...",
`      `"majorName": "...",
`      `"tier": "MATCH",
`      `"riskLevel": "MEDIUM",
`      `"historicalRanks": [],
`      `"comparabilityScore": 92
`    `}
`  `]
}

-----
# <a name="ai-禁止事项"></a>42. AI 禁止事项
AI 不得：

新增不存在的学校

不得：

新增数据库不存在的专业

不得：

修改冲稳保等级

不得：

声称用户具有专项资格

不得：

编造最低位次

不得：

自行计算官方录取概率

-----
# <a name="ai-输出职责"></a>43. AI 输出职责
AI 负责：

解释为什么推荐

解释主要风险

比较城市

比较专业

给出求学建议

给出志愿组合思路

但不能改变规则引擎结果。

-----
# <a name="规则引擎模型"></a>44. 规则引擎模型
定义：

BusinessRule

字段：

rule\_id

rule\_code

rule\_name

exam\_year

rule\_type

priority

condition\_expression

action\_expression

severity

source\_id

source\_reference

effective\_from
effective\_to

status

version

review\_status

-----
# <a name="ruletype"></a>45. RuleType
ELIGIBILITY
PLAN\_COMPATIBILITY
BATCH
SUBMISSION
SPECIAL\_PROGRAM
PROGRAM\_CONSTRAINT
SCORING
RECOMMENDATION
WARNING
DATA\_QUALITY

-----
# <a name="rulestatus"></a>46. RuleStatus
DRAFT
ACTIVE
INACTIVE
SUPERSEDED
CONFLICTED
REQUIRES\_REVIEW

-----
# <a name="示例规则普通类计划池"></a>47. 示例规则：普通类计划池
RULE CODE:
XJ-2026-PLAN-001

IF:
candidate.planType == NORMAL

THEN:
eligiblePlanTypes = [NORMAL]

STATUS:
ACTIVE

依据为 2026 官方规则中普通类考生填报计划范围。

-----
# <a name="示例规则单列类外语路径"></a>48. 示例规则：单列类外语路径
RULE CODE:
XJ-2026-PLAN-002

IF:
candidate.planType == SINGLE\_COLUMN
AND
candidate.examLanguagePath == FOREIGN\_LANGUAGE

THEN:
compatibilityPath = NORMAL\_THEN\_SINGLE

STATUS:
ACTIVE\_WITH\_REVIEW

依据包括 2026 报名规定的具体考试路径规则，以及招生工作规定中的兼报和投档顺序规则。

-----
# <a name="示例规则民族语文路径"></a>49. 示例规则：民族语文路径
RULE CODE:
XJ-2026-PLAN-003

IF:
candidate.planType == SINGLE\_COLUMN
AND
candidate.examLanguagePath == ETHNIC\_LANGUAGE

THEN:
compatibilityPath = SINGLE\_ONLY

STATUS:
REQUIRES\_POLICY\_RECONCILIATION

原因：

报名规定具有具体路径表述，但后续招生工作规定存在更概括表述，需上线前再次核验。

-----
# <a name="示例规则未知资格"></a>50. 示例规则：未知资格
RULE CODE:
XJ-COMMON-ELIGIBILITY-001

IF:
specialEligibility == UNKNOWN

THEN:
doNotIncludeInConfirmedSpecialRecommendation = true

addWarning:
ELIGIBILITY\_CONFIRMATION\_REQUIRED

-----
# <a name="示例规则2027-选科过滤"></a>51. 示例规则：2027 选科过滤
RULE CODE:
XJ-2027-SUBJECT-001

IF:
candidateSubjectCombination
DOES\_NOT\_SATISFY
majorSubjectRequirement

THEN:
excludePlanItem = true

2027 专业选考要求依据新疆官方发布的专业选考科目要求执行。

-----
# <a name="示例规则-dsl"></a>52. 示例规则 DSL
未来可以表达为：

ruleCode**:** XJ-2026-PLAN-002
name**:** 单列类外语路径兼报
year**:** 2026
type**:** PLAN\_COMPATIBILITY
priority**:** 100

when**:**
`  `all**:**
`    `**-** field**:** candidate.planType
`      `operator**:** EQ
`      `value**:** SINGLE\_COLUMN

`    `**-** field**:** candidate.examLanguagePath
`      `operator**:** EQ
`      `value**:** FOREIGN\_LANGUAGE

then**:**
`  `**-** action**:** SET\_COMPATIBILITY\_PATH
`    `value**:** NORMAL\_THEN\_SINGLE

source**:**
`  `sourceId**:** POLICY-2026-REGISTRATION

status**:** ACTIVE\_WITH\_REVIEW

-----
# <a name="policyconflict政策冲突表"></a>53. PolicyConflict：政策冲突表
定义：

PolicyConflict

字段：

conflict\_id

rule\_topic

source\_a\_id
source\_b\_id

description

detected\_at

resolution\_status

resolution

resolved\_by

resolved\_at

effective\_rule\_version

状态：

OPEN
UNDER\_REVIEW
RESOLVED
ACCEPTED\_RISK

-----
# <a name="推荐结果审计链"></a>54. 推荐结果审计链
每一次推荐必须保存：

recommendation\_run\_id

candidate\_profile\_version

eligibility\_profile\_version

exam\_year

rule\_set\_version

admission\_data\_version

history\_data\_version

algorithm\_version

prompt\_version

model\_provider

model\_name

created\_at

-----
# <a name="为什么必须保存版本"></a>55. 为什么必须保存版本
用户可能问：

为什么昨天推荐 A 大学，今天没有？

系统应能够回答：

招生计划数据更新

或者：

用户修改了专项资格

或者：

规则版本 XJ-2026-V2 生效

而不是：

AI 今天想法不一样。

-----
# <a name="recommendationrequesthash"></a>56. RecommendationRequestHash
免费三次机制需要：

request\_hash

Hash 输入建议：

examYear
score
rank
examRegime
planType
subjectTrack
eligibilityProfile
preferenceProfile
ruleSetVersion
dataVersion

用途：

- 防止重复扣次
- 结果缓存
- 幂等性
- 审计
-----
# <a name="业务错误码"></a>57. 业务错误码
建议预定义：

XJ\_RULE\_001
EXAM\_YEAR\_UNSUPPORTED

XJ\_RULE\_002
EXAM\_REGIME\_MISMATCH

XJ\_RULE\_003
PLAN\_TYPE\_UNKNOWN

XJ\_RULE\_004
SINGLE\_COLUMN\_PATH\_REQUIRED

XJ\_RULE\_005
SPECIAL\_ELIGIBILITY\_UNKNOWN

XJ\_RULE\_006
APPLICATION\_SCOPE\_UNKNOWN

XJ\_RULE\_007
NO\_ELIGIBLE\_PLAN

XJ\_RULE\_008
POLICY\_CONFLICT\_REVIEW\_REQUIRED

XJ\_RULE\_009
HISTORICAL\_DATA\_NOT\_COMPARABLE

XJ\_RULE\_010
SUBJECT\_REQUIREMENT\_NOT\_MET

-----
# <a name="warningcode"></a>58. WarningCode
警告不一定阻止推荐。

定义：

DATA\_INCOMPLETE

ELIGIBILITY\_UNVERIFIED

POLICY\_YEAR\_TRANSITION

LOW\_COMPARABILITY

ENROLLMENT\_QUOTA\_CHANGED

NEW\_MAJOR\_NO\_HISTORY

HIGH\_HISTORICAL\_VOLATILITY

SPECIAL\_REQUIREMENT\_REVIEW

-----
# <a name="前端表单动态规则"></a>59. 前端表单动态规则
前端不能固定展示所有字段。

-----
## <a name="普通类"></a>59.1 2026 普通类
显示：

年份
分数
位次
文史/理工
计划类型

-----
## <a name="单列类"></a>59.2 2026 单列类
增加：

考试科目路径

○ 外语
○ 民族语文
○ 不确定

-----
## <a name="section"></a>59.3 2027
不再展示：

文史/理工

改为：

首选科目

○ 物理
○ 历史

再选科目
□ 政治
□ 地理
□ 化学
□ 生物

-----
# <a name="p0-支持范围"></a>60. P0 支持范围
为了个人开发者可控，MVP 第一阶段建议正式支持：

新疆普通高考

2026

普通类
单列类

文史类
理工类

本科一批
本科二批
高职普通批次

基础专项资格模型

冲稳保推荐

-----
# <a name="p0-暂不做完整自动推荐的类别"></a>61. P0 暂不做完整自动推荐的类别
建议暂时：

只查询
\+
风险提示

而不是全自动冲稳保：

- 艺术类
- 体育类
- 军队
- 公安
- 消防
- 定向培养军士
- 高水平运动队
- 极复杂定向项目

原因：

这些类别存在独立专业成绩、体检、政审、面试、协议或特殊投档条件。2026 官方规定确认多类项目具有额外要求。

-----
# <a name="p1-支持范围"></a>62. P1 支持范围
增加：

国家专项
地方专项
南疆单列
对口援疆

本科提前批普通特殊类型

艺术类
体育类

-----
# <a name="p2-支持范围"></a>63. P2 支持范围
增加：

2027 3+1+2

专业选科硬过滤

跨制度历史归一化

新高考冷启动模型

但数据库架构必须从第一版预留。

-----
# <a name="自动化测试要求"></a>64. 自动化测试要求
任何规则必须拥有测试。

-----
## <a name="test-001"></a>Test 001
输入：

2026
普通类
理工

预期：

普通类候选池

-----
## <a name="test-002"></a>Test 002
输入：

2026
单列类
外语路径

预期：

NORMAL\_THEN\_SINGLE

并记录：

rule version

-----
## <a name="test-003"></a>Test 003
输入：

2026
单列类
民族语文路径

预期：

SINGLE\_ONLY
\+
POLICY REVIEW METADATA

-----
## <a name="test-004"></a>Test 004
输入：

国家专项资格 UNKNOWN

预期：

不得作为已确认专项资格推荐

-----
## <a name="test-005"></a>Test 005
输入：

2027
首选历史

专业要求：

必须物理

预期：

硬过滤

-----
## <a name="test-006"></a>Test 006
输入：

2027物理组用户

历史数据：

2026理工类

预期：

禁止直接位次差计算

-----
## <a name="test-007"></a>Test 007
输入：

报考范围仅区内本科

候选：

区外本科

预期：

硬过滤

-----
## <a name="test-008"></a>Test 008
输入：

专项资格 VERIFIED\_INELIGIBLE

候选：

专项计划

预期：

硬过滤

-----
## <a name="test-009"></a>Test 009
输入：

历史数据来源 CONFLICTED

预期：

不得进入高置信推荐

-----
## <a name="test-010"></a>Test 010
输入：

同样请求
同 ruleSetVersion
同 dataVersion
短时间重复提交

预期：

复用结果
不重复扣免费次数

-----
# <a name="codex-实现边界"></a>65. Codex 实现边界
未来 Codex 只能：

按照本文件实现规则

不能：

自行理解新疆政策

不能：

觉得某个枚举更简单就合并

不能：

把 PlanType 和 SubjectTrack 合并

不能：

把专项资格设计成 boolean

不能：

把2027继续设计成文史/理工

-----
# <a name="codex-发现问题时的处理方式"></a>66. Codex 发现问题时的处理方式
Codex 必须：

停止修改规则
↓
生成 Conflict Report
↓
说明冲突文件
↓
等待上游文档修订

禁止自行选择。

-----
# <a name="最终业务模型总图"></a>67. 最终业务模型总图
Candidate
`    `│
`    `▼
CandidateExamProfile
`    `│
`    `├── ExamYear
`    `├── ExamRegime
`    `├── PlanType
`    `├── SubjectTrack
`    `├── SubjectCombination
`    `└── ExamLanguagePath
`    `│
`    `▼
CandidateEligibilityProfile
`    `│
`    `├── ApplicationScope
`    `├── NationalSpecial
`    `├── LocalSpecial
`    `├── SouthXinjiang
`    `├── CounterpartAssistance
`    `└── Other
`    `│
`    `▼
Annual Rule Set
`    `│
`    `├── Eligibility Rules
`    `├── Compatibility Rules
`    `├── Batch Rules
`    `├── Submission Rules
`    `└── Program Constraints
`    `│
`    `▼
AdmissionPlan
`    `│
`    `▼
AdmissionPlanItem
`    `│
`    `├── University
`    `├── Major
`    `├── Batch
`    `├── PlanType
`    `├── Quota
`    `└── Constraints
`    `│
`    `▼
Hard Filter
`    `│
`    `▼
Historical Comparability
`    `│
`    `▼
Risk Scoring
`    `│
`    `▼
Preference Ranking
`    `│
`    `▼
REACH / MATCH / SAFE / WATCH
`    `│
`    `▼
AI Explanation

-----
# <a name="最终原则"></a>68. 最终原则
本系统不是：

输入分数
↓
搜索学校
↓
AI推荐

而是：

考试年度
↓
年度考试制度
↓
考生考试画像
↓
考生资格画像
↓
官方报考范围
↓
计划类型兼容性
↓
批次规则
↓
专项规则
↓
招生计划项
↓
专业硬限制
↓
历史数据可比性
↓
风险模型
↓
用户偏好
↓
冲稳保
↓
AI解释

任何绕过以上核心链路的推荐结果：

不得视为正式志愿推荐结果

-----
# <a name="v1.0-架构冻结决策"></a>69. V1.0 架构冻结决策
从本版本开始，以下原则进入架构基线：

1. 考试规则按年度版本化。
1. 2026 与 2027 使用不同考试制度模型。
1. PlanType 与 SubjectTrack 分离。
1. 单列类考试语言路径独立建模。
1. 专项资格采用多态状态，不使用 boolean。
1. 可报地域和院校层次范围独立建模。
1. 推荐单位采用 AdmissionPlanItem。
1. 硬规则先于推荐评分。
1. AI 无权突破硬规则。
1. 跨考试制度历史位次不得直接比较。
1. 所有规则必须保存来源。
1. 政策冲突必须显式记录。
1. 所有推荐结果必须保存版本链。
1. 冲稳保不等于伪精确录取概率。
1. 特殊类别分阶段支持，不在 MVP 中盲目全自动化。
