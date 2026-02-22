# Assessment & Performance System — Overview

## Architecture

The Assessment & Performance system manages builder assessments throughout the program lifecycle, tracks submission status, enables LLM-powered conversations for assessment completion, provides admin grading interfaces with BigQuery integration, and displays personal performance metrics including attendance calendars and feedback inboxes.

### Tech Stack

- **Client**: React 19 + Vite, MUI v7, Tailwind, React Router v6, React Query
- **Server**: Express.js, PostgreSQL (pg-promise), JWT auth
- **AI**: LLM integration for assessment conversations
- **Analytics**: BigQuery integration for grading analytics

---

## Builder-Facing Routes

| Route | Component | Purpose |
|---|---|---|
| `/assessment` | AssessmentList | Lists assessments by period, filtered by status: Available, Completed, In Progress, Locked, Resubmission Required. Shows assessment name, type, period, due date, and status badges. |
| `/performance` | Performance | Builder's personal dashboard showing attendance calendar with present/late/absent indicators, feedback inbox with unread counts, task completion status, and user photos. |
| `/stats` | UserStats | Tabbed interface: Work Product (submissions, completion rates), Comprehension (assessment scores), Feedback (received feedback), Resources (accessed resources). Visual charts and metrics. |

## Admin Routes

| Route | Purpose |
|---|---|
| `/assessment-grades` | Admin grading interface. Filter by cohort/period. View submissions, edit feedback, assign grades. Mass email functionality. Export CSV/JSON. BigQuery integration. |
| Admin Assessment Management | Create and edit assessment templates, set up assessments for cohorts, configure assessment periods, manage trigger day numbers, view submission analytics, activate/deactivate assessments. |

---

## Controllers

### assessmentController

- `GET` assessments list
- `GET` submissions
- `POST` thread creation
- `POST` LLM conversation storage
- `GET` readonly view

### adminAssessmentController

- `GET` submissions listing
- `GET` analytics
- `POST` cohort setup
- `GET` export data

### adminAssessmentGradesController

- `GET` grades with BigQuery
- `GET` cohorts/periods
- `POST` mass email
- `GET` export CSV/JSON
- `PUT` editable feedback

### performanceController

- `GET` tasks with feedback
- `GET` attendance records
- `GET` user photos

### statsController

- `GET` user stats
- `GET` tasks data
- `GET` submissions data
- `GET` feedback data
- `GET` resources data

---

## API Endpoints

### /api/assessments/* (Builder)

- `GET /` — List assessments for user
- `GET /:id` — Get assessment details
- `GET /:id/submissions` — Get user's submissions
- `POST /:id/submissions` — Create submission
- `PUT /:id/submissions/:submissionId` — Update submission
- `POST /:id/threads` — Create LLM conversation thread
- `POST /:id/threads/:threadId` — Store LLM conversation
- `GET /:id/readonly` — Readonly view

### /api/admin/assessments/* (Admin)

- `GET /submissions` — List all submissions
- `GET /analytics` — Assessment analytics
- `POST /cohorts` — Setup cohort assessments
- `GET /export` — Export assessment data

### /api/admin/assessment-grades/* (Admin)

- `GET /` — Get grades with BigQuery
- `GET /cohorts` — List cohorts
- `GET /periods` — List assessment periods
- `POST /mass-email` — Send mass emails
- `GET /export/csv` — Export CSV
- `GET /export/json` — Export JSON
- `PUT /feedback/:submissionId` — Update feedback

### /api/performance/* & /api/users/stats

- `GET /api/performance/tasks` — Tasks with feedback
- `GET /api/performance/attendance` — Attendance records
- `GET /api/performance/photos` — User photos
- `GET /api/users/stats` — User statistics

---

## Database Tables (3 core tables)

### Assessment Templates

- **assessment_templates** — Template definitions
  - `template_id` PRIMARY KEY
  - `assessment_name` — Name of assessment
  - `assessment_type` — Type classification
  - `instructions` — Assessment instructions
  - `deliverables` — JSONB field for deliverables

### Assessments

- **assessments** — Cohort/period-linked assessments
  - `assessment_id` PRIMARY KEY
  - `template_id` FK to templates
  - `cohort` — Cohort identifier
  - `trigger_day_number` — Day when assessment becomes available
  - `assessment_period` — Period classification
  - `is_active` — Active status
  - **UNIQUE:** template_id + cohort + trigger_day_number

### Submissions

- **assessment_submissions** — Builder submissions with LLM data
  - `submission_id` PRIMARY KEY
  - `user_id` FK to users
  - `assessment_id` FK to assessments
  - `submission_data` — JSONB submission content
  - `llm_conversation_data` — JSONB LLM conversation
  - `status` — draft/submitted
  - `is_preview` — Preview flag
  - `needs_file_resubmission` — File resubmission flag
  - `needs_video_resubmission` — Video resubmission flag
  - **UNIQUE:** user_id + assessment_id + is_preview

---

## Key Files

### Client (`pilot-client/src/`)

- `pages/Assessment/AssessmentList.jsx` — Assessment listing page
- `pages/Assessment/AssessmentView.jsx` — Assessment submission interface
- `pages/Performance/Performance.jsx` — Personal performance dashboard
- `pages/Stats/UserStats.jsx` — User statistics page
- `pages/Admin/AssessmentGrades.jsx` — Admin grading interface

### Server (`test-pilot-server/`)

- `controllers/assessmentController.js` — Builder assessment API logic
- `controllers/adminAssessmentController.js` — Admin assessment management
- `controllers/adminAssessmentGradesController.js` — Grading with BigQuery
- `controllers/performanceController.js` — Performance tracking
- `controllers/statsController.js` — User statistics
- `routes/assessmentRoutes.js` — Route definitions
- `queries/assessments.js` — Database queries

---

## Related Visual Guides

- `system-overview.md` — Markdown version of this guide for agent consumption
- `schema.sql` — Complete DDL for all assessment-related tables
