# Engineering Onboarding — Pursuit Pilot Platform

Welcome to the team. This is your guided tour of the Pursuit "Pilot" platform — an AI-native learning
and career-development system for **builders** (learners). Read it top to bottom on day one; after that
it's a reference.

> **How to use this with Claude Code:** open the workspace in Claude Code and ask questions as you go —
> "walk me through the V2 Coach graph", "where is login handled?", "show me how permissions work".
> The pointers below are written so the assistant can jump straight to the right file.

---

## 1. What we're building

Pursuit runs a program that takes people from application → admissions → a multi-level curriculum →
assessments → job placement. The platform is the software layer around that whole journey. The
distinctive part is a heavy **AI coaching engine**: an LLM-driven agent ("V2 Coach") that teaches,
sets tasks, grades submissions, and adapts to each builder.

**User types you'll see everywhere:** `builder` (learner), `staff`, `admin`, `applicant`,
`volunteer`, plus workshop/enterprise variants. Almost everything is gated by **role + permission**.

Key vocabulary:
- **Builder** — a learner. (The `users` table uses `first_name`/`last_name`, never `full_name`.)
- **Cohort** — a group of builders progressing together; cohorts have **levels** (L1, L2, L3+).
- **V2 Coach** — the LangGraph AI agent that runs the learning experience.
- **Skill taxonomy** — a flat 45-skill model, scored per-builder on a Dreyfus 0–5 scale.
- **Admissions v2** — the applicant → cohort enrollment pipeline.

---

## 2. The system at a glance

After setup, one repository (`Pursuit-Org/platform`) lives in `~/Documents/pursuit-platform/`, with two package roots:

| Package root | What it is | Stack | Port |
|------|-----------|-------|------|
| **`server/`** | Backend API + AI engine | Node/Express, PostgreSQL (pg-promise + pgvector), LangGraph | **7001** |
| **`client/`** | Web frontend (SPA) | React 19, Vite, Tailwind + shadcn/ui, Zustand, React Query | **5173** |

Plus a **ready-to-use tool** (nothing to clone or run — see §4):

| Tool | What it gives you | How you access it |
|------|-------------------|-------------------|
| **Pursuit DB Connector** | Read-only query access to prod Postgres + a BigQuery analytics dataset | An MCP connector already available in **Claude Code** and **Claude Cowork** |

```
                    ┌─────────────────┐
   Browser  ──────► │  client/        │  React SPA (Vite)
                    │  :5173          │
                    └────────┬────────┘
                             │  REST + SSE (Authorization: Bearer <JWT>)
                             ▼
                    ┌─────────────────┐        ┌──────────────────────┐
                    │ server/  :7001  │───────►│  PostgreSQL          │
                    │                 │        │  (segundo-db,        │
                    │  Express + AI   │        │   pgvector, 60+ tbls)│
                    └───┬─────────┬───┘        └──────────┬───────────┘
                        │         │                       │
                        ▼         ▼                       │ read-only
                  OpenRouter   BigQuery /          ┌──────────────────────┐
                  Anthropic    S3 / Slack /        │  Pursuit DB Connector│◄── Claude Code /
                  OpenAI       DocuSign …          │  (read-only MCP tool)│    Claude Cowork
                                                   └──────────────────────┘
```

- Frontend → backend: base URL from `VITE_API_URL` (default `http://localhost:7001`). Two patterns —
  plain REST (`fetch`/`axios` + JSON) and **SSE streaming** for AI chat (`utils/api.js`).
- Backend → LLMs: **OpenRouter is primary**; Anthropic SDK is used for the tool-use chat path;
  OpenAI as needed. Every call is logged to `llm_usage_logs`.
- The **DB Connector** is not in the request path — it's a governed, read-only window into the same
  Postgres + a BigQuery analytics dataset, surfaced to you as a tool inside Claude Code / Cowork.

---

## 3. Day 1: get it running

The **setup wizard** installs tooling (Homebrew, Node, Git, gh, Cursor, Claude Code), grants you
access to both repos, forks + clones them into `~/Documents/pursuit-platform/`, decrypts env
secrets, runs `npm install`, and starts both servers.

