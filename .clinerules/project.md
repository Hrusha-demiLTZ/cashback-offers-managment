# Project Instructions for Cline

## 1. Source of truth and task workflow

- Before changing files, inspect the relevant existing files and read the project documents that apply:
  - `02_ТЗ_кэшбэк-офферы_MVP_MVPplus.md` — functional requirements and business rules.
  - `03_Решение_кейса_технический_план.md` — recommended technical solution and accepted caveats.
  - `04_Базовый_шаблон_банковский_хакатон.md` — starter templates and security guidance.
  - `05_План_конкретных_задач_реализации.md` — ordered implementation backlog and acceptance checks.
  - `01_Рассуждения_по_кейсу.md` and `TTask.md` — supporting context; prefer the detailed TЗ if a business-rule conflict exists.
- Treat the detailed TЗ as the primary source for defined business behavior. Treat technical-plan choices as recommendations unless explicitly confirmed. Do not silently resolve contradictions or open business questions.
- Work on the requested backlog item or a small, explicitly scoped group of adjacent items. Do not implement the whole backlog in one task.
- Before editing, state a concise plan and identify files/areas expected to change. If a key business, security, data, or environment decision is missing, ask one focused question or present a clearly labeled safe proposal before implementing dependent behavior.
- Do not claim a command, test, build, migration, deployment, or review succeeded unless it was actually run and its result inspected.
- At completion, summarize changed files, behavior, validation commands/results, and unresolved risks or follow-up items.

## 2. Scope and architecture

- This repository starts as a document-only case; create application code only when the user requests implementation of a backlog task.
- Target a modular monolith: Python/FastAPI backend, React/TypeScript frontend, PostgreSQL, OpenAPI, Docker Compose. Use the versions and dependency choices already established in project files; if none exist, verify current compatibility and pin versions/lockfiles rather than guessing that a version works.
- Python 3.14.7, Node 26.7.0, and Docker 29.8.2 were observed on the original workstation. They are not guaranteed to be available elsewhere. Verify supported runtimes in CI and keep local, CI, and container versions aligned.
- PostgreSQL is the source of truth for business state. Use Alembic migrations for schema changes. Do not connect to, modify, or reuse an unrelated/system PostgreSQL database. Local development must use the project's isolated Compose database, database/user, port, and volume.
- Do not add Redis, a message broker, Kubernetes, microservices, or new infrastructure without a concrete requirement, a concise rationale, and user approval.
- Keep frontend and backend contracts in OpenAPI. Generate frontend API types/client from the contract; do not maintain competing hand-written copies of generated models.
- Keep business rules and authorization on the backend. Frontend validation is for usability only and never replaces server validation.

## 3. Banking-demo safety boundaries

- Use synthetic data only. Never import or invent real customer records, account/card data, PAN/CVV, bank exports, production identifiers, or production secrets.
- Do not connect to real banking, payment, card-processing, accounting, identity, or customer-data systems unless the user explicitly requests a separately reviewed integration plan.
- Clearly label purchases, balances, cashback, and customers as demonstration/synthetic. The prototype must not imply that a real financial posting or payment occurred.
- Never put credentials, tokens, private keys, certificates, or populated `.env` files into source control, logs, Docker images, screenshots, or documentation. Do not weaken `.gitignore` to expose them.
- Do not log passwords, JWTs, secrets, or sensitive request payloads. Use parameterized database access and validate untrusted input.
- Enforce authentication and role authorization on every protected backend operation. Never trust a role supplied by the browser. Return safe errors without exposing secrets or internal traces.
- Keep Swagger/OpenAPI available as required, but respect environment access controls; documentation exposure must not bypass API authorization.
- Avoid destructive database or Docker commands. Before any reset/drop/volume removal, verify it targets only this project's isolated local/test resources and clearly warn about data loss.

## 4. Domain rules to preserve

