-- ============================================================
-- ADMISSIONS SYSTEM — DATABASE SCHEMA
-- PostgreSQL DDL for all admissions-related tables
-- ============================================================

-- ─── IDENTITY ───────────────────────────────────────────────

CREATE TABLE applicant (
    applicant_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    password_hash VARCHAR(255) NOT NULL DEFAULT '',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    email_opt_out BOOLEAN DEFAULT false,
    email_opt_out_date TIMESTAMP,
    email_opt_out_reason VARCHAR(255),
    email_opt_out_by_admin_id INTEGER REFERENCES users(user_id),
    verified BOOLEAN DEFAULT false,
    verification_token VARCHAR(255),
    token_expires_at TIMESTAMP,
    referral_source VARCHAR(255),
    referral_detail TEXT,
    nycha_resident VARCHAR(50)
);

CREATE INDEX idx_applicant_email ON applicant(email);
CREATE INDEX idx_applicant_verification_token ON applicant(verification_token);
CREATE INDEX idx_applicant_referral_source ON applicant(referral_source);
CREATE INDEX idx_applicant_nycha_resident ON applicant(nycha_resident);

CREATE TABLE applicant_stage (
    stage_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    applicant_id INTEGER UNIQUE NOT NULL REFERENCES applicant(applicant_id) ON DELETE CASCADE,
    current_stage VARCHAR(50) NOT NULL,
    previous_stage VARCHAR(50),
    stage_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    program_admission_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    pledge_completed BOOLEAN DEFAULT false,
    pledge_completed_at TIMESTAMP,
    pledge_signature_data TEXT,
    deferred BOOLEAN DEFAULT false,
    deferred_at TIMESTAMP,
    deliberation VARCHAR(20),
    original_cohort_id UUID,
    current_cohort_id UUID REFERENCES cohort(cohort_id),
    rollover_cohorts UUID[] DEFAULT '{}',
    rollover_count INTEGER DEFAULT 0,
    last_rollover_date TIMESTAMP,
    deferred_from_cohort_id UUID,
    is_rollover BOOLEAN DEFAULT false,
    CONSTRAINT check_current_stage CHECK (current_stage IS NULL OR current_stage IN (
        'workshop_invited', 'workshop_registered', 'workshop_attended', 'workshop_no_show',
        'info_session_registered', 'info_session_attended', 'info_session_no_show',
        'application_submitted', 'application_under_review'
    )),
    CONSTRAINT check_program_admission_status CHECK (program_admission_status IN (
        'pending', 'accepted', 'rejected', 'waitlisted', 'withdrawn'
    )),
    CONSTRAINT applicant_stage_deliberation_check CHECK (deliberation IN ('yes', 'maybe', 'no'))
);

CREATE INDEX idx_applicant_stage_applicant_id ON applicant_stage(applicant_id);
CREATE INDEX idx_applicant_stage_current_stage ON applicant_stage(current_stage);
CREATE INDEX idx_applicant_stage_program_admission_status ON applicant_stage(program_admission_status);
CREATE INDEX idx_applicant_stage_program_status ON applicant_stage(program_admission_status, deferred);
CREATE INDEX idx_applicant_stage_deliberation ON applicant_stage(deliberation);
CREATE INDEX idx_applicant_stage_current_cohort ON applicant_stage(current_cohort_id);

