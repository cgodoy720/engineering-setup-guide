-- ============================================================
-- FORMS & SURVEYS SYSTEM — DATABASE SCHEMA
-- PostgreSQL DDL for all forms-related tables
-- ============================================================

-- ─── FORMS ───────────────────────────────────────────────────

CREATE TABLE forms (
    form_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    slug VARCHAR(255) UNIQUE NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'draft',
    created_by INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    expires_at TIMESTAMP,
    submission_limit INTEGER,
    submission_count INTEGER DEFAULT 0,
    settings JSONB DEFAULT '{}',
    questions JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT forms_status_check CHECK (status IN (
        'draft', 'active', 'closed', 'archived'
    ))
);

CREATE INDEX idx_forms_slug ON forms(slug);
CREATE INDEX idx_forms_status ON forms(status);
CREATE INDEX idx_forms_created_by ON forms(created_by);
CREATE INDEX idx_forms_created_at ON forms(created_at);
CREATE INDEX idx_forms_status_created_at ON forms(status, created_at);

-- ─── FORM SUBMISSIONS ───────────────────────────────────────

CREATE TABLE form_submissions (
    submission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    form_id UUID NOT NULL REFERENCES forms(form_id) ON DELETE CASCADE,
    responses JSONB NOT NULL DEFAULT '{}',
    respondent_email VARCHAR(255),
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completion_time_seconds INTEGER,
    session_id VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'completed',
    notes TEXT,
    flagged BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT form_submissions_status_check CHECK (status IN (
        'completed', 'draft'
    ))
);

CREATE INDEX idx_form_submissions_form_id ON form_submissions(form_id);
CREATE INDEX idx_form_submissions_status ON form_submissions(status);
CREATE INDEX idx_form_submissions_submitted_at ON form_submissions(submitted_at);
CREATE INDEX idx_form_submissions_form_status ON form_submissions(form_id, status);
CREATE INDEX idx_form_submissions_flagged ON form_submissions(flagged) WHERE flagged = true;
CREATE INDEX idx_form_submissions_session_id ON form_submissions(session_id);
CREATE INDEX idx_form_submissions_respondent_email ON form_submissions(respondent_email);

-- ─── TRIGGERS ─────────────────────────────────────────────────

-- Update updated_at timestamp on forms
CREATE OR REPLACE FUNCTION update_forms_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_forms_updated_at
    BEFORE UPDATE ON forms
    FOR EACH ROW
    EXECUTE FUNCTION update_forms_updated_at();

-- Update updated_at timestamp on form_submissions
CREATE OR REPLACE FUNCTION update_form_submissions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_form_submissions_updated_at
    BEFORE UPDATE ON form_submissions
    FOR EACH ROW
    EXECUTE FUNCTION update_form_submissions_updated_at();

-- Increment submission_count on forms when submission is created
CREATE OR REPLACE FUNCTION increment_form_submission_count()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' THEN
        UPDATE forms
        SET submission_count = submission_count + 1
        WHERE form_id = NEW.form_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_form_submission_count
    AFTER INSERT ON form_submissions
    FOR EACH ROW
    WHEN (NEW.status = 'completed')
    EXECUTE FUNCTION increment_form_submission_count();
