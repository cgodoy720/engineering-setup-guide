# Admin & Management System — Overview

## Architecture

The Admin & Management system provides comprehensive control over user permissions, organizational hierarchies, cohort management, and prompt configuration. It includes role-based access control with custom overrides, multi-level organization structures, and centralized prompt management for AI interactions.

### Tech Stack

- **Client**: React 19 + Vite, MUI v7, Tailwind, React Router v6, React Query
- **Server**: Express.js, PostgreSQL (pg-promise), JWT auth
- **Permission System**: Role-based defaults + custom user overrides with resource scoping

---

## Admin Pages

All admin pages require appropriate `page:*` permissions. The permission system checks role defaults first, then user-specific overrides, with admin users having wildcard access.

| Route | Component | Permission Required | Key Features |
|---|---|---|---|
| `/admin-dashboard` | AdminDashboard | `page:admin_dashboard` | Tabs: Summary, Survey (NPS), L2 Selections, Videos, Legacy View |
| `/admin-prompts` | AdminPrompts | `page:admin_prompts` | Tabs: Base Prompts, Personas, Program Contexts, Modes, Content Generation, Status |
| `/admin-attendance-dashboard` | AdminAttendanceDashboard | `page:admin_attendance` | Attendance tracking and management |
| `/cohort-admin-dashboard` | CohortAdminDashboard | `page:cohort_admin` | View assigned cohorts, participants, conversations |
| `/admin/organization-management` | OrganizationManagement | `page:organization_management` | Tabs: Organizations, Programs, Courses, Cohorts, Enrollments. Bulk operations, CSV export |
| `/admin/permission-management` | PermissionManagement | Admin only | User permissions, role management, custom overrides |
| `/workshop-admin-dashboard` | WorkshopAdminDashboard | `page:workshop_admin` | Workshop administration |
| `/payment-admin` | PaymentAdmin | `page:payment_admin` | Payment management |

---

## Permission System

### Overview

The permission system uses a multi-layered approach:

1. **Role Permissions** (`role_permissions`) — Default grants per role
2. **User Permissions** (`user_permissions`) — Custom overrides per user
3. **Admin Wildcard** — Admin role users have access to all permissions
4. **Resource-Scoped Permissions** — Permissions can be scoped to specific resources (`resource_id`, `resource_type`)
5. **Expiring Permissions** — Optional `expires_at` for temporary access
6. **Middleware Factory** — `requirePermission()` creates route protection middleware

### Permission Check Flow

1. Check if user role is `admin` → Grant all permissions
2. Check `user_permissions` for custom override → Use if exists and not expired
3. Check `role_permissions` for default grant → Use if no override
4. Check resource scoping if applicable → Verify `resource_id` and `resource_type` match
5. Deny access if no match found

### Roles

- `admin` — Full access (wildcard)
- `staff` — Staff-level permissions
- `builder` — Builder-level permissions
- `applicant` — Applicant-level permissions
- `workshop_participant` — Workshop participant permissions
- `workshop_admin` — Workshop admin permissions
- `volunteer` — Volunteer permissions
- `enterprise_builder` — Enterprise builder permissions
- `enterprise_admin` — Enterprise admin permissions

### Permission Keys

Permissions use dot notation, e.g.:
- `page:admin_dashboard` — Access to admin dashboard page
- `page:admin_prompts` — Access to prompts management
- `page:cohort_admin` — Access to cohort admin dashboard
- `action:create_cohort` — Permission to create cohorts
- `action:manage_permissions` — Permission to manage user permissions

---

## Organization Hierarchy

The system supports a four-level hierarchy:

```
Organization
  └── Program
      └── Course
          └── Cohort
              └── Enrollment (User ↔ Cohort)
```

### Organizations

- Top-level entities with unique `slug`
- Contact information (email, name)
- Logo URL
- Active status
- Can have multiple programs

### Programs

- Belong to an organization (`organization_id` FK)
- Have `program_type` classification
- Unique `slug` per organization
- Active status
- Can have multiple courses

### Courses

- Belong to a program (`program_id` FK)
- Have `level` and `sequence_order` for ordering
- `duration_weeks` for scheduling
- Unique `slug` per program
- Active status
- Can have multiple cohorts

### Cohorts

- Belong to a course (`course_id` FK)
- `cohort_type`: `builder` / `workshop` / `external`
- `access_code` for enrollment
- `start_date` and `end_date`
- `is_active` flag
- BigQuery integration for analytics
- Can have multiple admins (`cohort_admins`)
- Can have pending invitations (`cohort_invitations`)

