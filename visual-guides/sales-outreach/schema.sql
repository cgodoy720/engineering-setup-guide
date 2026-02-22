-- ============================================================
-- SALES & OUTREACH SYSTEM — DATABASE SCHEMA
-- PostgreSQL DDL for all Sales & Outreach-related tables
-- ============================================================

-- ─── LEAD MANAGEMENT ────────────────────────────────────────

CREATE TABLE outreach (
    id SERIAL PRIMARY KEY,
    staff_user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE SET NULL,
    contact_name VARCHAR(255),
    company_name VARCHAR(255),
    contact_email VARCHAR(255),
    linkedin_url TEXT,
    stage VARCHAR(50) NOT NULL DEFAULT 'Initial Outreach',
    source JSONB DEFAULT '{}',
    aligned_sector JSONB DEFAULT '[]',
    notes TEXT,
    response_notes TEXT,
    is_migrated BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT outreach_stage_check CHECK (stage IN (
        'Initial Outreach', 'Active Lead', 'Follow Up', 'Qualified', 'Not Interested', 'Closed'
    ))
);

CREATE INDEX idx_outreach_staff_user_id ON outreach(staff_user_id);
CREATE INDEX idx_outreach_stage ON outreach(stage);
CREATE INDEX idx_outreach_company_name ON outreach(company_name);
CREATE INDEX idx_outreach_contact_email ON outreach(contact_email);
CREATE INDEX idx_outreach_is_migrated ON outreach(is_migrated);

CREATE TABLE st_activities (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE SET NULL,
    user_name VARCHAR(255),
    action_type VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_name VARCHAR(255),
    details JSONB DEFAULT '{}',
    is_migrated BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_st_activities_user_id ON st_activities(user_id);
CREATE INDEX idx_st_activities_action_type ON st_activities(action_type);
CREATE INDEX idx_st_activities_entity_type ON st_activities(entity_type);
CREATE INDEX idx_st_activities_created_at ON st_activities(created_at);
CREATE INDEX idx_st_activities_is_migrated ON st_activities(is_migrated);

-- ─── JOB POSTINGS ──────────────────────────────────────────

CREATE TABLE job_postings (
    id SERIAL PRIMARY KEY,
    staff_user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE SET NULL,
    outreach_id INTEGER REFERENCES outreach(id) ON DELETE SET NULL,
    company_name VARCHAR(255) NOT NULL,
    job_title VARCHAR(255) NOT NULL,
    job_url TEXT,
    status VARCHAR(50),
    salary_range VARCHAR(100),
    location VARCHAR(255),
    aligned_sector TEXT,
    is_shared BOOLEAN DEFAULT false,
    shared_date TIMESTAMP,
    is_migrated BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_job_postings_staff_user_id ON job_postings(staff_user_id);
CREATE INDEX idx_job_postings_outreach_id ON job_postings(outreach_id);
CREATE INDEX idx_job_postings_status ON job_postings(status);
CREATE INDEX idx_job_postings_company_name ON job_postings(company_name);
CREATE INDEX idx_job_postings_is_shared ON job_postings(is_shared);
CREATE INDEX idx_job_postings_is_migrated ON job_postings(is_migrated);

CREATE TABLE job_posting_builders (
    job_posting_id INTEGER NOT NULL REFERENCES job_postings(id) ON DELETE CASCADE,
    builder_user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'Shared',
    shared_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    applied_date TIMESTAMP,
    notes TEXT,
    PRIMARY KEY (job_posting_id, builder_user_id),
    CONSTRAINT job_posting_builders_status_check CHECK (status = 'Shared')
);

CREATE INDEX idx_job_posting_builders_job_posting_id ON job_posting_builders(job_posting_id);
CREATE INDEX idx_job_posting_builders_builder_user_id ON job_posting_builders(builder_user_id);
CREATE INDEX idx_job_posting_builders_status ON job_posting_builders(status);

-- ─── SYNC & TRACKING ───────────────────────────────────────

CREATE TABLE sales_tracker_sync_log (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    last_synced_id INTEGER,
    records_synced INTEGER DEFAULT 0,
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(table_name)
);

CREATE INDEX idx_sales_tracker_sync_log_table_name ON sales_tracker_sync_log(table_name);