- Preserve the TЗ lifecycle: draft, review, partially approved, returned for changes, rejected, approved, ready to launch. Approval and offer status are distinct concepts.
- Three approval roles review independently: product, analytics, and operations. Decisions require comments and refer to an immutable submitted offer version.
- Editing a later draft must not mutate a version already under review. Preserve previous versions, decisions, comments, and audit events.
- Detect changed fields with a diff and route checks using an explicitly agreed field-to-responsibility matrix. A diff alone cannot decide business impact. The responsible reviewer records impact; cross-zone or uncertain impact requires full review.
- Only a fully approved, non-expired offer that operations marked ready may be placed in a showcase period.
- Showcase conflict means overlapping offer-validity periods AND at least one shared MCC. Do not silently equate a duplicate offer with this business conflict; apply only an explicitly agreed duplicate policy.
- Show up to seven enhanced offers and the required separate “1% on everything” category. Never fabricate empty offer cards.
- A client has one current selection per category and showcase period; selection changes are historized and past purchases are not recalculated. Repeated activation is idempotent.
- For a test purchase, apply at most one enhanced offer. Do not add base 1% to an enhanced payout on the same purchase. Apply base 1% according to the TЗ when the purchase is not covered by an enhanced offer.
- Respect the overall offer budget. Partial enhanced payouts are capped by the remaining budget; retries must not spend the budget twice.
- MVP+ reservations must be transactional and idempotent: reserve, confirm, release on pre-confirmation cancellation, and route uncertain reservations to reconciliation rather than silently freeing them on a timer.
- Use exact decimal money types, never binary floating point. Currency is RUB and display timezone is Europe/Moscow. Do not invent an unresolved rounding rule or minimum payout; record it as an open decision and ask/offer a proposal.

## 5. Code and dependency practices

- Follow conventions and dependencies already established in the repository. Do not add a library when standard-library or existing project functionality is sufficient.
- Keep changes minimal and scoped. Do not perform unrelated refactors, rename files, rewrite documents, or alter architecture as part of an implementation task.
- Add/adjust tests for changed behavior, especially authorization, state transitions, money/budget rules, idempotency, and persistence constraints.
- Use migrations for schema changes; do not rely on manual database edits or startup-time schema mutation.
- Keep lockfiles in version control. Use locked installs in CI (`uv sync --frozen`, `npm ci`, or the project's adopted equivalent).
- Never use `latest` image tags. Keep the PostgreSQL service, application configuration, and test database isolated and reproducible.
- Treat generated API clients and other generated files as generated; update them with their generator rather than editing generated output manually.

## 6. Validation and completion

- Run the narrowest relevant tests during development, then run the full available checks for affected components before completion.
- For backend changes, run applicable Ruff checks/format check, type checking, unit tests, and PostgreSQL integration tests. For frontend changes, run ESLint, formatting check, TypeScript check, unit tests, and build. Run E2E tests for changed user journeys when the environment supports them.
- For database changes, verify a clean database can be created through migrations and that existing project data is not involved.
- For API changes, verify OpenAPI output and generated client consistency.
- For security-sensitive changes, test denied access as well as the successful role path.
- Report skipped checks and why they could not run. Do not substitute a static inspection for a test run without saying so.
- Do not mark backlog checkboxes complete unless the stated result and validation have been verified.

## 7. Agent-role workflow

- Do not create an in-product multi-agent framework or a custom agent orchestration service for this prototype.
- Use role separation as a lightweight work method: analyst (requirements/acceptance criteria), implementer (one scoped change), reviewer (independent check against TЗ/security/tests), and operator (reproducible run/deploy checklist).
- Keep context in the existing project documents and concise ADRs/backlog updates; do not create a separate “context keeper” agent that duplicates them.
- A review pass must be independent of implementation when practical, but may be a separate Cline pass/person rather than a persistent autonomous agent.
- Deployment must remain an explicit, authorized pipeline/checklist action. Do not grant an agent autonomous access to production, banking credentials, or destructive infrastructure operations.
- Consider Cline subagents/agent teams only if the installed Cline version supports them and independent tasks have clear file boundaries, stable contracts, and a measurable speed/quality benefit. Human review remains required.