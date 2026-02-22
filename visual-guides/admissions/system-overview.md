# Admissions System — Overview

## Architecture

The Admissions system manages applicant intake from signup through program onboarding. It consists of two user-facing sides:

- **Applicant Portal** — Public pages for people applying (separate auth from builder login)
- **Admin Dashboard** — Staff-only dashboard requiring `page:admissions` permission

### Tech Stack

- **Client**: React 19 + Vite, MUI v7, Tailwind, React Router v6, React Query
- **Server**: Express.js, PostgreSQL (pg-promise), JWT auth
- **AI**: OpenAI/Anthropic for application analysis scoring

---

## Applicant-Facing Routes

| Route | Component | Purpose |
|---|---|---|
| `/apply/signup` | ApplicantSignup | Account creation (name, email, password). Email verification required. |
| `/apply` | ApplicantDashboard | Main hub with 4 progress cards (Info Session, Application, Workshop, Pledge/Onboarding). Status-driven UI. |
| `/info-sessions` | InfoSessions | Browse and register for info sessions. Shows date, time, location, capacity. |
| `/application-form` | ApplicationForm | Multi-section form with auto-save (1s debounce). Eligibility checking. Conditional questions. |
| `/workshops` | Workshops | Browse workshops (only if invited). Register with laptop selection. "Enter Workshop" converts to builder account. |
| `/pledge` | Pledge | 6-step wizard: Introduction, Learning, Community, Building, Information, Signature (canvas). |
| `/onboarding` | Onboarding | 8-step task wizard. Creates builder account when all required tasks complete. |

## Admin Routes

| Route | Purpose |
|---|---|
| `/admissions-dashboard` | Main dashboard with 6 tabs: Overview, Applicants, Info Sessions, Workshops, Leads, Emails |
| `/admissions-dashboard/applicant/:applicantId` | Detailed applicant view with responses, scores, notes, event history |

### Admin Dashboard Tabs

- **Overview**: KPI tiles, stage breakdowns, demographics, conversion funnels
- **Applicants**: Filterable table, bulk actions (invite, email, admit, reject), deliberation flags (yes/maybe/no), notes
- **Info Sessions**: Create/edit sessions, manage registrations, mark attendance
- **Workshops**: Create/edit workshops, manage registrations, mark attendance, laptop tracking
- **Leads**: CSV import, source tracking, conversion to applicant, status management
- **Emails**: Automated email sequences, queue management, send history, email mapping

---

## Applicant Journey (Stage Progression)

### Stages (`applicant_stage.current_stage`)

1. `info_session_registered` → `info_session_attended` / `info_session_no_show`
2. `application_submitted` → `application_under_review`
3. `workshop_invited` → `workshop_registered` → `workshop_attended` / `workshop_no_show`

### Program Admission Status (`applicant_stage.program_admission_status`)

- `pending` (default) → `accepted` / `rejected` / `waitlisted` / `withdrawn`
- `deferred` flag for rolling to next cohort

### Complete Flow

1. **Signup** → Create account at `/apply/signup`
2. **Email Verification** → Must verify before dashboard access
3. **Info Session** → Register and attend at `/info-sessions`
4. **Application** → Multi-section form at `/application-form`
   - Eligibility check (age, income, location, work auth, commute, schedule)
   - If ineligible → Rejection email, can edit and retry
5. **AI Analysis** → Automated scoring (learning, grit, critical thinking, overall 0-100)
   - Recommendation: `strong_recommend` / `recommend` / `review_needed` / `not_recommend`
6. **Human Review** → Staff deliberation (yes/maybe/no)
7. **Workshop Invitation** → Admin invites eligible applicants
8. **Workshop** → Register at `/workshops`, attend, "Enter Workshop" creates builder account
9. **Program Decision** → Staff sets `program_admission_status`
10. **Pledge** → 6-step wizard at `/pledge` (accepted applicants only)
11. **Onboarding** → 8-step tasks at `/onboarding`, creates builder account

---

## API Endpoints

### /api/admissions (Admin)

