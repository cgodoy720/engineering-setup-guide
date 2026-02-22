# Volunteer Management System — Overview

## Architecture

The Volunteer Management system coordinates volunteer participation in classes, events, and activities. It supports both volunteer self-service (signup, schedule viewing, check-in) and staff management (slot assignment, attendance tracking, feedback collection). Volunteers can be assigned to multiple cohorts and slots are generated from curriculum days.

### Tech Stack

- **Client**: React 19 + Vite, MUI v7, Tailwind, React Router v6, React Query
- **Server**: Express.js, PostgreSQL (pg-promise), JWT auth

---

## Volunteer-Facing Routes

| Route | Component | Purpose |
|---|---|---|
| `/volunteering` | VolunteerDashboard | Volunteer dashboard with tabs: Schedule (view assigned slots), Check-in (self check-in with photo), Feedback (submit feedback for sessions). |

## Staff Routes

| Route | Purpose |
|---|---|
| `/volunteer-management` | Staff dashboard with tabs: List (volunteer profiles, cohort assignments), Calendar (slot management, generate from curriculum), Attendance (check-in management, bulk operations, stats), Feedback (view and manage feedback submissions). |

---

## Controllers

### Roster
- **volunteerRosterController** — Signup, profiles, cohort management, auto-assign

### Slots
- **volunteerSlotController** — Slot CRUD, generate from curriculum, self-assign, confirm

### Attendance
- **volunteerAttendanceController** — Check-in (self+staff), bulk, stats, today

### Feedback
- **volunteerFeedbackController** — Feedback CRUD, types (AI Native Class, Demo Day, etc.)

---

## API Endpoints

### /api/volunteers

- `GET /` — List volunteers
- `GET /:id` — Get volunteer profile
- `POST /signup` — Volunteer signup
- `PUT /:id` — Update profile
- `GET /cohorts` — List cohorts
- `POST /cohorts/:cohort/assign` — Assign to cohort
- `POST /auto-assign` — Auto-assign volunteers

### /api/volunteer-slots

- `GET /` — List slots
- `POST /` — Create slot
- `PUT /:id` — Update slot
- `DELETE /:id` — Delete slot
- `POST /generate-from-curriculum` — Generate slots from curriculum
- `POST /:id/self-assign` — Self-assign to slot
- `POST /:id/confirm` — Confirm assignment

### /api/volunteer-attendance

- `GET /` — List attendance
- `POST /check-in` — Self check-in
- `PUT /:id` — Update attendance (staff)
- `POST /bulk` — Bulk update
- `GET /stats` — Attendance statistics
- `GET /today` — Today's attendance

### /api/volunteer-feedback

- `GET /` — List feedback
- `POST /` — Submit feedback
- `PUT /:id` — Update feedback
- `DELETE /:id` — Delete feedback
- `GET /types` — List feedback types

---

## Database Tables (6 core tables)

### Volunteer Profiles (2 tables)

- **volunteer_profiles** — Phone, availability JSONB, skills JSONB (array), bio, staff_notes, preferred_contact_method, timezone, professional_background, linkedin_url
- **volunteer_cohort_assignments** — Volunteer-to-cohort many-to-many assignments. UNIQUE on user_id + cohort_name, is_active flag, assigned_by tracking

### Slots & Attendance (2 tables)

- **volunteer_class_slots** — Class session slots with volunteer assignments, generated from curriculum. Links to curriculum_days for prep content. Slot types: class_support, demo_day, networking, mock_interview, panel. Status: open/assigned/confirmed/cancelled/completed
- **volunteer_attendance** — Status: pending/attended/no_show/cancelled/excused. Check-in photos, checked_in_by (staff), session_rating, quick_notes. UNIQUE on slot_id + volunteer_user_id

### Email & Feedback (2 tables)

- **volunteer_email_log** — Prep emails, reminders (24h, 48h), confirmations, thank_you, schedule_change. Email tracking (opened_at, clicked_at), status tracking (pending/sent/delivered/opened/failed/bounced)
- **volunteer_feedback** — Feedback CRUD. Types: AI Native Class, Demo Day, Networking Event, Panel, Mock Interview. Overall experience, improvement suggestions, specific feedback, audio_recording_url

### Views

- **volunteers_full_view** — Combined volunteer data view
- **volunteer_schedule_view** — Schedule view for volunteers
- **volunteer_attendance_summary** — Attendance summary statistics

---

## Key Files

### Client (`pilot-client/src/`)

- `pages/Volunteering/VolunteerDashboard.jsx` — Volunteer dashboard
- `pages/VolunteerManagement/VolunteerManagementDashboard.jsx` — Staff dashboard

### Server (`test-pilot-server/`)

- `controllers/volunteerRosterController.js` — Volunteer profiles and cohort management
- `controllers/volunteerSlotController.js` — Slot management
- `controllers/volunteerAttendanceController.js` — Attendance tracking
- `controllers/volunteerFeedbackController.js` — Feedback management
- `queries/volunteers.js` — Database queries
- `routes/volunteerRoutes.js` — Route definitions
- `db/migrations/030_volunteer_management_schema.sql` — Full schema DDL

---

## Related Visual Guides

- `system-overview.html` — Visual overview with diagrams
- `schema.sql` — Complete DDL for all Volunteer Management tables
