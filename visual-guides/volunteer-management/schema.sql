-- ============================================================
-- VOLUNTEER MANAGEMENT SYSTEM — DATABASE SCHEMA
-- PostgreSQL DDL for all Volunteer Management-related tables
-- ============================================================

-- ============================================================
-- TRIGGER FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- ============================================================
-- VOLUNTEER PROFILES
-- ============================================================

CREATE TABLE IF NOT EXISTS volunteer_profiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    phone VARCHAR(20),
    preferred_contact_method VARCHAR(20) DEFAULT 'email'
        CHECK (preferred_contact_method IN ('email', 'phone', 'text')),
    timezone VARCHAR(50) DEFAULT 'America/New_York',
    availability_preferences JSONB DEFAULT '{}',
    skills TEXT[],
    professional_background TEXT,
    linkedin_url VARCHAR(255),
    staff_notes TEXT,
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_volunteer_profiles_user_id ON volunteer_profiles(user_id);
CREATE INDEX idx_volunteer_profiles_skills ON volunteer_profiles USING gin(skills);

CREATE TRIGGER update_volunteer_profiles_updated_at 
    BEFORE UPDATE ON volunteer_profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- VOLUNTEER COHORT ASSIGNMENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS volunteer_cohort_assignments (
    assignment_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    cohort_name VARCHAR(100) NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by INTEGER REFERENCES users(user_id),
    is_active BOOLEAN DEFAULT true,
    deactivated_at TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, cohort_name)
);

CREATE INDEX idx_volunteer_cohort_assignments_user_id ON volunteer_cohort_assignments(user_id);
CREATE INDEX idx_volunteer_cohort_assignments_cohort ON volunteer_cohort_assignments(cohort_name);
CREATE INDEX idx_volunteer_cohort_assignments_active ON volunteer_cohort_assignments(user_id, cohort_name) WHERE is_active = true;

CREATE TRIGGER update_volunteer_cohort_assignments_updated_at 
    BEFORE UPDATE ON volunteer_cohort_assignments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- VOLUNTEER CLASS SLOTS
-- ============================================================

CREATE TABLE IF NOT EXISTS volunteer_class_slots (
    slot_id SERIAL PRIMARY KEY,
    curriculum_day_id INTEGER REFERENCES curriculum_days(id) ON DELETE CASCADE,
    slot_date DATE NOT NULL,
    cohort_name VARCHAR(100) NOT NULL,
    volunteer_user_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    assigned_at TIMESTAMP,
    assigned_by INTEGER REFERENCES users(user_id),
    slot_type VARCHAR(50) DEFAULT 'class_support',
    max_volunteers INTEGER DEFAULT 1,
    status VARCHAR(30) DEFAULT 'open',
    volunteer_confirmed_at TIMESTAMP,
    slot_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    slot_time TIME,
    CONSTRAINT volunteer_class_slots_slot_type_check CHECK (slot_type IN ('class_support', 'demo_day', 'networking', 'mock_interview', 'panel')),
    CONSTRAINT volunteer_class_slots_status_check CHECK (status IN ('open', 'assigned', 'confirmed', 'cancelled', 'completed'))
);

CREATE INDEX idx_volunteer_class_slots_date ON volunteer_class_slots(slot_date);
CREATE INDEX idx_volunteer_class_slots_cohort ON volunteer_class_slots(cohort_name);
CREATE INDEX idx_volunteer_class_slots_date_cohort ON volunteer_class_slots(slot_date, cohort_name);
CREATE INDEX idx_volunteer_class_slots_volunteer ON volunteer_class_slots(volunteer_user_id) WHERE volunteer_user_id IS NOT NULL;
CREATE INDEX idx_volunteer_class_slots_curriculum_day ON volunteer_class_slots(curriculum_day_id);
CREATE INDEX idx_volunteer_class_slots_status ON volunteer_class_slots(status);
CREATE INDEX idx_volunteer_class_slots_upcoming ON volunteer_class_slots(slot_date, status) WHERE status IN ('open', 'assigned', 'confirmed');

CREATE TRIGGER update_volunteer_class_slots_updated_at 
    BEFORE UPDATE ON volunteer_class_slots 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- VOLUNTEER ATTENDANCE
-- ============================================================

CREATE TABLE IF NOT EXISTS volunteer_attendance (
    attendance_id SERIAL PRIMARY KEY,
    slot_id INTEGER NOT NULL REFERENCES volunteer_class_slots(slot_id) ON DELETE CASCADE,
    volunteer_user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    checked_in_at TIMESTAMP,
    checked_in_by INTEGER REFERENCES users(user_id),
    cancellation_reason TEXT,
    cancelled_at TIMESTAMP,
    session_rating INTEGER CHECK (session_rating >= 1 AND session_rating <= 5),
    quick_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    photo_url TEXT,
    late_arrival_minutes INTEGER DEFAULT 0,
    UNIQUE(slot_id, volunteer_user_id),
    CONSTRAINT volunteer_attendance_status_check CHECK (status IN ('pending', 'attended', 'no_show', 'cancelled', 'excused'))
);

CREATE INDEX idx_volunteer_attendance_slot ON volunteer_attendance(slot_id);
CREATE INDEX idx_volunteer_attendance_volunteer ON volunteer_attendance(volunteer_user_id);
CREATE INDEX idx_volunteer_attendance_status ON volunteer_attendance(status);
CREATE INDEX idx_volunteer_attendance_date ON volunteer_attendance(created_at);

