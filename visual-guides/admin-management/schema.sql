-- Admin & Management System Database Schema
-- PostgreSQL DDL for permissions, organizations, cohorts, and prompts

-- ============================================================================
-- PERMISSION TABLES
-- ============================================================================

-- Role Permissions: Default grants per role
CREATE TABLE role_permissions (
    role_permission_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL CHECK (role_name IN (
        'admin', 'staff', 'builder', 'applicant', 'workshop_participant',
        'workshop_admin', 'volunteer', 'enterprise_builder', 'enterprise_admin'
    )),
    permission_key VARCHAR(255) NOT NULL,
    default_granted BOOLEAN NOT NULL DEFAULT true,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(role_name, permission_key)
);

CREATE INDEX idx_role_permissions_role_name ON role_permissions(role_name);
CREATE INDEX idx_role_permissions_permission_key ON role_permissions(permission_key);

-- User Permissions: Custom user overrides
CREATE TABLE user_permissions (
    permission_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    permission_key VARCHAR(255) NOT NULL,
    resource_id UUID,
    resource_type VARCHAR(50),
    granted BOOLEAN NOT NULL DEFAULT true,
    granted_by INTEGER REFERENCES users(user_id),
    notes TEXT,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, permission_key, resource_id, resource_type)
);

CREATE INDEX idx_user_permissions_user_id ON user_permissions(user_id);
CREATE INDEX idx_user_permissions_permission_key ON user_permissions(permission_key);
CREATE INDEX idx_user_permissions_resource ON user_permissions(resource_id, resource_type);
CREATE INDEX idx_user_permissions_expires_at ON user_permissions(expires_at) WHERE expires_at IS NOT NULL;

-- ============================================================================
-- ORGANIZATION HIERARCHY TABLES
-- ============================================================================

