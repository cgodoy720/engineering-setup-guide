-- ============================================================
-- EXTERNAL COHORTS SYSTEM — DATABASE SCHEMA
-- PostgreSQL DDL for all External Cohorts-related tables
-- ============================================================

-- ─── COHORT MANAGEMENT ─────────────────────────────────────

CREATE TABLE cohort (
    cohort_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE,
    cohort_type VARCHAR(50) NOT NULL,
    access_code VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    contact_name VARCHAR(255),
    contact_email VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    course_id UUID REFERENCES course(course_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT cohort_type_check CHECK (cohort_type IN ('builder', 'workshop', 'external'))
);

CREATE INDEX idx_cohort_access_code ON cohort(access_code);
CREATE INDEX idx_cohort_cohort_type ON cohort(cohort_type);
CREATE INDEX idx_cohort_is_active ON cohort(is_active);
CREATE INDEX idx_cohort_course_id ON cohort(course_id);
CREATE INDEX idx_cohort_start_date ON cohort(start_date);
CREATE INDEX idx_cohort_end_date ON cohort(end_date);

-- Access codes are auto-generated with format: EXT-{timestamp}-{random}
-- Example: EXT-1708560000-a3f9b2

CREATE TABLE cohort_admins (
    admin_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    cohort_id UUID NOT NULL REFERENCES cohort(cohort_id) ON DELETE CASCADE,
    pending_email VARCHAR(255),
    role VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT cohort_admins_user_or_email CHECK (
        (user_id IS NOT NULL) OR (pending_email IS NOT NULL)
    )
);

CREATE INDEX idx_cohort_admins_user_id ON cohort_admins(user_id);
CREATE INDEX idx_cohort_admins_cohort_id ON cohort_admins(cohort_id);
CREATE INDEX idx_cohort_admins_pending_email ON cohort_admins(pending_email);

-- ─── INVITATIONS ───────────────────────────────────────────

CREATE TABLE cohort_invitations (
    invitation_id SERIAL PRIMARY KEY,
    cohort_id UUID NOT NULL REFERENCES cohort(cohort_id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    sent_at TIMESTAMP,
    registered_at TIMESTAMP,
    user_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT cohort_invitations_status_check CHECK (status IN ('pending', 'sent', 'registered', 'expired')),
    UNIQUE(cohort_id, email)
);

CREATE INDEX idx_cohort_invitations_cohort_id ON cohort_invitations(cohort_id);
CREATE INDEX idx_cohort_invitations_email ON cohort_invitations(email);
CREATE INDEX idx_cohort_invitations_status ON cohort_invitations(status);
CREATE INDEX idx_cohort_invitations_user_id ON cohort_invitations(user_id);

-- ─── USERS EXTENSION ───────────────────────────────────────

-- Note: The users table is extended with the following columns:
-- ALTER TABLE users ADD COLUMN IF NOT EXISTS cohort_id UUID REFERENCES cohort(cohort_id) ON DELETE SET NULL;
-- ALTER TABLE users ADD COLUMN IF NOT EXISTS roles TEXT[] DEFAULT '{}';
-- 
-- Enterprise roles are stored in the roles array:
-- - 'enterprise_builder' — Builder in an enterprise cohort
-- - 'enterprise_admin' — Admin of an enterprise cohort
--
-- Indexes:
-- CREATE INDEX IF NOT EXISTS idx_users_cohort_id ON users(cohort_id);
-- CREATE INDEX IF NOT EXISTS idx_users_enterprise_roles ON users USING GIN(roles);
