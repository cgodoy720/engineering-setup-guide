# Weekly Reports System — Overview

## Architecture

The Weekly Reports system generates automated weekly reports for cohorts, including attendance overview, at-risk builders, activities completion, assessments, and AI-generated narrative insights using Claude Sonnet 4.5. Reports are delivered via HTML email with CSV attachments and optional Slack notifications.

### Tech Stack

- **Client**: React 19 + Vite, MUI v7, Tailwind, React Router v6, React Query
- **Server**: Express.js, PostgreSQL (pg-promise), JWT auth
- **Controllers**: `weeklyReportController.js`, `weeklyReportService.js`
- **AI**: Claude Sonnet 4.5 for narrative insights

---

## Pages

| Route | Component | Purpose |
|---|---|---|
| `/admin/weekly-reports` | WeeklyReports | Admin dashboard for managing weekly report configurations, Slack settings, recipients, viewing report logs, and manually triggering reports. Requires `page:weekly_reports` permission. Features include: config management (week start/end days, enable/disable), Slack channel selection and testing, recipient management (add/edit/remove), report log viewing with status and error messages, manual trigger for single cohort or all cohorts, and cohort lookup (active non-workshop cohorts only). |

---

## Report Generation Flow

1. **Cron Job** → Runs Fridays at 6:00 PM ET
2. **Check Enabled** → Skip cohorts with reports disabled
3. **Calculate Week** → Determine week start/end dates based on cohort schedule (week_start_day, week_end_day, 0-6 where Sunday=0)
4. **Gather Data** → Collect:
   - Attendance overview
   - At-risk builders (based on attendance thresholds)
   - Activities and completion rates
   - Graded activities and assessments
5. **AI Insights** → Generate narrative insights using Claude Sonnet 4.5 (currently hidden in email but generated)
6. **Generate Report** → Create HTML report with all data
7. **Generate CSV** → Create CSV attachment
8. **Get Recipients** → Retrieve active recipients for cohort
9. **Send Email** → Deliver HTML email with CSV attachment
10. **Send Slack** → If Slack enabled, send notification to configured channel
11. **Log Report** → Record delivery status, channels, and any errors

### Report Content

- **Attendance Overview**: Summary of attendance rates and patterns
- **At-Risk Builders**: Builders falling below attendance thresholds
- **Activities & Completion**: Activity completion rates and statistics
- **Graded Activities**: Performance on graded assignments
- **Assessments**: Assessment results and trends
- **AI Narrative Insights**: Claude Sonnet 4.5 generated insights (currently hidden in email)

**Note**: External cohorts are excluded from reports.

---

## API Endpoints

All endpoints require `page:weekly_reports` permission.

### Config Management (`/api/admin/weekly-reports`)

- `GET /configs` — Get all report configurations
- `PATCH /configs/:cohortId/toggle` — Toggle report enabled/disabled
- `PATCH /configs/:cohortId` — Update config (week_start_day, week_end_day, etc.)

### Slack Management

- `GET /slack/channels` — Get available Slack channels
- `PATCH /configs/:cohortId/slack` — Update Slack configuration (channel_id, enabled)
- `POST /slack/test` — Test Slack notification

### Recipients

- `GET /recipients/:cohortId` — Get recipients for a cohort
- `POST /recipients` — Add recipient (cohort_id, email, name, user_id optional)
- `PATCH /recipients/:id` — Update recipient (email, name, active)
- `DELETE /recipients/:id` — Remove recipient

### Report Logs

- `GET /logs/:cohortId` — Get report logs for a cohort (status, error messages, delivery channels)

### Manual Triggers

- `POST /trigger/:cohortId` — Manually trigger report generation for a single cohort
- `POST /trigger-all` — Manually trigger reports for all enabled cohorts

### Cohorts

- `GET /cohorts` — Get active non-workshop cohorts (for dropdown/selection)

---

## Database Tables (3 total)

### weekly_report_config

Per-cohort configuration for weekly reports. Includes week calculation settings, enable/disable flag, and Slack settings. UNIQUE constraint on cohort_id ensures one config per cohort.

