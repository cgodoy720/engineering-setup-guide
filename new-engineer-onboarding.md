# New Engineer Onboarding Checklist

> **📋 Fill it out here:** [New Engineer Onboarding Checklist (Google Doc)](https://docs.google.com/document/d/1Nbnn8U9bAnBsAd0vk-L6fjmB38J33rWaFSPNXcNY3Dk/edit)
> — make a copy per hire and complete it there. This file is the source template.

Tracks everything a new engineer needs — access, setup, and documentation — so nothing is
missed and the manager has a record of what was granted. Make a copy per hire and check
items off as they're completed. Carlos grants everything unless noted otherwise.

**Engineer:** ______________ · **Start date:** ______________ · **Onboarding owner:** Carlos Godoy

---

## 1. Before they start

- [ ] Google Workspace account — @pursuit.org email *(IT / Ops)*
- [ ] Slack workspace + engineering channels
- [ ] Claude seat (Teams / Cowork) — used for Claude Code and platform work
- [ ] Pursuit DB Connector enabled on their Claude account — read-only Postgres + BigQuery
- [ ] Platform staff account — log into the app itself as staff
- [ ] Engineer has a GitHub account (any personal account works — the wizard grants code-repo access)
- [ ] Invited as **collaborator on the private `platform-onboarding` repo** (Settings → Collaborators)
- [ ] Onboarding passphrase shared — verbally / 1:1, never in the same channel as repo access

## 2. Machine setup (day one, self-serve)

Send them this message once they've accepted the repo invite:

```
1. Accept my GitHub invite to platform-onboarding (check your email/github notifications)
2. Open Terminal (Cmd+Space, type "Terminal", hit Enter)
3. Paste this and hit Enter:
   git clone https://github.com/cgodoy720/platform-onboarding.git ~/pursuit-onboarding && cd ~/pursuit-onboarding && bash setup.sh --passphrase "THE_PASSPHRASE"
4. Follow the prompts. That's it.
   (If git asks you to log in, use your GitHub username + a personal access token —
    or skip git: on the repo page click Code → Download ZIP, unzip, and run
    "bash setup.sh --passphrase ..." from inside that folder.)
```

The wizard does the rest automatically: installs all tooling, signs them into GitHub, **adds
them as a collaborator on both repos and accepts the invites**, forks + clones into
`~/Documents/pursuit-platform/`, writes env config, installs dependencies, and verifies both
servers boot. If anything fails, ping Carlos (the `platform-onboarding` repo is private, so
its troubleshooting README isn't visible to new hires).

**Verify:**

- [ ] Wizard completed without errors
- [ ] Collaborator access on `Pursuit-Org/platform`
      (granted by the wizard — spot-check under the repo's Settings → Collaborators)
- [ ] Backend responds on `http://localhost:7001`
- [ ] Frontend responds on `http://localhost:5173`
- [ ] Can log into the app locally with their staff account
- [ ] Claude Code opens and answers a question about the codebase

## 3. Access to grant later — when their work requires it

- [ ] Netlify — frontend deploys
- [ ] Render — backend deploys
- [ ] GCP project — Cloud SQL, BigQuery, Cloud Run
- [ ] Figma — design files
- [ ] Integration accounts — DocuSign, HubSpot, Bill.com, LiveKit — only if working on that integration

---

## 4. Documentation to give them

All platform documentation, in reading order:

### Start here

- **[Engineer Onboarding Guide](./engineer-onboarding-guide.md)** — the full tour: what we're
  building, architecture, codebase map, conventions, gotchas, first-week checklist. Read first.
- **[README](./README.md)** — engineering best practices & setup reference.
- **[Tech Stack & Architecture](./tech-stack-diagram.md)** — stack summary + architecture and
  user-journey diagrams; database ERD in [images/database-erd.md](./images/database-erd.md).

### System deep-dives — Platform Visuals

The **[deployed Platform Visuals app](https://platform-visuals-igpmdh52e-joinpursuit.vercel.app/)**
is the living system documentation: one entry per platform system, each with a rendered visual
guide and an `agent.md` reference. Source lives in
[Pursuit-Org/platform-visuals](https://github.com/Pursuit-Org/platform-visuals) and is
kept current automatically when code merges to main. Systems covered: admissions ·
admin-management · assessment-performance · attendance · external-cohorts · forms-surveys ·
learning-curriculum · onboarding · pathfinder · payment · sales-outreach · volunteer-management ·
weekly-reports · ai-coach · skills-taxonomy · platform-intake

### Working guides

- **[Cursor IDE Guide](./cursor.md)** — editor setup and AI-assisted workflow.
- **[Smart Tasks Testing Guide](./smart-tasks-testing-guide.md)** — testing the AI-powered
  learning tasks.

### In the code repository (read once cloned)

- `server/CLAUDE.md` — backend conventions and gotchas (authoritative).
- `server/app-context.md` — full-stack feature/file map, 13 feature areas.
- `server/data-dictionary.md` + `server/database-schema.sql` — the 60+ table schema.
- `server/graphs/coachV2-architecture.md` — the V2 Coach agent topology.
- `client/CLAUDE.md` — frontend conventions (authoritative).
- `client/admin-dash-prd.md` — Admin Dashboard living product contract.

> Note: the `README.md` files in `server/` and `client/` are outdated — the `CLAUDE.md` files are the source of
> truth for run instructions and conventions.

**Verify:**

- [ ] Given access to this documentation repo
- [ ] Read the Engineer Onboarding Guide
- [ ] Walked through the visual guide for their first assignment's system

---

## 5. First week

- [ ] Trace one request end-to-end (UI click → `services/` → `app.js` route → controller → query)
- [ ] Skim the core tables: `users`, `cohorts`, `applications`, `user_task_progress`,
  `builder_profiles`, `agent_run_steps`
- [ ] First small ticket: branch from `dev` in a worktree, tests pass, PR opened against `dev`
- [ ] Pair session on the V2 Coach (watch a live run in the Coach Runs admin UI)

---

## 6. Sign-off

- [ ] **Engineer** — "I have access to everything above" · name: ______________ · date: __________
- [ ] **Onboarding owner** — "All items verified" · name: ______________ · date: __________
- [ ] **Manager** — reviewed · name: ______________ · date: __________
