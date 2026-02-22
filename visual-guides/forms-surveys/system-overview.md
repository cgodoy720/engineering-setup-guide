# Forms & Surveys System — Overview

## Architecture

The Forms & Surveys system provides a comprehensive form builder for creating, managing, and analyzing custom forms and surveys. It consists of two user-facing sides:

- **Admin Dashboard** — Staff-only dashboard requiring `page:form_builder` permission for form creation and management
- **Public Form Interface** — Public-facing form interface accessible via unique slug (no authentication required, rate limited)

### Tech Stack

- **Client**: React 19 + Vite, MUI v7, Tailwind, React Router v6, React Query
- **Server**: Express.js, PostgreSQL (pg-promise), JWT auth
- **Storage**: JSONB for flexible question and response storage

---

## Admin Routes

| Route | Component | Purpose |
|---|---|---|
| `/forms` | FormBuilderDashboard | List all forms (card/table views), filter, create/edit/duplicate/archive forms |
| `/forms/new` | FormEditor | Create new form with question editor, settings, live preview |
| `/forms/:formId/edit` | FormEditor | Edit existing form with question editor, settings, live preview |
| `/forms/:formId/submissions` | FormSubmissions | View submissions, flag submissions, add notes, export CSV/JSON |
| `/forms/:formId/analytics` | FormAnalytics | Stats, response distributions, completion rates, visualizations |

## Public Routes

| Route | Component | Purpose |
|---|---|---|
| `/form/:slug` | PublicFormContainer | Public form view, question-by-question progression, progress tracking, draft saving, session management |

---

## Question Types

The system supports 9 question types:

- `text` — Short text input
- `long_text` — Multi-line text area
- `email` — Email input with validation
- `number` — Numeric input
- `scale` — Rating scale (e.g., 1-5, 1-10)
- `multiple_choice` — Single selection from options
- `checkbox` — Multiple selections from options
- `date` — Date picker
- `file` — File upload

Questions are stored as JSONB arrays in `forms.questions`. Each question has: `id`, `type`, `label`, `required`, `options` (for multiple choice/checkbox), `validation`, and `order`.

---

## Form Status

Forms can have the following statuses:

- `draft` — Form is being created/edited, not yet published
- `active` — Form is live and accepting submissions
- `closed` — Form is closed to new submissions
- `archived` — Form is archived (soft delete)

---

## API Endpoints

### /api/forms (Admin)

All endpoints require `page:form_builder` permission.

- `POST /` — Create form
  - Body: `title`, `description`, `slug`, `status`, `questions`, `settings`
  - Returns: Created form object
- `GET /` — Get all forms
  - Query params: `status`, `createdBy`, `search`
  - Returns: Array of form objects
- `GET /:formId` — Get form by ID
  - Returns: Form object with questions and settings
- `PUT /:formId` — Update form
  - Body: Same as create
  - Returns: Updated form object
- `DELETE /:formId` — Delete (archive) form
  - Returns: Success message
- `POST /:formId/duplicate` — Duplicate form
  - Returns: New form object
- `PUT /:formId/status` — Update form status
  - Body: `status`
  - Returns: Updated form object
- `GET /:formId/submissions` — Get form submissions
  - Query params: `status`, `flagged`, `limit`, `offset`
  - Returns: Array of submission objects
- `PUT /:formId/submissions/:submissionId` — Update submission
  - Body: `notes`, `flagged`
  - Returns: Updated submission object
- `DELETE /:formId/submissions/:submissionId` — Delete submission
  - Returns: Success message
- `GET /:formId/analytics` — Get form analytics
  - Returns: Analytics object with stats, distributions, completion rates
- `GET /:formId/analytics/distribution` — Get response distribution
  - Query params: `questionId`
  - Returns: Distribution data for a specific question
- `GET /:formId/analytics/completion` — Get completion stats
  - Returns: Completion rate and time statistics
- `GET /:formId/export/csv` — Export submissions as CSV
  - Returns: CSV file download
- `GET /:formId/export/json` — Export submissions as JSON
  - Returns: JSON file download

### /api/public/forms (Public)

No authentication required. Rate limited.

- `GET /:slug` — Get form by slug
  - Returns: Form object (public fields only)
