# Attendance System — Overview

## Architecture

The Attendance system manages builder check-ins with camera capture, tracks daily attendance records with status indicators (present/late/absent/excused), provides admin dashboards for attendance management and cohort performance analytics, and handles excuse requests with approval workflows.

### Tech Stack

- **Client**: React 19 + Vite, MUI v7, Tailwind, React Router v6, React Query
- **Server**: Express.js, PostgreSQL (pg-promise), JWT auth
- **Camera**: Browser camera API for photo capture during check-in

---

## Builder-Facing Routes

| Route | Component | Purpose |
|---|---|---|
| `/attendance-dashboard` | AttendanceDashboard | Builder check-in interface with camera capture for photo verification. Shows today's overview with status indicators, cohort cards with attendance summary, search functionality to find builders, and real-time check-in status updates. |
| `/attendance-login` | AttendanceLogin | Staff/admin login page for attendance system. Separate authentication from main builder login. Required for accessing admin attendance features. |

## Admin Routes

| Route | Purpose |
|---|---|
| `/admin-attendance-dashboard` | Admin dashboard with 3 tabs: Today's Attendance (real-time view), Cohort Performance (analytics), Attendance Management (history and manual records) |

### Admin Dashboard Tabs

- **Today's Attendance**: Real-time view of today's check-ins, filter by cohort, see present/late/absent status, view check-in times, access builder photos
- **Cohort Performance**: Attendance rates per cohort, trend analysis over time, late arrival patterns, absence frequency, comparison charts
- **Attendance Management**: View attendance history, create manual records, edit existing records, delete records, bulk operations

---

## Controllers

### attendanceController

- `POST` login
- `GET` builder search
- `POST` check-in with photo
- `GET` today's records
- `POST` photo cleanup

### attendanceManagementController

- `GET` attendance history
- `POST` create manual record
- `PUT` update record
- `DELETE` delete record

### excuseController

- `POST` mark excused
- `GET` pending excuses
- `GET` excuse history
- `POST` bulk excuse
- `GET` excuse statistics

---

## API Endpoints

### /api/attendance/* (Builder & Staff)

- `POST /login` — Staff login
- `GET /search` — Builder search
- `POST /check-in` — Check-in with photo
- `GET /today` — Today's records
- `POST /cleanup-photos` — Photo cleanup

### /api/admin/attendance/manage/* (Admin)

- `GET /history` — Attendance history
- `POST /records` — Create manual record
- `PUT /records/:id` — Update record
- `DELETE /records/:id` — Delete record

### /api/admin/excuses/* (Admin)

- `POST /mark-excused` — Mark absence as excused
- `GET /pending` — List pending excuses
- `GET /history` — Excuse history
- `POST /bulk` — Bulk excuse operations
- `GET /statistics` — Excuse statistics

---

## Database Tables (3 core tables)

### Builder Attendance

- **builder_attendance_new** — Daily attendance records
  - `attendance_id` PRIMARY KEY
  - `user_id` FK to users
  - `attendance_date` — Date of attendance
  - `check_in_time` — Timestamp of check-in
  - `photo_url` — Photo from check-in
  - `late_arrival_minutes` — Minutes late
  - `status` — present/late/absent/excused
  - `notes` — Additional notes
  - **UNIQUE:** user_id + attendance_date

### Excused Absences

- **excused_absences** — Excuse requests and approvals
  - `excuse_id` PRIMARY KEY
  - `attendance_id` FK to attendance
  - `user_id` FK to users
  - `absence_date` — Date of absence
  - `excuse_reason` — Sick/Personal/Program Event/Technical Issue/Other
  - `excuse_details` — Details text
  - `staff_notes` — Staff notes
  - `processed_by` FK to users
  - `status` — pending/approved/denied
  - **UNIQUE:** user_id + absence_date

### Volunteer Attendance

- **volunteer_attendance** — Volunteer slot attendance
  - `attendance_id` PRIMARY KEY
  - `slot_id` FK to volunteer slots
  - `volunteer_user_id` FK to users
  - `status` — pending/attended/no_show/cancelled/excused
  - `checked_in_at` — Check-in timestamp
  - `photo_url` — Photo URL
  - **UNIQUE:** slot_id + volunteer_user_id

---

## Key Files

### Client (`pilot-client/src/`)

- `pages/Attendance/AttendanceDashboard.jsx` — Builder check-in interface
- `pages/Attendance/AttendanceLogin.jsx` — Staff login page
- `pages/Admin/AdminAttendanceDashboard.jsx` — Admin dashboard

### Server (`test-pilot-server/`)

- `controllers/attendanceController.js` — Check-in and today's records
- `controllers/attendanceManagementController.js` — Manual record CRUD
- `controllers/excuseController.js` — Excuse management
- `routes/attendanceRoutes.js` — Route definitions
- `queries/attendance.js` — Database queries

---

## Related Visual Guides

- `system-overview.md` — Markdown version of this guide for agent consumption
- `schema.sql` — Complete DDL for all attendance-related tables
