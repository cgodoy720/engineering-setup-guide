-- ============================================================
-- ATTENDANCE SYSTEM — DATABASE SCHEMA
-- PostgreSQL DDL for all attendance-related tables
-- ============================================================

-- ─── BUILDER ATTENDANCE ─────────────────────────────────────

CREATE TABLE builder_attendance_new (
    attendance_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    check_in_time TIMESTAMP,
    photo_url TEXT,
    late_arrival_minutes INTEGER DEFAULT 0,
    status VARCHAR(50) NOT NULL DEFAULT 'present' CHECK (status IN ('present', 'late', 'absent', 'excused')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, attendance_date)
);

CREATE INDEX idx_builder_attendance_user_id ON builder_attendance_new(user_id);
CREATE INDEX idx_builder_attendance_date ON builder_attendance_new(attendance_date);
CREATE INDEX idx_builder_attendance_status ON builder_attendance_new(status);
CREATE INDEX idx_builder_attendance_user_date ON builder_attendance_new(user_id, attendance_date);
CREATE INDEX idx_builder_attendance_check_in_time ON builder_attendance_new(check_in_time) WHERE check_in_time IS NOT NULL;

-- ─── EXCUSED ABSENCES ────────────────────────────────────────

CREATE TABLE excused_absences (
    excuse_id SERIAL PRIMARY KEY,
    attendance_id INTEGER REFERENCES builder_attendance_new(attendance_id) ON DELETE SET NULL,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    absence_date DATE NOT NULL,
    excuse_reason VARCHAR(50) NOT NULL CHECK (excuse_reason IN ('Sick', 'Personal', 'Program Event', 'Technical Issue', 'Other')),
    excuse_details TEXT,
    staff_notes TEXT,
    processed_by INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'denied')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, absence_date)
);

CREATE INDEX idx_excused_absences_user_id ON excused_absences(user_id);
CREATE INDEX idx_excused_absences_absence_date ON excused_absences(absence_date);
CREATE INDEX idx_excused_absences_status ON excused_absences(status);
CREATE INDEX idx_excused_absences_attendance_id ON excused_absences(attendance_id) WHERE attendance_id IS NOT NULL;
CREATE INDEX idx_excused_absences_processed_by ON excused_absences(processed_by) WHERE processed_by IS NOT NULL;

-- ─── VOLUNTEER ATTENDANCE ───────────────────────────────────

CREATE TABLE volunteer_attendance (
    attendance_id SERIAL PRIMARY KEY,
    slot_id INTEGER NOT NULL REFERENCES volunteer_slots(slot_id) ON DELETE CASCADE,
    volunteer_user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'attended', 'no_show', 'cancelled', 'excused')),
    checked_in_at TIMESTAMP,
    photo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(slot_id, volunteer_user_id)
);

CREATE INDEX idx_volunteer_attendance_slot_id ON volunteer_attendance(slot_id);
CREATE INDEX idx_volunteer_attendance_volunteer_user_id ON volunteer_attendance(volunteer_user_id);
CREATE INDEX idx_volunteer_attendance_status ON volunteer_attendance(status);
CREATE INDEX idx_volunteer_attendance_checked_in_at ON volunteer_attendance(checked_in_at) WHERE checked_in_at IS NOT NULL;