- `POST /:slug/submit` — Submit form
  - Body: `responses` (JSONB), `respondentEmail` (optional)
  - Returns: Submission confirmation
- `POST /:slug/draft` — Save draft
  - Body: `responses` (JSONB), `sessionId`
  - Returns: Draft saved confirmation
- `GET /:slug/draft` — Get draft
  - Query params: `sessionId`
  - Returns: Draft responses or null
- `GET /:slug/status` — Get form status
  - Returns: Form status (active/closed) and submission limit info

---

## Database Tables (2 total)

### forms

- **form_id** — UUID PRIMARY KEY DEFAULT gen_random_uuid()
- **title** — VARCHAR(255) NOT NULL
- **description** — TEXT
- **slug** — VARCHAR(255) UNIQUE NOT NULL
- **status** — VARCHAR(50) NOT NULL (draft, active, closed, archived)
- **created_by** — INTEGER REFERENCES users(user_id)
- **expires_at** — TIMESTAMP
- **submission_limit** — INTEGER
- **submission_count** — INTEGER DEFAULT 0
- **settings** — JSONB (theme, redirect URL, thank you message, etc.)
- **questions** — JSONB NOT NULL (array of question objects)
- **created_at** — TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- **updated_at** — TIMESTAMP DEFAULT CURRENT_TIMESTAMP

### form_submissions

- **submission_id** — UUID PRIMARY KEY DEFAULT gen_random_uuid()
- **form_id** — UUID NOT NULL REFERENCES forms(form_id) ON DELETE CASCADE
- **responses** — JSONB NOT NULL (object mapping question_id → answer)
- **respondent_email** — VARCHAR(255)
- **submitted_at** — TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- **completion_time_seconds** — INTEGER
- **session_id** — VARCHAR(255)
- **ip_address** — VARCHAR(45)
- **user_agent** — TEXT
- **status** — VARCHAR(50) NOT NULL DEFAULT 'completed' (completed, draft)
- **notes** — TEXT (admin notes)
- **flagged** — BOOLEAN DEFAULT false
- **created_at** — TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- **updated_at** — TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## Controllers

### formBuilderController

Handles form CRUD operations:

- `createForm` — Create new form
- `getAllForms` — List all forms with filtering
- `getFormById` — Get form by ID
- `updateForm` — Update form
- `deleteForm` — Archive form (soft delete)
- `duplicateForm` — Duplicate form
- `updateFormStatus` — Update form status
- `getFormBySlug` — Get form by slug (public)

### formSubmissionsController

Handles submission operations:

- `submitForm` — Submit form (public)
- `getFormStatus` — Get form status (public)
- `saveDraft` — Save draft (public)
- `getDraft` — Get draft (public)
- `getSubmissions` — Get submissions for a form (admin)
- `updateSubmission` — Update submission (notes, flagged) (admin)
- `deleteSubmission` — Delete submission (admin)

### formAnalyticsController

Handles analytics and exports:

- `getAnalytics` — Get form analytics (admin)
- `getResponseDistribution` — Get response distribution for a question (admin)
- `getCompletionStats` — Get completion statistics (admin)
- `exportCSV` — Export submissions as CSV (admin)
- `exportJSON` — Export submissions as JSON (admin)

---

## Key Files

### Client (`pilot-client/src/`)

- `pages/Forms/FormBuilderDashboard.jsx` — Main dashboard
- `pages/Forms/FormEditor.jsx` — Form editor (create/edit)
- `pages/Forms/FormSubmissions.jsx` — Submissions view
- `pages/Forms/FormAnalytics.jsx` — Analytics view
- `pages/Forms/PublicFormContainer.jsx` — Public form view

### Server (`test-pilot-server/`)

- `controllers/formBuilderController.js` — Form CRUD logic
- `controllers/formSubmissionsController.js` — Submission logic
- `controllers/formAnalyticsController.js` — Analytics logic
- `routes/formRoutes.js` — Route definitions
- `db/schema.sql` — Database schema DDL

---

## Related Visual Guides

- `system-overview.html` — Visual guide with architecture diagrams
- `schema.sql` — Complete DDL for all forms-related tables