- `GET /stats` — Overall statistics
- `GET /dashboard/overview` — Overview tab data
- `GET /dashboard/applications` — Applications tab data
- `GET /applications` — List with filters
- `GET /application/:applicationId` — Application details
- `GET /applicant/:applicantId/detail` — Applicant details
- `PUT /applications/:applicationId/status` — Update final status
- `PUT /applicants/:applicantId/stage` — Update stage
- `PUT /applicants/:applicantId/admission-status` — Update program admission status
- `POST /bulk-actions` — Bulk operations
- `GET|POST|PUT|DELETE /info-sessions` — CRUD
- `GET|POST|PUT|DELETE /workshops` — CRUD
- `PUT /attendance/:eventType/:eventId/:applicantId` — Mark attendance
- `GET|POST|PUT|DELETE /notes/:applicantId` — Notes CRUD
- `POST /pledge/complete` — Complete pledge
- `GET /leads` — List leads
- `POST /leads/import` — CSV import
- `POST /email-automation/run` — Run email automation

### /api/applications (Applicant)

- `POST /signup` — Applicant signup
- `POST /login` — Applicant login
- `GET /questions` — Application questions
- `POST /response/anonymous` — Save response (auto-save)
- `PUT /application/:applicationId/submit/anonymous` — Submit
- `POST /check-eligibility` — Eligibility check
- `POST /defer` / `POST /undefer` — Deferral management
- `POST /reapply` — Reapply after rejection

### Supporting APIs

- `/api/info-sessions` — Public event listing and registration
- `/api/workshop` — Workshop access, entry, and conversion to builder
- `/api/onboarding` — Task completions and account creation

---

## Database Tables (22 total)

### Identity (4 tables)

- **applicant** — Accounts with email verification, referral tracking
- **applicant_stage** — Current stage, admission status, pledge, deferral, deliberation, cohort assignment
- **applicant_notes** — Staff notes per applicant
- **applicant_email_mapping** — Personal ↔ Pursuit email mapping

### Application Form (5 tables)

- **application** — Per-applicant applications (status: draft/in_progress/submitted/ineligible)
- **section** — Form sections with display ordering
- **question** — Questions with conditional logic (parent_question_id, show_when_parent_equals)
- **choice_option** — Multiple choice options
- **response** — Applicant answers (UNIQUE on application_id + question_id)

### Events (2 tables)

- **event** — Info sessions and workshops (capacity, online/in-person, workshop_type)
- **event_registration** — Registrations with attendance tracking, laptop needs, reminders

### Analysis (1 table)

- **application_analysis** — AI scoring (learning, grit, critical thinking, overall 0-100), recommendation, masters degree detection, versioned

### Leads (7 tables)

- **lead** — Pre-applicant contacts (status: new/nurturing/qualified/converted/unsubscribed/invalid)
- **lead_source** — Multi-source tracking per lead
- **lead_engagement** — Interaction history (email, event, sms, call)
- **lead_note** — Staff notes
- **email_list** / **lead_email_list** — Email list management (many-to-many)
- **lead_source_config** — Source configuration

### Email & Onboarding (3 tables)

- **email_automation_log** — Email queue with scheduling and tracking
- **onboarding_tasks** — Configurable tasks with ordering and active flags
- **applicant_onboarding_task_completions** — Per-applicant task completion tracking

---

## Key Files

### Client (`pilot-client/src/`)

- `pages/Admissions/ApplicantDashboard.jsx` — Main applicant hub
- `pages/Admissions/ApplicationForm.jsx` — Multi-section form
- `pages/Admissions/ApplicantSignup.jsx` — Account creation
- `pages/Admissions/InfoSessions.jsx` — Info session registration
- `pages/Admissions/Workshops.jsx` — Workshop registration
- `pages/Admissions/Pledge.jsx` — Pledge wizard
- `pages/Admissions/Onboarding.jsx` — Onboarding wizard
- `pages/Admissions/AdmissionsDashboard.jsx` — Admin dashboard
- `pages/Admissions/ApplicationDetail.jsx` — Applicant detail view

### Server (`test-pilot-server/`)

- `controllers/admissionsController.js` — Admin API logic
- `controllers/applicationsController.js` — Applicant API logic
- `controllers/infoSessionsController.js` — Public info session API
- `controllers/onboardingController.js` — Onboarding API
- `queries/admissions.js` — Database queries
- `routes/admissionsRoutes.js` — Route definitions
- `db/database-schema.sql` — Full schema DDL

---

## Related Visual Guides

- `applicant-journey.html` — Full stage diagram with process explanations
- `applicant-side.html` — Detailed applicant page breakdown
- `admin-side.html` — Admin dashboard tabs and features
- `database-schema.html` — ER diagram with table details
- `schema.sql` — Complete DDL for all admissions tables
