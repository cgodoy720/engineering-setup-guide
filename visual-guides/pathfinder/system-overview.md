# Pathfinder System — Overview

## Architecture

Pathfinder is a comprehensive career development system that helps builders track job applications, manage networking activities ("Hustle Tracker"), build project portfolios, discover events, and monitor their career progress. It includes both builder-facing dashboards and staff admin tools.

### Tech Stack

- **Client**: React 19 + Vite, MUI v7, Tailwind, React Router v6, React Query
- **Server**: Express.js, PostgreSQL (pg-promise), JWT auth

---

## Builder-Facing Routes

| Route | Component | Purpose |
|---|---|---|
| `/pathfinder` | PathfinderContainer | Main container with nested routes. Entry point for all Pathfinder features. |
| `/pathfinder/dashboard` | PathfinderDashboard | Personal dashboard with stats, milestones, application funnel, networking activity, project progress. |
| `/pathfinder/applications` | Applications | Job applications tracking. CRUD operations, stage management (prospect→applied→screen→oa→interview→offer→accepted/rejected/withdrawn), contacts, salary tracking, stage history. |
| `/pathfinder/networking` | Networking | "Hustle Tracker" for networking activities. Digital (LinkedIn, email) and IRL (events, coffee chats) tracking. Contacts, follow-ups, URL parsing, outcome tracking. |
| `/pathfinder/projects` | Projects | Project portfolio management. Stages: ideation→planning→development→testing→launch. PRD approval workflow, launch checklist. |
| `/pathfinder/events` | EventHub | Event discovery and RSVP. Browse tech events, filter by topics, RSVP, link to networking activities. |

## Admin Routes

| Route | Purpose |
|---|---|
| `/pathfinder/admin` | Admin dashboard for staff. Overview, builders, companies, roles, timeline, export, leaderboard. |

---

## Controllers

### Applications
- **pathfinderApplicationsController** — Job CRUD, stats, dashboard
- **pathfinderInterviewsController** — Interview tracking
- **jobScrapingController** — URL-based job scraping

### Networking
- **pathfinderNetworkingController** — Networking activities CRUD, contacts, follow-ups, URL parsing

### Projects
- **pathfinderProjectsController** — Projects CRUD, PRD workflow, launch checklist

### Events
- **pathfinderEventHubController** — Events CRUD, RSVP, topics, URL parsing

### Admin
- **pathfinderAdminController** — Overview, builders, companies, roles, timeline, export, leaderboard

### Companies
- **companiesController** — Company search, logos

---

## API Endpoints

### /api/pathfinder/applications

- `GET /` — List applications
- `POST /` — Create application
- `PUT /:id` — Update application
- `DELETE /:id` — Delete application
- `GET /stats` — Dashboard statistics
- `GET /dashboard` — Dashboard data

### /api/pathfinder/networking

- `GET /` — List activities
- `POST /` — Create activity
- `PUT /:id` — Update activity
- `DELETE /:id` — Delete activity
- `POST /parse-url` — Parse URL for activity

### /api/pathfinder/projects

- `GET /` — List projects
- `POST /` — Create project
- `PUT /:id` — Update project
- `DELETE /:id` — Delete project
- `POST /:id/submit-prd` — Submit PRD
- `POST /:id/approve-prd` — Approve PRD (admin)

### /api/pathfinder/events

- `GET /` — List events
- `POST /` — Create event
- `PUT /:id` — Update event
- `DELETE /:id` — Delete event
- `POST /:id/rsvp` — RSVP to event
- `GET /topics` — List topics
- `POST /parse-url` — Parse event URL

### /api/pathfinder/admin

- `GET /overview` — Admin overview stats
- `GET /builders` — Builder list
- `GET /companies` — Company list
- `GET /roles` — Role analytics
- `GET /timeline` — Timeline view
- `GET /export` — Export data
- `GET /leaderboard` — Leaderboard

### /api/companies

- `GET /search` — Search companies
- `GET /:id/logo` — Get company logo

---

## Database Tables (8 core tables)

### Job Applications (2 tables)

- **job_applications** — Stages: prospect→applied→screen→oa→interview→offer→accepted/rejected/withdrawn. Contacts, salary, stage history JSONB, job URL, source tracking
- **interviews** — Linked to applications, interviewer info, feedback, content type

### Networking (1 table)

- **networking_activities** — Digital/IRL activities, contacts, follow-ups, URL parsing, outcome tracking, connection strength, linked job applications

### Projects (1 table)

- **builder_projects** — Stages: ideation→planning→development→testing→launch. PRD approval workflow, launch checklist JSONB, lookbook content

### Events (3 tables)

- **pathfinder_events** — Staff/builder created events, shared from hustles. Topics array, location type, virtual links, featured events
- **pathfinder_event_rsvps** — Builder RSVPs and attendance. Registration status: interested/attending/attended/cancelled
- **pathfinder_event_tags** — Topic tags for event categorization (AI/ML, Web Development, Networking, etc.)

### Companies (1 table)

- **companies** — Company search, logos, domains, times_used counter

---

## Key Files

### Client (`pilot-client/src/`)

- `pages/Pathfinder/PathfinderContainer.jsx` — Main container
- `pages/Pathfinder/PathfinderDashboard.jsx` — Dashboard
- `pages/Pathfinder/Applications.jsx` — Applications page
- `pages/Pathfinder/Networking.jsx` — Networking page
- `pages/Pathfinder/Projects.jsx` — Projects page
- `pages/Pathfinder/EventHub.jsx` — Events page
- `pages/Pathfinder/PathfinderAdmin.jsx` — Admin dashboard

### Server (`test-pilot-server/`)

- `controllers/pathfinderApplicationsController.js` — Applications API
- `controllers/pathfinderInterviewsController.js` — Interviews API
- `controllers/pathfinderNetworkingController.js` — Networking API
- `controllers/pathfinderProjectsController.js` — Projects API
- `controllers/pathfinderEventHubController.js` — Events API
- `controllers/pathfinderAdminController.js` — Admin API
- `controllers/jobScrapingController.js` — Job scraping
- `controllers/companiesController.js` — Company search
- `queries/pathfinder.js` — Database queries
- `routes/pathfinderRoutes.js` — Route definitions
- `db/pathfinder-complete-deployment-schema.sql` — Full schema DDL

---

## Related Visual Guides

- `system-overview.html` — Visual overview with diagrams
- `schema.sql` — Complete DDL for all Pathfinder tables
