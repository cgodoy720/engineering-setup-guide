-- ============================================================
-- BUILDER ONBOARDING SYSTEM — DATABASE SCHEMA
-- PostgreSQL DDL for all onboarding-related tables
-- ============================================================

-- ─── ONBOARDING TASKS ───────────────────────────────────────

CREATE TABLE onboarding_tasks (
    task_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    detailed_description TEXT,
    link_url TEXT,
    link_text VARCHAR(255),
    is_required BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    updated_by_user_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE INDEX idx_onboarding_tasks_display_order ON onboarding_tasks(display_order);
CREATE INDEX idx_onboarding_tasks_is_active ON onboarding_tasks(is_active);
CREATE INDEX idx_onboarding_tasks_is_required ON onboarding_tasks(is_required);

-- ─── TASK COMPLETIONS ───────────────────────────────────────

CREATE TABLE applicant_onboarding_task_completions (
    id SERIAL PRIMARY KEY,
    applicant_id INTEGER NOT NULL REFERENCES applicant(applicant_id) ON DELETE CASCADE,
    task_id INTEGER NOT NULL REFERENCES onboarding_tasks(task_id) ON DELETE CASCADE,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    UNIQUE(applicant_id, task_id)
);

CREATE INDEX idx_onboarding_completions_applicant_id ON applicant_onboarding_task_completions(applicant_id);
CREATE INDEX idx_onboarding_completions_task_id ON applicant_onboarding_task_completions(task_id);
CREATE INDEX idx_onboarding_completions_completed_at ON applicant_onboarding_task_completions(completed_at);

-- ─── EMAIL MAPPING ─────────────────────────────────────────

CREATE TABLE applicant_email_mapping (
    id SERIAL PRIMARY KEY,
    personal_email VARCHAR(255) UNIQUE NOT NULL,
    pursuit_email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email_mapping_personal ON applicant_email_mapping(personal_email);
CREATE INDEX idx_email_mapping_pursuit ON applicant_email_mapping(pursuit_email);