CREATE TRIGGER update_volunteer_attendance_updated_at 
    BEFORE UPDATE ON volunteer_attendance 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- VOLUNTEER EMAIL LOG
-- ============================================================

CREATE TABLE IF NOT EXISTS volunteer_email_log (
    email_id SERIAL PRIMARY KEY,
    volunteer_user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    recipient_email VARCHAR(255) NOT NULL,
    email_type VARCHAR(50) NOT NULL,
    subject VARCHAR(255),
    slot_id INTEGER REFERENCES volunteer_class_slots(slot_id) ON DELETE SET NULL,
    curriculum_day_id INTEGER REFERENCES curriculum_days(id) ON DELETE SET NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sent_by INTEGER REFERENCES users(user_id),
    opened_at TIMESTAMP,
    clicked_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'sent',
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT volunteer_email_log_email_type_check CHECK (email_type IN ('prep_email', 'reminder_24h', 'reminder_48h', 'confirmation', 'thank_you', 'schedule_change')),
    CONSTRAINT volunteer_email_log_status_check CHECK (status IN ('pending', 'sent', 'delivered', 'opened', 'failed', 'bounced'))
);

CREATE INDEX idx_volunteer_email_log_volunteer ON volunteer_email_log(volunteer_user_id);
CREATE INDEX idx_volunteer_email_log_type ON volunteer_email_log(email_type);
CREATE INDEX idx_volunteer_email_log_slot ON volunteer_email_log(slot_id) WHERE slot_id IS NOT NULL;
CREATE INDEX idx_volunteer_email_log_status ON volunteer_email_log(status);
CREATE INDEX idx_volunteer_email_log_sent_at ON volunteer_email_log(sent_at);

-- ============================================================
-- VOLUNTEER FEEDBACK
-- ============================================================

CREATE TABLE IF NOT EXISTS volunteer_feedback (
    feedback_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    feedback_date DATE NOT NULL,
    feedback_type VARCHAR(50) NOT NULL,
    feedback_text TEXT,
    audio_recording_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    overall_experience TEXT,
    improvement_suggestions TEXT,
    specific_feedback TEXT,
    CONSTRAINT volunteer_feedback_feedback_type_check CHECK (feedback_type IN ('AI Native Class', 'Demo Day', 'Networking Event', 'Panel', 'Mock Interview'))
);

CREATE INDEX idx_volunteer_feedback_user_id ON volunteer_feedback(user_id);
CREATE INDEX idx_volunteer_feedback_date ON volunteer_feedback(feedback_date);
CREATE INDEX idx_volunteer_feedback_type ON volunteer_feedback(feedback_type);
CREATE INDEX idx_volunteer_feedback_created_at ON volunteer_feedback(created_at);

CREATE TRIGGER update_volunteer_feedback_updated_at 
    BEFORE UPDATE ON volunteer_feedback 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- VIEWS
-- ============================================================

-- Combined volunteer data view
CREATE OR REPLACE VIEW volunteers_full_view AS
SELECT 
    u.user_id,
    u.email,
    u.first_name,
    u.last_name,
    vp.phone,
    vp.preferred_contact_method,
    vp.timezone,
    vp.availability_preferences,
    vp.skills,
    vp.professional_background,
    vp.linkedin_url,
    vp.staff_notes,
    vp.bio,
    vp.created_at as profile_created_at,
    vp.updated_at as profile_updated_at
FROM users u
LEFT JOIN volunteer_profiles vp ON u.user_id = vp.user_id;

-- Schedule view for volunteers
CREATE OR REPLACE VIEW volunteer_schedule_view AS
SELECT 
    vcs.slot_id,
    vcs.slot_date,
    vcs.slot_time,
    vcs.cohort_name,
    vcs.slot_type,
    vcs.status,
    vcs.volunteer_user_id,
    u.first_name || ' ' || u.last_name as volunteer_name,
    u.email as volunteer_email,
    va.attendance_id,
    va.status as attendance_status,
    va.checked_in_at,
    va.session_rating,
    cd.day_number,
    cd.title as curriculum_day_title
FROM volunteer_class_slots vcs
LEFT JOIN users u ON vcs.volunteer_user_id = u.user_id
LEFT JOIN volunteer_attendance va ON vcs.slot_id = va.slot_id AND vcs.volunteer_user_id = va.volunteer_user_id
LEFT JOIN curriculum_days cd ON vcs.curriculum_day_id = cd.id;

-- Attendance summary view
CREATE OR REPLACE VIEW volunteer_attendance_summary AS
SELECT 
    va.volunteer_user_id,
    u.first_name || ' ' || u.last_name as volunteer_name,
    COUNT(*) FILTER (WHERE va.status = 'attended') as attended_count,
    COUNT(*) FILTER (WHERE va.status = 'no_show') as no_show_count,
    COUNT(*) FILTER (WHERE va.status = 'cancelled') as cancelled_count,
    COUNT(*) FILTER (WHERE va.status = 'excused') as excused_count,
    COUNT(*) FILTER (WHERE va.status = 'pending') as pending_count,
    COUNT(*) as total_slots,
    ROUND(AVG(va.session_rating) FILTER (WHERE va.session_rating IS NOT NULL), 2) as avg_rating
FROM volunteer_attendance va
JOIN users u ON va.volunteer_user_id = u.user_id
GROUP BY va.volunteer_user_id, u.first_name, u.last_name;
