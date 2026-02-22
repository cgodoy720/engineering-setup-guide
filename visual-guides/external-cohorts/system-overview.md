# External Cohorts System — Overview

## Architecture

The External Cohorts system manages enterprise cohorts and workshops for external organizations. It provides a unified signup flow using access codes, admin assignment, participant management, curriculum viewing, and conversation tracking.

### Tech Stack

- **Client**: React 19 + Vite, MUI v7, Tailwind, React Router v6, React Query
- **Server**: Express.js, PostgreSQL (pg-promise), JWT auth
- **Permissions**: 
  - Admin routes require `page:external_cohorts`
  - Cohort admin routes require `page:cohort_admin`
  - Public routes require no auth

---

## External Cohorts Dashboard

### Route: `/external-cohorts`

Admin dashboard for managing external cohorts and workshops. Requires `page:external_cohorts` permission.

### Features

- **Cohort Management**: Create/list/update/deactivate cohorts
- **Admin Assignment**: Assign and manage cohort admins
- **Bulk Invites**: Invite participants in bulk, resend invitations
- **Analytics**: Stats, participant listing, attendance breakdown
- **Viewing**: Curriculum viewing, participant conversations, task conversations

---

## Controllers

### externalCohortsController

- **Full CRUD** for cohorts (create, list, update, deactivate)
- **Admin Management**: Assignment, listing, removal
- **Bulk Invites**: Invite participants, resend invitations
- **Stats & Metrics**: Cohort statistics and performance metrics
- **Participant Management**: Listing, attendance breakdown
- **Viewing**: Curriculum viewing, participant conversations, task conversations

### enterpriseController

- **Unified Signup**: Single endpoint for cohort and workshop signup
- **Access Code Validation**: Validate access codes before signup
- **User Account Creation**: Create user accounts with enterprise roles

---

## API Routes

### Public (No Auth Required)

- `POST /api/external-cohorts/access` — Sign up with access code
- `GET /api/external-cohorts/validate-code/:code` — Validate access code

### Admin (Requires `page:external_cohorts`)

- Full CRUD for cohorts
- Admin assignment/listing/removal
- Bulk invite participants
- Resend invitations
- Stats, participants, attendance breakdown
- Curriculum viewing
- Participant and task conversation viewing

### Cohort Admin (Requires `page:cohort_admin`)

- `GET /api/external-cohorts/cohort-admin/my-cohorts` — List cohorts for cohort admin

### Internal (For CurriculumEditor)

- `GET /api/external-cohorts/internal/list` — List cohorts for curriculum editor
- `POST /api/external-cohorts/internal` — Create cohort from curriculum editor
- `PUT /api/external-cohorts/internal` — Update cohort from curriculum editor

---

## Database Tables (4 core tables)

### Cohort Management

- **cohort** — Cohort records with access codes, types, dates
  - Columns: cohort_id (UUID PK), name, start_date, end_date, cohort_type (builder/workshop/external), access_code (UNIQUE), description, contact_name, contact_email, is_active, course_id (FK)
  - Access codes: Auto-generated format `EXT-{timestamp}-{random}`
- **cohort_admins** — Admin assignments to cohorts
  - Columns: admin_id (PK), user_id (FK nullable), cohort_id (FK), pending_email, role
  - Supports pending admins via email before user account creation

### Invitations & Users

- **cohort_invitations** — Participant invitations with status tracking
  - Columns: invitation_id (PK), cohort_id (FK), email, status (pending/sent/registered/expired), sent_at, registered_at, user_id (FK nullable)
  - Status flow: pending → sent → registered (or expired)
- **users** (extended) — User accounts extended with cohort assignment
  - Extended columns: cohort_id (FK), roles: enterprise_builder, enterprise_admin
  - Links users to cohorts and provides enterprise role support

---

## Key Files

### Client (`pilot-client/src/`)

- `pages/ExternalCohorts/ExternalCohortsDashboard.jsx` — Main dashboard page

### Server (`test-pilot-server/`)

- `controllers/externalCohortsController.js` — API logic for cohort management
- `controllers/enterpriseController.js` — Unified signup endpoint
- `routes/externalCohortsRoutes.js` — Route definitions
- `queries/externalCohorts.js` — Database queries

---

## Related Visual Guides

- `system-overview.html` — Visual guide with architecture diagrams
- `schema.sql` — Complete DDL for all External Cohorts tables
