# backend-architecture

- **Category:** Coding
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Implement Java backend changes inside the frozen modular-monolith architecture without boundary erosion or stack drift.

## When to use

Use for backend modules, services, application flows, adapters, module events, transactions, caching, or package structure.

## Inputs

Backend task; target module; API/domain contract; transaction requirements; affected persistence models.

## Required upstream documents

- `docs/03-system-architecture.md`
- `docs/04-database-design.md`
- `docs/05-api-contract.md`
- `docs/00-decision-register.md`

## Frozen constraints

Java 21; Spring Boot 4.1.x baseline; Spring Modulith 2.1.x baseline; MyBatis-Plus plus handwritten/XML complex SQL; MySQL 8.4 LTS; Flyway; Redis-compatible only cache/temporary; Modular Monolith; no P0 microservices/Kafka/RabbitMQ/Kubernetes.

Cross-cutting constraints that always apply when relevant:

- Respect every `FROZEN` / `FROZEN FOR P0` / `FROZEN FOR STEP 9` decision in `00-decision-register.md`.
- Keep every Open Decision open unless the human explicitly approves closure.
- `docs/` is SSOT; implementation must not silently redefine product, rules, architecture, database, API, IA, or UI semantics.
- User and Candidate remain separate.
- ExamProfile, EligibilityProfile, and PreferenceProfile remain versioned.
- Eligibility is never reduced to Boolean.
- Recommendation truth unit remains `AdmissionPlanItem`.
- Successful `RecommendationRun` keeps immutable audit semantics and frozen version references.
- Recommendation creation uses `idempotency_key + request_hash`; replay must not double-charge quota.
- Quota uses `QuotaAccount + QuotaLedger`; Membership, Entitlement, and Quota are not collapsed into `user.vip`.
- Payment success is server-confirmed fact, never client assertion.
- User API and Admin API remain separated.
- AI may explain structured facts but may not override Hard Rules.
- No uncalibrated precise admission probability.
- Recommendation Tier (`REACH/MATCH/SAFE/WATCH`) and Risk remain separate concepts.
- Preserve `zh-CN`, `ug-CN`, and RTL behavior.

## Procedure

1. Identify owning backend module and incoming/outgoing boundaries.
2. Load relevant domain skill before coding business semantics.
3. Keep controllers thin and contract-aligned; application service orchestrates use case.
4. Place business invariants in domain/application logic, not client or cache.
5. Use repository/persistence adapters consistent with DB design.
6. Define transaction boundary explicitly for quota/payment/recommendation mutations.
7. Use module events only where architecture allows decoupling; do not invent distributed infrastructure.
8. Add tests at rule/module/integration/contract level as applicable.

## Output contract

Compilable backend change with module ownership, contract trace, migration impact statement, tests, and no unrelated refactor.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] Module dependency direction remains valid.
- [ ] No direct cross-module table coupling introduced casually.
- [ ] Cache is not correctness source.
- [ ] Transactions protect invariant changes.
- [ ] API response/error semantics match contract.
- [ ] Java version and chosen libraries match frozen stack.

## Forbidden actions

- Creating microservices.
- Introducing message brokers for P0.
- Using Python for online recommendation.
- Making Redis source of truth.
- Adding arbitrary script execution from DB.

## Escalation / Conflict handling

If required behavior crosses module boundaries not defined in architecture, report boundary conflict; do not create a new module topology silently.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