**Ask your onboarding buddy (Carlos) for `setup.sh` + `env.secrets.gpg` and the passphrase**, save
both files in one folder, then run the command from the
[New Engineer Onboarding Checklist](./new-engineer-onboarding.md)
(`bash setup.sh --passphrase "..."`). After first setup, `pursuit-sync` pulls latest `dev` for
the repository.

If you'd rather set up manually:

```bash
# Backend
cd server
cp .env.example .env          # then fill in real values from the team secrets bundle
npm install
npx nodemon server.js         # → http://localhost:7001

# Frontend (new terminal)
cd client
cp .env.example .env          # set VITE_API_URL=http://localhost:7001
npm install
npm run dev                   # → http://localhost:5173
```

- **Node 20 / npm 10.9.0** (matches Netlify; there's an `.nvmrc` in `client/`).
- You do **not** run Postgres locally — everyone shares a hosted dev database. Env vars point you at it.
- **`PG_SSL` behavior:** `db/dbConfig.js` only enables SSL when `PG_SSL=true` is set.
- BigQuery self-disables locally if `db/bq-config/key.json` is missing — that's fine.
- Cron jobs (emails, demo seeding, lead import) are gated behind `ENABLE_*` flags and default **off**
  locally, so you won't accidentally email anyone. Leave them off unless you know why you're turning
  one on.

---

## 4. Codebase map

### Backend — `server/`
The real composition root is **`app.js`** (not `server.js`). `server.js` boots the listener and starts
cron jobs, then requires `app.js`, which imports ~80 controllers and mounts most routes **inline**
(`app.post('/api/...', authenticateToken, controller.method)`).

Request flow:
```
route (app.js) → authenticateToken / requirePermission → controller (validates input)
              → queries/ (pg-promise SQL)  or  services/ (AI, email, Slack, GCS…) → JSON or SSE
```

| Dir | Role |
|-----|------|
| `controllers/` (~82) | Request handlers / business logic, one per feature area |
| `queries/` (~77) | **All** SQL, via pg-promise, parameterized — the data-access layer |
| `services/` (~58) | AI client, email, Slack, GCS, BigQuery, scraping, eval/reflection |
| `graphs/coachV2/` | The LangGraph V2 Coach agent (see below) — `coachV2-architecture.md` is authoritative |
| `middleware/` | `authenticateToken`, `requirePermission`, uploads, Slack sig verify, status gates |
| `auth/` | JWT generation + verification (`auth/auth.js`) |
| `db/` | `dbConfig.js` (pg-promise pool), `redisConfig.js`, seeds, bq-config |
| `utils/` | `aiClient.js`, `promptManager.js`, `skillTaxonomy.js`, `completionRules.js`, `cohortLevel.js` |
| `migrations/`, `db/migrations/` | SQL migrations; full schema also in `database-schema.sql` |
| `__tests__/` | Jest suites (controllers, queries, services, graphs, integration, golden) |

**Start here:** `CLAUDE.md`, `app-context.md` (13-area feature/file map), `data-dictionary.md` +
`database-schema.sql` (the 60+ table schema).

### The V2 Coach (the heart of the platform)
`graphs/coachV2/` is a LangGraph state machine. Node flow:
```
init → learn → generateApply → apply → grade → remediate → complete → reflect
```
- State is **checkpointed in Postgres** (`@langchain/langgraph-checkpoint-postgres`).
- Every node execution is logged to `agent_run_steps` via fire-and-forget `stepLogger.js` — this feeds
  the staff-facing **Coach Runs** observability UI.
- **Production prompts are DB-backed**, not files: `content_generation_prompts`, `coach_v2_config`,
  `program_contexts`, `skill_taxonomy`. They're loaded into `promptManager` at startup, editable by
  admins with audit + revert history. Missing rows throw loudly — there is no file fallback.
  (The `prompts/` directory is largely legacy/test material — don't assume it drives production.)
- Quality tooling: an LLM-judge **eval** harness (`graphs/coachV2/eval/`) and a **Golden Dataset** of
  synthetic builder archetypes (`graphs/coachV2/golden/`). See `PROMPT_TESTING_GUIDE.md`.

### Frontend — `client/`
- `main.jsx` wires React Query + Router; **`App.jsx`** holds all routes and role guards.
- `pages/` — ~65 route-level features (Dashboard, Learning/AI chat, Admin Dashboard, Admissions,
  Coach admin suite, Pathfinder/Sputnik employment engine, Onboarding, applicant flow).
- `components/` — shared components; `components/ui/` is 33 shadcn/Radix primitives.
- `services/` + `utils/api.js` — the API layer, including **SSE streaming** for AI chat.
- `stores/` — Zustand: `authStore.js`, `navStore.js`. **There are no React Context providers.**
- `hooks/usePermissions` — `hasPermission` / `canAccessPage` / `canUseFeature`; admin = wildcard `*`.

Pages worth touring early: **Dashboard** (`/dashboard`), **Learning / v2 Coach** (`/learning`,
`/ai-chat`), **Admin Dashboard** (`/admin-dashboard`, see `admin-dash-prd.md`), **Coach admin suite**
(`/admin/coach` — Runs, Evals, Golden Dataset), **Admissions** (`/admissions-dashboard`).

### Tool — Pursuit DB Connector
A **ready-to-use MCP tool**, already available in **Claude Code** and **Claude Cowork** — there's
nothing to clone, install, or run. Just ask Claude to query the data and it'll call the tool for you.

It exposes:
- `pg_query` / `pg_list_tables` / `pg_describe_table` — the production Postgres (`segundo-db`)
- `bq_query` / `bq_list_tables` / `bq_describe_table` — the BigQuery analytics dataset

Everything is **read-only by design and enforced server-side**: SELECT/`WITH` only, single statement,
forbidden-keyword blocklist, and an auto-applied row `LIMIT`. So it's safe to explore prod data freely —
you cannot mutate anything through it. This is the right way to answer "what does the data look like?"
questions instead of running ad-hoc SQL against prod yourself.

> If it's not showing up for you, ask Carlos to confirm you're added to the connector in Claude
> Teams/Cowork.

---

## 5. How we work

The workspace uses **Kiro-style spec-driven development** on top of AI-DLC. For non-trivial features
the flow is: **Requirements → Design → Tasks → Implementation**, each with human review. Slash
commands (in Claude Code):
- `/kiro:spec-init "description"` → `/kiro:spec-requirements` → `/kiro:spec-design` → `/kiro:spec-tasks`
  → `/kiro:spec-impl`
- `/kiro:spec-status {feature}` any time to check progress. Specs live in `.kiro/specs/`; project-wide
  rules ("steering") live in `.kiro/steering/`.

**Git & branching:**
- Both repos default to the **`dev`** branch. Keep `dev` clean.
- Feature work happens in **worktrees** inside your workspace directory. Confirm a worktree's branch
  is current with `dev` before building on it.
- **Commit before removing a worktree.** Don't lose work.
- Open PRs against `dev`. CI (`.github/workflows/ci.yml`) runs tests; there's also automated Claude PR
  review, so keep `CLAUDE.md` files current — the reviewer reads them.

---

## 6. Conventions & gotchas (read these — they cause the most bugs)

**Backend**
- **pg-promise only.** Use `db.any()/one()/oneOrNone()/none()` from `db/dbConfig` — never `db.query()`.
- **Parameterized queries only** — no string interpolation into SQL. CSV exports must use
  `escapeCsvValue()` (formula-injection) and cap at `LIMIT 50000`.
- `users` has `first_name`/`last_name`, **not** `full_name`.
- **Fire-and-forget side effects** (step logging, usage logging, reflection, email confirmations, the
  `user_task_progress` completion cache) are wrapped in try/catch so they never break the parent
  request. Watch for log tags like `[utp-refresh]`, `[auth]`.
- **Task completion source of truth:** `user_task_progress.status='completed'`, written server-side;
  rule centralized in `utils/completionRules.js#evaluateCompletion`. The client's
  `POST /api/learning/complete-task` is now a **no-op safety net**.
- **L3+ enrollment-date gating:** rolling joiners in L3+ cohorts only see curriculum on/after their
  `enrolled_date` (founders exempt). Logic in `utils/cohortLevel.js`.
- **Admissions v2:** `application.cohort_id` is the permanent source of truth; automatic cohort rollover
  was removed. `current_stage` is lifetime-monotonic (never moves backward). Use applicant-driven
  signals for "activity recency", **never `.updated_at`**.
- Tool-use chat requires the **Anthropic-direct path** (`ANTHROPIC_API_KEY`); the OpenRouter fallback
  silently drops tools. Tools force `user_id` from the JWT to prevent IDOR.

**Frontend**
- **No emojis in the UI** (explicit product rule; see `admin-dash-prd.md`).
- Use **Zustand selector hooks** directly (`useAuthStore((s) => s.user)`) — no providers to wrap.
- **Never read `localStorage.getItem('token')` directly** — go through `authStore`.
- React Query owns server state (~30s stale/poll); don't hand-roll caching for it.
- **`admin-dash-prd.md` is a living contract** — if a request contradicts it, confirm before building.
- Some components are **parked but kept on disk** (e.g. `FeedbackInbox.jsx`, `CoachProfiles`) —
  don't re-import them without product sign-off.

**Stale docs to distrust** (current truth lives in the `CLAUDE.md` files):
- Both repos' `README.md` are outdated (wrong ports/vars — client says 3000/`npm start`; real is 5173/
  `npm run dev`).
- `joannahandoff.md` (2026-03) predates the Zustand migration; its `useAuth()`/AuthContext frontend
  details are historical.

---

## 7. Security & secrets

- Secrets are distributed only through the encrypted onboarding bundle (decrypted by the setup
  wizard). **Never commit a real `.env`**, and never paste secrets into Gists, PRs, or chats.
- Production DB secrets live in **Google Cloud Secret Manager**; don't rotate shared secrets
  casually — several services (including the DB Connector) depend on specific versions.
- Never run `INSERT/UPDATE/DELETE/DROP` against prod to "test" something — use the read-only tooling.

---

## 8. Testing

| Repo | Tooling | Run |
|------|---------|-----|
| Backend | Jest + supertest | `npm test`, `npm run test:watch`, `npm run test:coverage` |
| Frontend | Vitest + Testing Library | `npm test`, `npm run test:ui`, `npm run test:coverage` |
| Frontend E2E | Playwright | `npx playwright test` (auto-starts the dev server) |
| Frontend mutation | Stryker | `npx stryker run` (currently scoped to a couple of files) |

- Tests are co-located in `__tests__/` dirs.
- **Zustand test convention:** don't wrap in providers — set state via `useAuthStore.setState(...)` in
  `beforeEach`, reset with `getInitialState()` in `afterEach`.

---

## 9. Deployment

- **Frontend** → Netlify (`netlify.toml`): publishes `dist/`; Node 20; build bumps
  `--max-old-space-size=4096` (Vite OOMs on Netlify's container otherwise).
- **Backend** → Render. Postgres is GCP Cloud SQL (`segundo-db`); BigQuery for analytics.
- Deploys flow from the `dev` branch through PR + review. Ask before pushing/deploying anything.

---

## 10. First-week checklist

- [ ] Run the setup wizard (get the passphrase from Carlos); confirm both servers boot.
- [ ] Log in locally as a test user and click through Dashboard → Learning → Admin Dashboard.
- [ ] Read `server/CLAUDE.md`, `server/app-context.md`, and `server/graphs/coachV2-architecture.md`.
- [ ] Read `client/CLAUDE.md` and `client/admin-dash-prd.md`.
- [ ] Trace one request end-to-end: click something in the UI → find the `services/` call →
      the `app.js` route → the controller → the query.
- [ ] Skim `database-schema.sql` / `data-dictionary.md` for the `users`, `cohorts`, `applications`,
      `user_task_progress`, `builder_profiles`, and `agent_run_steps` tables.
- [ ] Do a small first ticket in a worktree, run tests, open a PR against `dev`.

## Where to get help
- **Codebase questions:** ask Claude Code inside the repo — the `CLAUDE.md` / `app-context.md` files
  are written for it.
- **Docs:** this documentation repo — see the
  [New Engineer Onboarding Checklist](./new-engineer-onboarding.md) for the full index.
- **People:** Carlos (platform lead / your onboarding buddy).

Welcome aboard.
