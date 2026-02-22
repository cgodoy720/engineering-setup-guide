-- ============================================================
-- LEARNING & CURRICULUM SYSTEM — DATABASE SCHEMA
-- PostgreSQL DDL for all learning & curriculum-related tables
-- ============================================================

-- ─── CURRICULUM STRUCTURE ────────────────────────────────────

CREATE TABLE curriculum_days (
    id SERIAL PRIMARY KEY,
    day_number INTEGER NOT NULL,
    day_date DATE NOT NULL,
    day_type VARCHAR(50),
    daily_goal TEXT,
    learning_objectives TEXT,
    cohort VARCHAR(255),
    cohort_id UUID REFERENCES cohort(cohort_id),
    level VARCHAR(50),
    week INTEGER,
    weekly_goal TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_curriculum_days_cohort ON curriculum_days(cohort);
CREATE INDEX idx_curriculum_days_cohort_id ON curriculum_days(cohort_id);
CREATE INDEX idx_curriculum_days_day_date ON curriculum_days(day_date);
CREATE INDEX idx_curriculum_days_day_number ON curriculum_days(day_number);
CREATE INDEX idx_curriculum_days_week ON curriculum_days(week);

CREATE TABLE time_blocks (
    id SERIAL PRIMARY KEY,
    day_id INTEGER NOT NULL REFERENCES curriculum_days(id) ON DELETE CASCADE,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    block_category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_time_blocks_day_id ON time_blocks(day_id);
CREATE INDEX idx_time_blocks_start_time ON time_blocks(start_time);

CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    block_id INTEGER NOT NULL REFERENCES time_blocks(id) ON DELETE CASCADE,
    task_title VARCHAR(255) NOT NULL,
    task_description TEXT,
    task_type VARCHAR(100),
    duration_minutes INTEGER,
    intro TEXT,
    conclusion TEXT,
    questions JSONB DEFAULT '[]',
    deliverable TEXT,
    deliverable_type VARCHAR(100),
    deliverable_schema JSONB,
    linked_resources JSONB DEFAULT '[]',
    should_analyze BOOLEAN DEFAULT false,
    analysis_type VARCHAR(100),
    task_mode VARCHAR(50) DEFAULT 'conversation',
    conversation_model VARCHAR(50),
    persona VARCHAR(255),
    ai_helper_mode VARCHAR(50),
    feedback_slot INTEGER,
    assessment_id INTEGER,
    smart_prompt TEXT,
    template JSONB,
    facilitator_notes JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT tasks_task_mode_check CHECK (task_mode IN ('basic', 'conversation', 'assessment'))
);

CREATE INDEX idx_tasks_block_id ON tasks(block_id);
CREATE INDEX idx_tasks_task_mode ON tasks(task_mode);
CREATE INDEX idx_tasks_task_type ON tasks(task_type);
CREATE INDEX idx_tasks_conversation_model ON tasks(conversation_model);

-- ─── LEARNING PROGRESS ──────────────────────────────────────

CREATE TABLE user_task_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    task_id INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'not_started',
    completion_time TIMESTAMP,
    is_preview BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, task_id, is_preview),
    CONSTRAINT user_task_progress_status_check CHECK (status IN ('not_started', 'in_progress', 'completed'))
);

CREATE INDEX idx_user_task_progress_user_id ON user_task_progress(user_id);
CREATE INDEX idx_user_task_progress_task_id ON user_task_progress(task_id);
CREATE INDEX idx_user_task_progress_status ON user_task_progress(status);
CREATE INDEX idx_user_task_progress_user_task ON user_task_progress(user_id, task_id);
CREATE INDEX idx_user_task_progress_is_preview ON user_task_progress(is_preview);

CREATE TABLE task_threads (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    task_id INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    thread_id INTEGER NOT NULL REFERENCES threads(thread_id) ON DELETE CASCADE,
    is_preview BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, task_id, is_preview)
);

CREATE INDEX idx_task_threads_user_id ON task_threads(user_id);
CREATE INDEX idx_task_threads_task_id ON task_threads(task_id);
CREATE INDEX idx_task_threads_thread_id ON task_threads(thread_id);
CREATE INDEX idx_task_threads_user_task ON task_threads(user_id, task_id);
CREATE INDEX idx_task_threads_is_preview ON task_threads(is_preview);

CREATE TABLE task_submissions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    task_id INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    feedback TEXT,
    is_preview BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_task_submissions_user_id ON task_submissions(user_id);
CREATE INDEX idx_task_submissions_task_id ON task_submissions(task_id);
CREATE INDEX idx_task_submissions_user_task ON task_submissions(user_id, task_id);
CREATE INDEX idx_task_submissions_is_preview ON task_submissions(is_preview);

-- ─── CHAT SYSTEM ───────────────────────────────────────────

CREATE TABLE threads (
    thread_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_threads_user_id ON threads(user_id);
CREATE INDEX idx_threads_created_at ON threads(created_at);
CREATE INDEX idx_threads_updated_at ON threads(updated_at);

CREATE TABLE conversation_messages (
    message_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    thread_id INTEGER NOT NULL REFERENCES threads(thread_id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_role VARCHAR(50) NOT NULL,
    is_preview BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT conversation_messages_role_check CHECK (message_role IN ('user', 'assistant', 'system'))
);

CREATE INDEX idx_conversation_messages_user_id ON conversation_messages(user_id);
CREATE INDEX idx_conversation_messages_thread_id ON conversation_messages(thread_id);
CREATE INDEX idx_conversation_messages_created_at ON conversation_messages(created_at);
CREATE INDEX idx_conversation_messages_is_preview ON conversation_messages(is_preview);
CREATE INDEX idx_conversation_messages_thread_created ON conversation_messages(thread_id, created_at);

-- ─── CONTENT MANAGEMENT ────────────────────────────────────

CREATE TABLE curriculum_change_history (
    id SERIAL PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INTEGER NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_by INTEGER NOT NULL REFERENCES users(user_id) ON DELETE SET NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cohort VARCHAR(255),
    change_context JSONB DEFAULT '{}',
    CONSTRAINT curriculum_change_history_entity_type_check CHECK (entity_type IN ('day', 'block', 'task'))
);

CREATE INDEX idx_curriculum_change_history_entity ON curriculum_change_history(entity_type, entity_id);
CREATE INDEX idx_curriculum_change_history_changed_by ON curriculum_change_history(changed_by);
CREATE INDEX idx_curriculum_change_history_changed_at ON curriculum_change_history(changed_at);
CREATE INDEX idx_curriculum_change_history_cohort ON curriculum_change_history(cohort);

CREATE TABLE content_generation_prompts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(255) NOT NULL,
    description TEXT,
    content TEXT NOT NULL,
    prompt_type VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT content_generation_prompts_prompt_type_check CHECK (prompt_type IN ('json_generation', 'facilitator_notes', 'other'))
);

CREATE INDEX idx_content_generation_prompts_prompt_type ON content_generation_prompts(prompt_type);
CREATE INDEX idx_content_generation_prompts_is_active ON content_generation_prompts(is_active);
CREATE INDEX idx_content_generation_prompts_is_default ON content_generation_prompts(is_default);