### Enrollments

- Many-to-many relationship between users and cohorts
- `enrolled_date` timestamp
- `status` field (active/inactive/completed/etc.)
- `is_active` boolean
- Optional `notes` field

---

## API Endpoints

### /api/admin/dashboard

- `GET /summary` — Cohort summary statistics
- `GET /survey` — Survey (NPS) data
- `GET /l2-selections` — L2 selection tracking
- `GET /videos` — Video management
- `GET /legacy` — Legacy view data

### /api/admin/prompts

- `GET|POST|PUT|DELETE /base-prompts` — CRUD for base prompts
- `GET|POST|PUT|DELETE /personas` — Persona management
- `GET|POST|PUT|DELETE /program-contexts` — Program context CRUD
- `GET|POST|PUT|DELETE /modes` — Mode configuration
- `GET|POST|PUT|DELETE /content-generation` — Content generation prompts
- `GET /status` — Status viewing and reload

### /api/admin/attendance

- `GET /` — Attendance tracking
- `GET /reports` — Attendance reports
- `POST /bulk` — Bulk attendance updates

### /api/admin/organization-management

- `GET|POST|PUT|DELETE /organizations` — Organization CRUD
- `GET|POST|PUT|DELETE /programs` — Program management
- `GET|POST|PUT|DELETE /courses` — Course operations
- `GET|POST|PUT|DELETE /cohorts` — Cohort CRUD
- `GET|POST|PUT|DELETE /enrollments` — Enrollment management
- `POST /bulk` — Bulk operations
- `GET /export` — CSV export

### /api/permissions

- `GET|POST|PUT|DELETE /` — Permission CRUD
- `GET|POST|PUT|DELETE /roles` — Role management
- `GET|POST|PUT|DELETE /users/:userId/permissions` — Custom user overrides
- `GET /audit` — Permission audit log

### /api/admin/assessments

- `GET|POST|PUT|DELETE /` — Assessment management
- `GET /results` — Assessment results
- `GET /analytics` — Assessment analytics

---

## Database Tables

### Permission Tables (2 tables)

- **role_permissions** — Default grants per role
  - `role_permission_id` PK
  - `role_name` (CHECK constraint: admin/staff/builder/etc.)
  - `permission_key` (e.g., `page:admin_dashboard`)
  - `default_granted` BOOLEAN
  - `description` TEXT

- **user_permissions** — Custom user overrides
  - `permission_id` PK
  - `user_id` FK → users
  - `permission_key`
  - `resource_id` UUID (optional, for resource-scoped permissions)
  - `resource_type` VARCHAR (optional, e.g., `cohort`, `organization`)
  - `granted` BOOLEAN
  - `granted_by` FK → users
  - `notes` TEXT
  - `expires_at` TIMESTAMP (optional)

### Organization Hierarchy (4 tables)

- **organizations** — Top-level organizations
  - `organization_id` PK
  - `name` VARCHAR NOT NULL
  - `slug` VARCHAR UNIQUE NOT NULL
  - `description` TEXT
  - `active` BOOLEAN DEFAULT true
  - `logo_url` VARCHAR
  - `contact_email` VARCHAR
  - `contact_name` VARCHAR
  - `created_at`, `updated_at` TIMESTAMP

- **program** — Programs within organizations
  - `program_id` PK
  - `organization_id` FK → organizations
  - `name` VARCHAR NOT NULL
  - `slug` VARCHAR NOT NULL (UNIQUE per organization)
  - `description` TEXT
  - `program_type` VARCHAR
  - `active` BOOLEAN DEFAULT true
  - `created_at`, `updated_at` TIMESTAMP

- **course** — Courses within programs
  - `course_id` PK
  - `program_id` FK → program
  - `name` VARCHAR NOT NULL
  - `slug` VARCHAR NOT NULL (UNIQUE per program)
  - `description` TEXT
  - `level` INTEGER
  - `sequence_order` INTEGER
  - `duration_weeks` INTEGER
  - `active` BOOLEAN DEFAULT true
  - `created_at`, `updated_at` TIMESTAMP

- **cohort** — Cohorts within courses
  - `cohort_id` UUID PK (gen_random_uuid())
  - `name` VARCHAR NOT NULL
  - `start_date` DATE
  - `end_date` DATE
  - `cohort_type` VARCHAR CHECK (builder/workshop/external)
  - `course_id` FK → course
  - `access_code` VARCHAR UNIQUE
  - `is_active` BOOLEAN DEFAULT true
  - `created_at`, `updated_at` TIMESTAMP

