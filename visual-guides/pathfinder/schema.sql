-- ============================================================
-- Pathfinder (Career Development) – Database Schema
-- ============================================================

-- Companies directory
CREATE TABLE IF NOT EXISTS companies (
    company_id    SERIAL PRIMARY KEY,
    name          TEXT NOT NULL,
    domain        TEXT,
    logo_url      TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_companies_name ON companies (name);
CREATE INDEX idx_companies_domain ON companies (domain);

-- Job applications
CREATE TABLE IF NOT EXISTS job_applications (
    application_id   SERIAL PRIMARY KEY,
    user_id          INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    company_id       INTEGER REFERENCES companies(company_id),
    company_name     TEXT,
    job_title        TEXT NOT NULL,
    job_url          TEXT,
    job_description  TEXT,
    stage            TEXT NOT NULL DEFAULT 'prospect'
                     CHECK (stage IN (
                         'prospect','applied','screen','oa',
                         'interview','offer','accepted','rejected','withdrawn'
                     )),
    stage_history    JSONB DEFAULT '[]'::jsonb,
    salary_min       NUMERIC,
    salary_max       NUMERIC,
    salary_currency  TEXT DEFAULT 'USD',
    location         TEXT,
    remote           BOOLEAN DEFAULT false,
    contact_name     TEXT,
    contact_email    TEXT,
    contact_phone    TEXT,
    notes            TEXT,
    applied_date     DATE,
    deadline         DATE,
    is_active        BOOLEAN NOT NULL DEFAULT true,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_job_applications_user   ON job_applications (user_id);
CREATE INDEX idx_job_applications_stage  ON job_applications (stage);
CREATE INDEX idx_job_applications_company ON job_applications (company_id);

-- Interviews linked to applications
CREATE TABLE IF NOT EXISTS interviews (
    interview_id     SERIAL PRIMARY KEY,
    application_id   INTEGER NOT NULL REFERENCES job_applications(application_id) ON DELETE CASCADE,
    user_id          INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    interview_date   TIMESTAMPTZ,
    interview_type   TEXT,
    interviewer_name TEXT,
    interviewer_title TEXT,
    location         TEXT,
    notes            TEXT,
    feedback         TEXT,
    status           TEXT DEFAULT 'scheduled'
                     CHECK (status IN ('scheduled','completed','cancelled','no_show')),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_interviews_application ON interviews (application_id);
CREATE INDEX idx_interviews_user        ON interviews (user_id);

-- Networking activities ("Hustles")
CREATE TABLE IF NOT EXISTS networking_activities (
    activity_id      SERIAL PRIMARY KEY,
    user_id          INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    application_id   INTEGER REFERENCES job_applications(application_id),
    activity_type    TEXT NOT NULL CHECK (activity_type IN ('digital','irl')),
    contact_name     TEXT,
    contact_email    TEXT,
    contact_linkedin TEXT,
    company_name     TEXT,
    title            TEXT,
    description      TEXT,
    event_url        TEXT,
    follow_up_date   DATE,
    follow_up_notes  TEXT,
    notes            TEXT,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_networking_user ON networking_activities (user_id);
CREATE INDEX idx_networking_app  ON networking_activities (application_id);

-- Builder projects
CREATE TABLE IF NOT EXISTS pathfinder_projects (
    project_id       SERIAL PRIMARY KEY,
    user_id          INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    application_id   INTEGER REFERENCES job_applications(application_id),
    title            TEXT NOT NULL,
    description      TEXT,
    project_url      TEXT,
    repo_url         TEXT,
    stage            TEXT NOT NULL DEFAULT 'ideation'
                     CHECK (stage IN ('ideation','planning','development','testing','launch')),
    prd_content      TEXT,
    prd_submitted    BOOLEAN DEFAULT false,
    prd_submitted_at TIMESTAMPTZ,
    prd_approved     BOOLEAN DEFAULT false,
    prd_approved_by  INTEGER REFERENCES users(id),
    prd_approved_at  TIMESTAMPTZ,
    launch_checklist JSONB DEFAULT '{}'::jsonb,
    technologies     JSONB DEFAULT '[]'::jsonb,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_projects_user  ON pathfinder_projects (user_id);
CREATE INDEX idx_projects_stage ON pathfinder_projects (stage);

-- Events (EventHub)
CREATE TABLE IF NOT EXISTS pathfinder_events (
    event_id         SERIAL PRIMARY KEY,
    title            TEXT NOT NULL,
    description      TEXT,
    event_date       TIMESTAMPTZ,
    end_date         TIMESTAMPTZ,
    location         TEXT,
    event_url        TEXT,
    event_type       TEXT,
    source           TEXT CHECK (source IN ('staff','builder','hustle')),
    created_by       INTEGER REFERENCES users(id),
    is_featured      BOOLEAN DEFAULT false,
    is_active        BOOLEAN DEFAULT true,
    max_attendees    INTEGER,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_events_date    ON pathfinder_events (event_date);
CREATE INDEX idx_events_source  ON pathfinder_events (source);
CREATE INDEX idx_events_active  ON pathfinder_events (is_active);

-- Event RSVPs
CREATE TABLE IF NOT EXISTS pathfinder_event_rsvps (
    rsvp_id     SERIAL PRIMARY KEY,
    event_id    INTEGER NOT NULL REFERENCES pathfinder_events(event_id) ON DELETE CASCADE,
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status      TEXT NOT NULL DEFAULT 'registered'
                CHECK (status IN ('registered','attended','cancelled','no_show')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (event_id, user_id)
);

CREATE INDEX idx_rsvps_event ON pathfinder_event_rsvps (event_id);
CREATE INDEX idx_rsvps_user  ON pathfinder_event_rsvps (user_id);

-- Event tags / topics
CREATE TABLE IF NOT EXISTS pathfinder_event_tags (
    tag_id      SERIAL PRIMARY KEY,
    event_id    INTEGER NOT NULL REFERENCES pathfinder_events(event_id) ON DELETE CASCADE,
    tag_name    TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_event_tags_event ON pathfinder_event_tags (event_id);