-- Organizations: Top-level entities
CREATE TABLE organizations (
    organization_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT true,
    logo_url VARCHAR(500),
    contact_email VARCHAR(255),
    contact_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_organizations_slug ON organizations(slug);
CREATE INDEX idx_organizations_active ON organizations(active);

-- Programs: Programs within organizations
CREATE TABLE program (
    program_id SERIAL PRIMARY KEY,
    organization_id INTEGER NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    program_type VARCHAR(100),
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(organization_id, slug)
);

CREATE INDEX idx_program_organization_id ON program(organization_id);
CREATE INDEX idx_program_active ON program(active);

-- Courses: Courses within programs
CREATE TABLE course (
    course_id SERIAL PRIMARY KEY,
    program_id INTEGER NOT NULL REFERENCES program(program_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    level INTEGER,
    sequence_order INTEGER DEFAULT 0,
    duration_weeks INTEGER,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(program_id, slug)
);

CREATE INDEX idx_course_program_id ON course(program_id);
CREATE INDEX idx_course_active ON course(active);
CREATE INDEX idx_course_sequence ON course(program_id, sequence_order);

-- Cohorts: Cohorts within courses
CREATE TABLE cohort (
    cohort_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id INTEGER NOT NULL REFERENCES course(course_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE,
    cohort_type VARCHAR(50) NOT NULL CHECK (cohort_type IN ('builder', 'workshop', 'external')),
    access_code VARCHAR(100) UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_cohort_course_id ON cohort(course_id);
CREATE INDEX idx_cohort_type ON cohort(cohort_type);
CREATE INDEX idx_cohort_access_code ON cohort(access_code);
CREATE INDEX idx_cohort_active ON cohort(is_active);
CREATE INDEX idx_cohort_dates ON cohort(start_date, end_date);

-- ============================================================================
-- ENROLLMENT & ACCESS TABLES
-- ============================================================================

-- User Enrollments: Many-to-many relationship between users and cohorts
CREATE TABLE user_enrollment (
    enrollment_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    cohort_id UUID NOT NULL REFERENCES cohort(cohort_id) ON DELETE CASCADE,
    enrolled_date TIMESTAMP DEFAULT NOW(),
    status VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, cohort_id)
);

CREATE INDEX idx_user_enrollment_user_id ON user_enrollment(user_id);
CREATE INDEX idx_user_enrollment_cohort_id ON user_enrollment(cohort_id);
CREATE INDEX idx_user_enrollment_active ON user_enrollment(is_active);
CREATE INDEX idx_user_enrollment_status ON user_enrollment(status);

-- Cohort Admins: Admin assignments to cohorts
CREATE TABLE cohort_admins (
    admin_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    cohort_id UUID NOT NULL REFERENCES cohort(cohort_id) ON DELETE CASCADE,
    pending_email VARCHAR(255),
    role VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, cohort_id),
    CHECK ((user_id IS NOT NULL) OR (pending_email IS NOT NULL))
);

CREATE INDEX idx_cohort_admins_user_id ON cohort_admins(user_id);
CREATE INDEX idx_cohort_admins_cohort_id ON cohort_admins(cohort_id);
CREATE INDEX idx_cohort_admins_pending_email ON cohort_admins(pending_email) WHERE pending_email IS NOT NULL;

-- Cohort Invitations: Pending cohort invitations
CREATE TABLE cohort_invitations (
    invitation_id SERIAL PRIMARY KEY,
    cohort_id UUID NOT NULL REFERENCES cohort(cohort_id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    invited_by INTEGER NOT NULL REFERENCES users(user_id),
    invited_at TIMESTAMP DEFAULT NOW(),
    accepted_at TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_cohort_invitations_cohort_id ON cohort_invitations(cohort_id);
CREATE INDEX idx_cohort_invitations_email ON cohort_invitations(email);
CREATE INDEX idx_cohort_invitations_expires_at ON cohort_invitations(expires_at) WHERE expires_at IS NOT NULL;

-- ============================================================================
-- PROMPT MANAGEMENT TABLES
-- ============================================================================

-- Base Prompts: Base prompt templates
CREATE TABLE base_prompts (
    prompt_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    description TEXT,
    is_default BOOLEAN NOT NULL DEFAULT false,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_base_prompts_active ON base_prompts(active);
CREATE INDEX idx_base_prompts_default ON base_prompts(is_default) WHERE is_default = true;

-- Personas: AI persona definitions
CREATE TABLE personas (
    persona_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    system_prompt TEXT NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT false,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_personas_active ON personas(active);
CREATE INDEX idx_personas_default ON personas(is_default) WHERE is_default = true;

-- Program Contexts: Program-specific contexts
CREATE TABLE program_contexts (
    context_id SERIAL PRIMARY KEY,
    program_id INTEGER REFERENCES program(program_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    context_data JSONB NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT false,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_program_contexts_program_id ON program_contexts(program_id);
CREATE INDEX idx_program_contexts_active ON program_contexts(active);
CREATE INDEX idx_program_contexts_default ON program_contexts(is_default) WHERE is_default = true;

-- Modes: Interaction modes
CREATE TABLE modes (
    mode_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    config JSONB NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT false,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_modes_active ON modes(active);
CREATE INDEX idx_modes_default ON modes(is_default) WHERE is_default = true;

-- Content Generation Prompts: Content generation prompts
CREATE TABLE content_generation_prompts (
    prompt_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    prompt_template TEXT NOT NULL,
    description TEXT,
    is_default BOOLEAN NOT NULL DEFAULT false,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_content_generation_prompts_active ON content_generation_prompts(active);
CREATE INDEX idx_content_generation_prompts_default ON content_generation_prompts(is_default) WHERE is_default = true;

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_role_permissions_updated_at BEFORE UPDATE ON role_permissions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_permissions_updated_at BEFORE UPDATE ON user_permissions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_program_updated_at BEFORE UPDATE ON program
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_course_updated_at BEFORE UPDATE ON course
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cohort_updated_at BEFORE UPDATE ON cohort
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_enrollment_updated_at BEFORE UPDATE ON user_enrollment
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cohort_admins_updated_at BEFORE UPDATE ON cohort_admins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cohort_invitations_updated_at BEFORE UPDATE ON cohort_invitations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_base_prompts_updated_at BEFORE UPDATE ON base_prompts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_personas_updated_at BEFORE UPDATE ON personas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_program_contexts_updated_at BEFORE UPDATE ON program_contexts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_modes_updated_at BEFORE UPDATE ON modes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_content_generation_prompts_updated_at BEFORE UPDATE ON content_generation_prompts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE role_permissions IS 'Default permission grants per role';
COMMENT ON TABLE user_permissions IS 'Custom user permission overrides with optional resource scoping and expiration';
COMMENT ON TABLE organizations IS 'Top-level organizational entities';
COMMENT ON TABLE program IS 'Programs within organizations';
COMMENT ON TABLE course IS 'Courses within programs';
COMMENT ON TABLE cohort IS 'Cohorts within courses, can be builder/workshop/external type';
COMMENT ON TABLE user_enrollment IS 'Many-to-many relationship between users and cohorts';
COMMENT ON TABLE cohort_admins IS 'Admin assignments to cohorts, supports pending invites via email';
COMMENT ON TABLE cohort_invitations IS 'Pending cohort invitations with expiration';
COMMENT ON TABLE base_prompts IS 'Base prompt templates for AI interactions';
COMMENT ON TABLE personas IS 'AI persona definitions with system prompts';
COMMENT ON TABLE program_contexts IS 'Program-specific context data stored as JSONB';
COMMENT ON TABLE modes IS 'Interaction mode configurations stored as JSONB';
COMMENT ON TABLE content_generation_prompts IS 'Content generation prompt templates';