### Enrollment & Access (3 tables)

- **user_enrollment** — User-cohort enrollments
  - `enrollment_id` PK
  - `user_id` FK → users
  - `cohort_id` FK → cohort
  - `enrolled_date` TIMESTAMP DEFAULT NOW()
  - `status` VARCHAR
  - `is_active` BOOLEAN DEFAULT true
  - `notes` TEXT
  - UNIQUE on `user_id` + `cohort_id`

- **cohort_admins** — Admin assignments to cohorts
  - `admin_id` PK
  - `user_id` FK → users
  - `cohort_id` FK → cohort
  - `pending_email` VARCHAR (for pending invites)
  - `role` VARCHAR
  - UNIQUE on `user_id` + `cohort_id`

- **cohort_invitations** — Pending cohort invitations
  - `invitation_id` PK
  - `cohort_id` FK → cohort
  - `email` VARCHAR NOT NULL
  - `invited_by` FK → users
  - `invited_at` TIMESTAMP DEFAULT NOW()
  - `accepted_at` TIMESTAMP
  - `expires_at` TIMESTAMP

### Prompt Management (5 tables)

- **base_prompts** — Base prompt templates
  - `prompt_id` PK
  - `name` VARCHAR NOT NULL
  - `content` TEXT NOT NULL
  - `description` TEXT
  - `is_default` BOOLEAN DEFAULT false
  - `active` BOOLEAN DEFAULT true
  - `created_at`, `updated_at` TIMESTAMP

- **personas** — AI persona definitions
  - `persona_id` PK
  - `name` VARCHAR NOT NULL
  - `description` TEXT
  - `system_prompt` TEXT NOT NULL
  - `is_default` BOOLEAN DEFAULT false
  - `active` BOOLEAN DEFAULT true
  - `created_at`, `updated_at` TIMESTAMP

- **program_contexts** — Program-specific contexts
  - `context_id` PK
  - `program_id` FK → program
  - `name` VARCHAR NOT NULL
  - `context_data` JSONB NOT NULL
  - `is_default` BOOLEAN DEFAULT false
  - `active` BOOLEAN DEFAULT true
  - `created_at`, `updated_at` TIMESTAMP

- **modes** — Interaction modes
  - `mode_id` PK
  - `name` VARCHAR NOT NULL
  - `description` TEXT
  - `config` JSONB NOT NULL
  - `is_default` BOOLEAN DEFAULT false
  - `active` BOOLEAN DEFAULT true
  - `created_at`, `updated_at` TIMESTAMP

- **content_generation_prompts** — Content generation prompts
  - `prompt_id` PK
  - `name` VARCHAR NOT NULL
  - `prompt_template` TEXT NOT NULL
  - `description` TEXT
  - `is_default` BOOLEAN DEFAULT false
  - `active` BOOLEAN DEFAULT true
  - `created_at`, `updated_at` TIMESTAMP

---

## Key Files

### Client (`pilot-client/src/`)

- `pages/Admin/AdminDashboard.jsx` — Main admin dashboard with tabs
- `pages/Admin/AdminPrompts.jsx` — Prompt management interface
- `pages/Admin/AdminAttendanceDashboard.jsx` — Attendance dashboard
- `pages/Admin/CohortAdminDashboard.jsx` — Cohort admin view
- `pages/Admin/OrganizationManagement.jsx` — Organization hierarchy management
- `pages/Admin/PermissionManagement.jsx` — Permission management interface
- `pages/Admin/WorkshopAdminDashboard.jsx` — Workshop admin
- `pages/Admin/PaymentAdmin.jsx` — Payment admin

### Server (`test-pilot-server/`)

- `controllers/adminController.js` — Admin dashboard logic
- `controllers/promptsController.js` — Prompt CRUD logic
- `controllers/organizationController.js` — Organization hierarchy CRUD
- `controllers/permissionController.js` — Permission management
- `middleware/permissions.js` — `requirePermission()` middleware factory
- `queries/permissions.js` — Permission query functions
- `queries/organizations.js` — Organization query functions
- `routes/adminRoutes.js` — Admin route definitions
- `routes/permissionRoutes.js` — Permission route definitions
- `db/database-schema.sql` — Full schema DDL

---

## Related Visual Guides

- `system-overview.html` — This visual guide with architecture diagrams
- `system-overview.md` — This markdown documentation (agent-friendly)
- `schema.sql` — Complete DDL for all admin/management tables
