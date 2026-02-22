# Builder Onboarding System — Overview

## Architecture

The Builder Onboarding system guides admitted applicants through required tasks before they become builders. It includes a task wizard, completion tracking, builder account creation, and email migration from personal to Pursuit email addresses.

### Tech Stack

- **Client**: React 19 + Vite, MUI v7, Tailwind, React Router v6, React Query
- **Server**: Express.js, PostgreSQL (pg-promise), JWT auth
- **Controller**: `onboardingController.js`

---

## Pages

| Route | Component | Purpose |
|---|---|---|
| `/onboarding` | OnboardingWizard | Wizard interface for admitted applicants to complete required tasks before becoming builders. Shows all tasks with completion status, allows marking/unmarking tasks as complete, displays completion summary, and provides "Create Builder Account" button when all required tasks are done. Handles email migration (personal → pursuit email format: first.last@pursuit.org) and role change from applicant to builder. |

---

## Onboarding Flow

1. **Admitted Applicant** → Views 8 default onboarding tasks
2. **Complete Required Tasks** → Mark tasks as complete/uncomplete
3. **Check Completion** → System verifies all required tasks are done
4. **Create Builder Account** → When all required tasks complete, applicant can create builder account
5. **Email Migration** → Personal email → Pursuit email (first.last@pursuit.org)
6. **Role Change** → Applicant role → Builder role
7. **Enrollment Update** → Update enrollment status
8. **Builder Ready** → Applicant is now a builder

### Default Tasks

The system includes 8 default onboarding tasks:

1. Program Details
2. Attendance Policy
3. Slack Setup
4. Pursuit Email
5. Google Calendar
6. Kisi Setup
7. Building in Public
8. Engage Tech News

Tasks can be marked as required or optional, and admins can manage them via the admin API.

---

## API Endpoints

### Public Endpoints (`/api/onboarding`)

- `GET /tasks?applicantId=` — Get all tasks with completion status for applicant
- `POST /tasks/:taskId/complete` — Mark a task as complete
- `DELETE /tasks/:taskId/complete` — Unmark a task (remove completion)
- `GET /status/:applicantId` — Get completion summary (required vs completed counts)
- `POST /create-builder-account` — Create builder account after all required tasks done
- `GET /email-mapping/:email` — Look up email mapping (personal → pursuit)

### Admin Endpoints (`/api/onboarding/admin`)

All admin endpoints require authentication and appropriate permissions.

**Tasks:**
- `GET /tasks` — List all tasks
- `POST /tasks` — Create new task
- `PUT /tasks/:taskId` — Update task
- `DELETE /tasks/:taskId` — Delete task

**Email Mappings:**
- `GET /email-mappings` — List email mappings
- `POST /email-mappings` — Create email mapping
- `PUT /email-mappings/:id` — Update email mapping
- `DELETE /email-mappings/:id` — Delete email mapping

---

## Database Tables (3 total)

### onboarding_tasks

Configurable tasks with ordering, required flags, and active status.

- **task_id** (SERIAL PK)
- **title** (VARCHAR(255) NOT NULL)
- **description** (TEXT)
- **detailed_description** (TEXT)
- **link_url** (TEXT)
- **link_text** (VARCHAR(255))
- **is_required** (BOOLEAN DEFAULT true)
- **display_order** (INTEGER DEFAULT 0)
- **is_active** (BOOLEAN DEFAULT true)
- **created_by_user_id** (INTEGER FK → users)
- **updated_by_user_id** (INTEGER FK → users)
- **created_at** (TIMESTAMP)
- **updated_at** (TIMESTAMP)

### applicant_onboarding_task_completions

Tracks which tasks each applicant has completed. UNIQUE constraint on applicant_id + task_id ensures one completion record per task per applicant.

- **completion_id** (SERIAL PK) — Note: column name may be `id` in actual schema
- **applicant_id** (INTEGER FK → applicant, NOT NULL)
- **task_id** (INTEGER FK → onboarding_tasks, NOT NULL)
- **completed_at** (TIMESTAMP DEFAULT CURRENT_TIMESTAMP)
- **notes** (TEXT, optional)
- **UNIQUE(applicant_id, task_id)**

### applicant_email_mapping

Maps personal email addresses to Pursuit email addresses (format: first.last@pursuit.org). Both personal_email and pursuit_email have UNIQUE constraints.

- **mapping_id** (SERIAL PK) — Note: column name may be `id` in actual schema
- **personal_email** (VARCHAR(255) UNIQUE NOT NULL)
- **pursuit_email** (VARCHAR(255) UNIQUE NOT NULL)
- **created_at** (TIMESTAMP)
- **updated_at** (TIMESTAMP)

---

## Controller: onboardingController

### Public Methods

- `getTasks` — Get tasks with completion status for applicant
- `markTaskComplete` — Mark a task as complete
- `unmarkTaskComplete` — Unmark a task (remove completion)
- `getCompletionStatus` — Get completion summary (required vs completed counts)
- `createBuilderAccount` — Create builder account after all required tasks done
- `getEmailMapping` — Look up email mapping by email

### Admin Methods

- Task CRUD operations (create, read, update, delete)
- Email mapping CRUD operations

---

## Key Features

- **Task Management**: Configurable tasks with ordering, required flags, and active status
- **Completion Tracking**: Per-applicant task completion with timestamps and optional notes
- **Builder Account Creation**: Automatic account creation when all required tasks are complete
- **Email Migration**: Maps personal emails to Pursuit email format (first.last@pursuit.org)
- **Role Change**: Automatically changes applicant role to builder upon account creation
- **Enrollment Update**: Updates enrollment status when builder account is created

---

## Related Visual Guides

- `system-overview.html` — Visual guide with diagrams and detailed explanations
- `schema.sql` — Complete DDL for all onboarding-related tables
