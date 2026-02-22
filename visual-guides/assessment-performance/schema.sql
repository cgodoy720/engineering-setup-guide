-- ============================================================
-- ASSESSMENT & PERFORMANCE SYSTEM — DATABASE SCHEMA
-- PostgreSQL DDL for all assessment-related tables
-- ============================================================

-- ─── ASSESSMENT TEMPLATES ────────────────────────────────────

CREATE TABLE assessment_templates (
    template_id SERIAL PRIMARY KEY,
    assessment_name VARCHAR(255) NOT NULL,
    assessment_type VARCHAR(100),
    instructions TEXT,
    deliverables JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_assessment_templates_type ON assessment_templates(assessment_type);
CREATE INDEX idx_assessment_templates_name ON assessment_templates(assessment_name);

-- ─── ASSESSMENTS ────────────────────────────────────────────

CREATE TABLE assessments (
    assessment_id SERIAL PRIMARY KEY,
    template_id INTEGER NOT NULL REFERENCES assessment_templates(template_id) ON DELETE CASCADE,
    cohort VARCHAR(100) NOT NULL,
    trigger_day_number INTEGER NOT NULL,
    assessment_period VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(template_id, cohort, trigger_day_number)
);

CREATE INDEX idx_assessments_template_id ON assessments(template_id);
CREATE INDEX idx_assessments_cohort ON assessments(cohort);
CREATE INDEX idx_assessments_period ON assessments(assessment_period);
CREATE INDEX idx_assessments_active ON assessments(is_active) WHERE is_active = true;
CREATE INDEX idx_assessments_cohort_period ON assessments(cohort, assessment_period);

-- ─── ASSESSMENT SUBMISSIONS ─────────────────────────────────

CREATE TABLE assessment_submissions (
    submission_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    assessment_id INTEGER NOT NULL REFERENCES assessments(assessment_id) ON DELETE CASCADE,
    submission_data JSONB,
    llm_conversation_data JSONB,
    status VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'submitted')),
    is_preview BOOLEAN DEFAULT false,
    needs_file_resubmission BOOLEAN DEFAULT false,
    needs_video_resubmission BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    submitted_at TIMESTAMP,
    UNIQUE(user_id, assessment_id, is_preview)
);

CREATE INDEX idx_assessment_submissions_user_id ON assessment_submissions(user_id);
CREATE INDEX idx_assessment_submissions_assessment_id ON assessment_submissions(assessment_id);
CREATE INDEX idx_assessment_submissions_status ON assessment_submissions(status);
CREATE INDEX idx_assessment_submissions_user_assessment ON assessment_submissions(user_id, assessment_id);
CREATE INDEX idx_assessment_submissions_submitted_at ON assessment_submissions(submitted_at) WHERE submitted_at IS NOT NULL;
