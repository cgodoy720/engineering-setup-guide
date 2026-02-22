-- ============================================================
-- WEEKLY REPORTS SYSTEM — DATABASE SCHEMA
-- PostgreSQL DDL for all weekly reports-related tables
-- ============================================================

-- ─── REPORT CONFIGURATION ─────────────────────────────────

CREATE TABLE weekly_report_config (
    id SERIAL PRIMARY KEY,
    cohort_id UUID NOT NULL REFERENCES cohort(cohort_id) ON DELETE CASCADE,
    week_start_day INTEGER NOT NULL DEFAULT 0 CHECK (week_start_day >= 0 AND week_start_day <= 6),
    week_end_day INTEGER NOT NULL DEFAULT 6 CHECK (week_end_day >= 0 AND week_end_day <= 6),
    report_enabled BOOLEAN DEFAULT true,
    slack_channel_id VARCHAR(255),
    slack_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(cohort_id)
);

CREATE INDEX idx_weekly_report_config_cohort_id ON weekly_report_config(cohort_id);
CREATE INDEX idx_weekly_report_config_enabled ON weekly_report_config(report_enabled) WHERE report_enabled = true;

-- ─── REPORT RECIPIENTS ─────────────────────────────────────

CREATE TABLE weekly_report_recipients (
    id SERIAL PRIMARY KEY,
    cohort_id UUID NOT NULL REFERENCES cohort(cohort_id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    active BOOLEAN DEFAULT true,
    added_by INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(cohort_id, email)
);

CREATE INDEX idx_weekly_report_recipients_cohort_id ON weekly_report_recipients(cohort_id);
CREATE INDEX idx_weekly_report_recipients_email ON weekly_report_recipients(email);
CREATE INDEX idx_weekly_report_recipients_active ON weekly_report_recipients(active) WHERE active = true;
CREATE INDEX idx_weekly_report_recipients_user_id ON weekly_report_recipients(user_id) WHERE user_id IS NOT NULL;

-- ─── REPORT LOGS ───────────────────────────────────────────

CREATE TABLE weekly_report_log (
    id SERIAL PRIMARY KEY,
    cohort_id UUID NOT NULL REFERENCES cohort(cohort_id) ON DELETE CASCADE,
    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,
    recipients_count INTEGER DEFAULT 0,
    report_data JSONB,
    status VARCHAR(50) NOT NULL CHECK (status IN ('pending', 'sent', 'failed')),
    error_message TEXT,
    delivery_channels JSONB DEFAULT '{"email": false, "slack": false}'::jsonb,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_weekly_report_log_cohort_id ON weekly_report_log(cohort_id);
CREATE INDEX idx_weekly_report_log_status ON weekly_report_log(status);
CREATE INDEX idx_weekly_report_log_created_at ON weekly_report_log(created_at DESC);
CREATE INDEX idx_weekly_report_log_cohort_date ON weekly_report_log(cohort_id, week_start_date DESC);