CREATE TABLE applicant_notes (
    note_id SERIAL PRIMARY KEY,
    applicant_id INTEGER NOT NULL REFERENCES applicant(applicant_id) ON DELETE CASCADE,
    created_by INTEGER NOT NULL REFERENCES users(user_id) ON DELETE SET NULL,
    note_content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE applicant_email_mapping (
    mapping_id SERIAL PRIMARY KEY,
    personal_email VARCHAR(255) UNIQUE NOT NULL,
    pursuit_email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_applicant_email_mapping_personal ON applicant_email_mapping(personal_email);
CREATE INDEX idx_applicant_email_mapping_pursuit ON applicant_email_mapping(pursuit_email);

-- ─── APPLICATION FORM ───────────────────────────────────────

CREATE TABLE application (
    application_id SERIAL PRIMARY KEY,
    applicant_id INTEGER NOT NULL REFERENCES applicant(applicant_id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'draft',
    submitted_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_application_applicant_id ON application(applicant_id);
CREATE INDEX idx_application_status ON application(status);
CREATE INDEX idx_application_cohort_dates ON application(created_at, submitted_at);

CREATE TABLE section (
    section_id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    display_order INTEGER
);

CREATE TABLE question (
    question_id INTEGER PRIMARY KEY,
    section_id INTEGER REFERENCES section(section_id),
    prompt TEXT NOT NULL,
    response_type VARCHAR(50) NOT NULL,
    display_order INTEGER,
    is_required BOOLEAN DEFAULT false,
    active BOOLEAN DEFAULT true,
    parent_question_id INTEGER REFERENCES question(question_id),
    show_when_parent_equals TEXT,
    condition_type VARCHAR(50)
);

CREATE INDEX idx_question_section ON question(section_id);
CREATE INDEX idx_question_parent ON question(parent_question_id);
CREATE INDEX idx_question_active ON question(active);

CREATE TABLE choice_option (
    option_id SERIAL PRIMARY KEY,
    question_id INTEGER REFERENCES question(question_id) ON DELETE CASCADE,
    label VARCHAR(255) NOT NULL,
    value VARCHAR(255) NOT NULL,
    display_order INTEGER
);

CREATE INDEX idx_choice_question ON choice_option(question_id);

CREATE TABLE response (
    response_id SERIAL PRIMARY KEY,
    application_id INTEGER NOT NULL REFERENCES application(application_id) ON DELETE CASCADE,
    question_id INTEGER NOT NULL,
    response_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(application_id, question_id)
);

CREATE INDEX idx_response_application_id ON response(application_id);
CREATE INDEX idx_response_question_id ON response(question_id);
CREATE INDEX idx_response_app_question ON response(application_id, question_id);

-- ─── AI ANALYSIS ────────────────────────────────────────────

CREATE TABLE application_analysis (
    analysis_id SERIAL PRIMARY KEY,
    application_id INTEGER NOT NULL REFERENCES application(application_id) ON DELETE CASCADE,
    learning_score INTEGER NOT NULL CHECK (learning_score >= 0 AND learning_score <= 100),
    grit_score INTEGER NOT NULL CHECK (grit_score >= 0 AND grit_score <= 100),
    critical_thinking_score INTEGER NOT NULL CHECK (critical_thinking_score >= 0 AND critical_thinking_score <= 100),
    overall_score INTEGER NOT NULL CHECK (overall_score >= 0 AND overall_score <= 100),
    base_score INTEGER NOT NULL CHECK (base_score >= 0 AND base_score <= 100),
    penalty INTEGER NOT NULL DEFAULT 0,
    missing_count INTEGER NOT NULL DEFAULT 0,
    recommendation VARCHAR(50) NOT NULL CHECK (recommendation IN (
        'strong_recommend', 'recommend', 'review_needed', 'not_recommend'
    )),
    strengths TEXT,
    concerns TEXT,
    areas_for_development TEXT,
    analysis_notes TEXT,
    target_responses_found INTEGER NOT NULL DEFAULT 0,
    total_responses INTEGER NOT NULL DEFAULT 0,
    tokens_used INTEGER DEFAULT 0,
    analyzer_version VARCHAR(20) DEFAULT 'v5.0',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    analyzed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    has_masters_degree BOOLEAN DEFAULT false,
    masters_confidence VARCHAR(20) DEFAULT 'none' CHECK (masters_confidence IN ('high', 'medium', 'low', 'none')),
    masters_evidence JSONB DEFAULT '[]',
    truncation_alerts JSONB DEFAULT '[]',
    final_status VARCHAR(50) CHECK (final_status IN (
        'strong_recommend', 'recommend', 'review_needed', 'not_recommend'
    )),
    UNIQUE(application_id, analyzer_version, analyzed_at)
);

CREATE INDEX idx_application_analysis_application_id ON application_analysis(application_id);
CREATE INDEX idx_application_analysis_created_at ON application_analysis(created_at);
CREATE INDEX idx_application_analysis_overall_score ON application_analysis(overall_score);
CREATE INDEX idx_application_analysis_recommendation ON application_analysis(recommendation);
CREATE INDEX idx_application_analysis_has_masters_degree ON application_analysis(has_masters_degree);
CREATE INDEX idx_application_analysis_masters_confidence ON application_analysis(masters_confidence);
CREATE INDEX idx_application_analysis_final_status ON application_analysis(final_status);

-- ─── EVENTS ─────────────────────────────────────────────────

CREATE TABLE event (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type_id UUID NOT NULL REFERENCES event_type(type_id),
    title VARCHAR(100) NOT NULL,
    description TEXT,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    location VARCHAR(200) NOT NULL,
    capacity INTEGER NOT NULL,
    is_online BOOLEAN DEFAULT false,
    meeting_link TEXT,
    status VARCHAR(20) DEFAULT 'scheduled',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    cohort_name VARCHAR(255),
    workshop_type VARCHAR(50),
    organization_id INTEGER REFERENCES organizations(organization_id) ON DELETE SET NULL,
    cohort_id UUID REFERENCES cohort(cohort_id) ON DELETE SET NULL,
    CONSTRAINT event_status_check CHECK (status IN ('scheduled', 'cancelled', 'completed')),
    CONSTRAINT event_workshop_type_check CHECK (workshop_type IN ('admissions', 'external') OR workshop_type IS NULL)
);

CREATE INDEX idx_event_type_id ON event(type_id);
CREATE INDEX idx_event_start_time ON event(start_time);
CREATE INDEX idx_event_workshop_type ON event(workshop_type) WHERE workshop_type IS NOT NULL;
CREATE INDEX idx_event_cohort_id ON event(cohort_id);

CREATE TABLE event_registration (
    registration_id SERIAL PRIMARY KEY,
    event_id UUID NOT NULL REFERENCES event(event_id) ON DELETE CASCADE,
    applicant_id INTEGER REFERENCES applicant(applicant_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'registered',
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    attended_at TIMESTAMP,
    reminder_48h_sent BOOLEAN DEFAULT false,
    reminder_24h_sent BOOLEAN DEFAULT false,
    reminder_48h_sent_at TIMESTAMP,
    reminder_24h_sent_at TIMESTAMP,
    needs_laptop BOOLEAN DEFAULT false,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    participant_type VARCHAR(50),
    attended BOOLEAN DEFAULT false,
    completed_at TIMESTAMP,
    notes TEXT,
    UNIQUE(event_id, applicant_id),
    CONSTRAINT event_registration_participant_type_check CHECK (
        participant_type IN ('applicant', 'external', 'regular') OR participant_type IS NULL
    )
);

CREATE INDEX idx_event_registration_event_id ON event_registration(event_id);
CREATE INDEX idx_event_registration_applicant_id ON event_registration(applicant_id);
CREATE INDEX idx_event_registration_email ON event_registration(email);
CREATE INDEX idx_event_registration_status ON event_registration(status, applicant_id);

-- ─── LEADS ──────────────────────────────────────────────────

CREATE TABLE lead (
    lead_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(50),
    zip_code VARCHAR(20),
    nycha_resident BOOLEAN DEFAULT false,
    status VARCHAR(50) DEFAULT 'new',
    applicant_id INTEGER REFERENCES applicant(applicant_id) ON DELETE SET NULL,
    user_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    converted_at TIMESTAMP,
    email_opt_out BOOLEAN DEFAULT false,
    email_opt_out_date TIMESTAMP,
    sms_opt_in BOOLEAN DEFAULT false,
    first_captured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lead_email ON lead(email);
CREATE INDEX idx_lead_status ON lead(status);
CREATE INDEX idx_lead_first_captured_at ON lead(first_captured_at);
CREATE INDEX idx_lead_applicant_id ON lead(applicant_id) WHERE applicant_id IS NOT NULL;

CREATE TABLE lead_source (
    source_id SERIAL PRIMARY KEY,
    lead_id INTEGER NOT NULL REFERENCES lead(lead_id) ON DELETE CASCADE,
    source_type VARCHAR(100) NOT NULL,
    source_name VARCHAR(255),
    source_detail VARCHAR(255),
    captured_at DATE NOT NULL,
    raw_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lead_source_lead_id ON lead_source(lead_id);
CREATE INDEX idx_lead_source_type ON lead_source(source_type);
CREATE INDEX idx_lead_source_captured_at ON lead_source(captured_at);

CREATE TABLE lead_engagement (
    engagement_id SERIAL PRIMARY KEY,
    lead_id INTEGER NOT NULL REFERENCES lead(lead_id) ON DELETE CASCADE,
    engagement_type VARCHAR(50) NOT NULL,
    engagement_subtype VARCHAR(100),
    email_subject TEXT,
    email_template_id UUID REFERENCES email_template(template_id),
    event_id UUID REFERENCES event(event_id) ON DELETE SET NULL,
    success BOOLEAN DEFAULT true,
    response TEXT,
    engaged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lead_engagement_lead_id ON lead_engagement(lead_id);
CREATE INDEX idx_lead_engagement_type ON lead_engagement(engagement_type);
CREATE INDEX idx_lead_engagement_engaged_at ON lead_engagement(engaged_at);

CREATE TABLE lead_note (
    note_id SERIAL PRIMARY KEY,
    lead_id INTEGER NOT NULL REFERENCES lead(lead_id) ON DELETE CASCADE,
    created_by INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    note_content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lead_note_lead_id ON lead_note(lead_id);
CREATE INDEX idx_lead_note_created_by ON lead_note(created_by);

CREATE TABLE email_list (
    list_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE lead_email_list (
    lead_id INTEGER NOT NULL REFERENCES lead(lead_id) ON DELETE CASCADE,
    list_id INTEGER NOT NULL REFERENCES email_list(list_id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (lead_id, list_id)
);

CREATE TABLE lead_source_config (
    config_id SERIAL PRIMARY KEY,
    source_type VARCHAR(100) NOT NULL,
    source_name VARCHAR(255),
    counts_as_info_session BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(source_type, source_name)
);

-- ─── EMAIL AUTOMATION ───────────────────────────────────────

CREATE TABLE email_automation_log (
    log_id SERIAL PRIMARY KEY,
    applicant_id INTEGER REFERENCES applicant(applicant_id),
    email_type VARCHAR(100) NOT NULL,
    email_sent_at TIMESTAMP DEFAULT now(),
    email_opened_at TIMESTAMP,
    email_clicked_at TIMESTAMP,
    send_count INTEGER DEFAULT 1,
    next_send_at TIMESTAMP,
    is_queued BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT now(),
    UNIQUE(applicant_id, email_type)
);

CREATE INDEX idx_email_automation_next_send ON email_automation_log(next_send_at) WHERE next_send_at IS NOT NULL;
CREATE INDEX idx_email_automation_queued ON email_automation_log(is_queued) WHERE is_queued = true;

-- ─── ONBOARDING ─────────────────────────────────────────────

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

CREATE TABLE applicant_onboarding_task_completions (
    completion_id SERIAL PRIMARY KEY,
    applicant_id INTEGER NOT NULL REFERENCES applicant(applicant_id) ON DELETE CASCADE,
    task_id INTEGER NOT NULL REFERENCES onboarding_tasks(task_id) ON DELETE CASCADE,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(applicant_id, task_id)
);