- **id** (SERIAL PK)
- **cohort_id** (UUID FK → cohort, UNIQUE NOT NULL)
- **week_start_day** (INTEGER, 0-6 where Sunday=0)
- **week_end_day** (INTEGER, 0-6)
- **report_enabled** (BOOLEAN DEFAULT true)
- **slack_channel_id** (VARCHAR)
- **slack_enabled** (BOOLEAN DEFAULT false)
- **created_at** (TIMESTAMP)
- **updated_at** (TIMESTAMP)

### weekly_report_recipients

Email recipients for weekly reports per cohort. Can be linked to a user account (user_id nullable) or just an email address. UNIQUE constraint on cohort_id + email ensures no duplicate recipients per cohort.

- **id** (SERIAL PK)
- **cohort_id** (UUID FK → cohort, NOT NULL)
- **user_id** (INTEGER FK → users, nullable)
- **email** (VARCHAR NOT NULL)
- **name** (VARCHAR)
- **active** (BOOLEAN DEFAULT true)
- **added_by** (INTEGER FK → users)
- **created_at** (TIMESTAMP)
- **updated_at** (TIMESTAMP)
- **UNIQUE(cohort_id, email)**

### weekly_report_log

Logs of all report generations and deliveries. Stores report data as JSONB, tracks delivery status, error messages, and delivery channels as JSONB object.

- **id** (SERIAL PK)
- **cohort_id** (UUID FK → cohort, NOT NULL)
- **week_start_date** (DATE NOT NULL)
- **week_end_date** (DATE NOT NULL)
- **recipients_count** (INTEGER)
- **report_data** (JSONB) — Full report data including attendance, activities, assessments, AI insights
- **status** (VARCHAR NOT NULL) — pending/sent/failed
- **error_message** (TEXT)
- **delivery_channels** (JSONB) — {email: bool, slack: bool}
- **created_at** (TIMESTAMP DEFAULT CURRENT_TIMESTAMP)

---

## Controllers & Services

### weeklyReportController

Handles HTTP requests for:
- Config management (CRUD)
- Slack configuration and testing
- Recipient management (CRUD)
- Report log retrieval
- Manual report triggers
- Cohort lookup

### weeklyReportService

Core service for report generation:
- **generateReport(cohortId)** — Main report generation function
- **calculateWeekDates(cohortId)** — Determine week start/end based on cohort schedule
- **gatherAttendanceData(cohortId, weekStart, weekEnd)** — Collect attendance overview
- **identifyAtRiskBuilders(cohortId, weekStart, weekEnd)** — Find builders below thresholds
- **gatherActivitiesData(cohortId, weekStart, weekEnd)** — Collect activity completion
- **gatherAssessmentsData(cohortId, weekStart, weekEnd)** — Collect assessment results
- **generateAIInsights(data)** — Use Claude Sonnet 4.5 to generate narrative insights
- **formatHTMLReport(data)** — Format report as HTML
- **generateCSV(data)** — Generate CSV attachment
- **sendEmail(recipients, html, csv)** — Send HTML email with CSV
- **sendSlack(channelId, data)** — Send Slack notification
- **logReport(cohortId, data, status, error)** — Log report delivery

---

## Key Features

- **Automated Scheduling**: Cron job runs Fridays at 6:00 PM ET
- **Flexible Week Calculation**: Configurable week start/end days per cohort (0-6, Sunday=0)
- **Comprehensive Data**: Attendance, at-risk builders, activities, assessments
- **AI Insights**: Claude Sonnet 4.5 generated narrative insights (currently hidden in email)
- **Dual Delivery**: HTML email with CSV attachment + optional Slack notifications
- **Manual Triggers**: Admin can manually trigger reports for single or all cohorts
- **Delivery Tracking**: Logs track status, errors, and delivery channels
- **External Cohort Exclusion**: External cohorts are automatically excluded

---

## Related Visual Guides

- `system-overview.html` — Visual guide with diagrams and detailed explanations
- `schema.sql` — Complete DDL for all weekly reports-related tables
