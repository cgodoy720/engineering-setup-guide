# Sales & Outreach System — Overview

## Architecture

The Sales & Outreach system manages lead tracking, job postings, and sales team performance. It provides a comprehensive dashboard for staff to track outreach activities, manage leads through various stages, monitor job postings, and view leaderboard rankings.

### Tech Stack

- **Client**: React 19 + Vite, MUI v7, Tailwind, React Router v6, React Query
- **Server**: Express.js, PostgreSQL (pg-promise), JWT auth
- **Permission**: All routes require `page:staff_section`

---

## SalesTracker Page

### Route: `/sales-tracker`

Tabbed interface for managing sales and outreach activities. Requires `page:staff_section` permission.

### Tabs

- **Dashboard** — Stats overview (period filter), recent activity feed, quick metrics
- **All Leads** — Lead listing with filters (search, stage, owner), CRUD operations, CSV export
- **Job Postings** — Job posting management, CRUD operations, builder assignments, status tracking
- **Leaderboard** — Staff performance rankings, period-based filtering, metrics comparison

---

## Controller: salesTrackerController

### Methods

- **getDashboardStats** — Dashboard statistics with period filtering, aggregated metrics, activity summaries
- **getDashboardActivity** — Recent activity feed with limit-based pagination, action type filtering, chronological ordering
- **getLeads** — List leads with filters (search, stage, owner), pagination
- **createLead** — Create new lead with contact info, company, stage assignment, source tracking
- **updateLead** — Update lead details (stage changes, notes, response notes, owner assignment)
- **deleteLead** — Delete lead with cascade handling, activity logging
- **exportLeads** — CSV export with filtered export, all lead fields, formatted CSV
- **getJobPostings** — List job postings with status filtering, owner filtering, pagination
- **createJobPosting** — Create job posting with company, title, URL, salary, location, sector alignment
- **updateJobPosting** — Update job posting (status changes, sharing flags, builder assignments)
- **deleteJobPosting** — Delete job posting with cascade handling, builder relationship cleanup
- **getLeaderboard** — Staff leaderboard with period filtering, ranking metrics, performance stats
- **getStaffUsers** — Staff dropdown data with active staff list, user details for assignment

---

## API Routes

All routes require `page:staff_section` permission.

### Dashboard

- `GET /api/sales-tracker/dashboard/stats?period=` — Dashboard statistics
- `GET /api/sales-tracker/dashboard/activity?limit=` — Recent activity feed

### Leads

- `GET /api/sales-tracker/leads` — List leads with filters
- `POST /api/sales-tracker/leads` — Create new lead
- `GET /api/sales-tracker/leads/:leadId` — Get lead details
- `PUT /api/sales-tracker/leads/:leadId` — Update lead
- `DELETE /api/sales-tracker/leads/:leadId` — Delete lead
- `GET /api/sales-tracker/leads/export` — CSV export

### Job Postings

- `GET /api/sales-tracker/job-postings` — List job postings
- `POST /api/sales-tracker/job-postings` — Create job posting
- `GET /api/sales-tracker/job-postings/:jobId` — Get job posting details
- `PUT /api/sales-tracker/job-postings/:jobId` — Update job posting
- `DELETE /api/sales-tracker/job-postings/:jobId` — Delete job posting

### Leaderboard & Staff

- `GET /api/sales-tracker/leaderboard?period=` — Staff leaderboard
- `GET /api/sales-tracker/staff-users` — Staff dropdown data

---

## Database Tables (5 core tables)

### Lead Management

- **outreach** — Lead records with stages, sources, sectors, notes
  - Columns: id (PK), staff_user_id (FK), contact_name, company_name, contact_email, linkedin_url, stage, source (JSONB), aligned_sector (JSONB), notes, response_notes, is_migrated
  - Stages: 'Initial Outreach', 'Active Lead', 'Follow Up', 'Qualified', 'Not Interested', 'Closed'
- **st_activities** — Activity log for all user actions
  - Columns: id (PK), user_id (FK), user_name, action_type, entity_type, entity_name, details (JSONB), is_migrated

### Job Postings

- **job_postings** — Job posting records with company, title, URL, status
  - Columns: id (PK), staff_user_id (FK), outreach_id (FK nullable), company_name, job_title, job_url, status, salary_range, location, aligned_sector (TEXT), is_shared, shared_date, is_migrated
- **job_posting_builders** — Builder assignments to job postings
  - Columns: job_posting_id (FK), builder_user_id (FK), status ('Shared'), shared_date, applied_date, notes

### Sync & Tracking

- **sales_tracker_sync_log** — Sync state tracking for data migration
  - Columns: id (PK), table_name, last_synced_id, records_synced

---

## Key Files

### Client (`pilot-client/src/`)

- `pages/SalesTracker/SalesTracker.jsx` — Main SalesTracker page with tabs

### Server (`test-pilot-server/`)

- `controllers/salesTrackerController.js` — API logic for all SalesTracker operations
- `routes/salesTrackerRoutes.js` — Route definitions
- `queries/salesTracker.js` — Database queries

---

## Related Visual Guides

- `system-overview.html` — Visual guide with architecture diagrams
- `schema.sql` — Complete DDL for all Sales & Outreach tables
