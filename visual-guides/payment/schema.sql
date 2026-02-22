-- ============================================================
-- PAYMENT & FINANCIAL SYSTEM — DATABASE SCHEMA
-- PostgreSQL DDL for all payment-related tables
-- ============================================================

-- ─── DOCUMENTS ────────────────────────────────────────────────

CREATE TABLE payment_documents (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT payment_documents_type_check CHECK (document_type IN (
        'goodJobAgreement', 'billComGuide', 'bondFaqs', 'employmentContract'
    )),
    UNIQUE(user_id, document_type)
);

CREATE INDEX idx_payment_documents_user_id ON payment_documents(user_id);
CREATE INDEX idx_payment_documents_document_type ON payment_documents(document_type);
CREATE INDEX idx_payment_documents_user_type ON payment_documents(user_id, document_type);
CREATE INDEX idx_payment_documents_uploaded_at ON payment_documents(uploaded_at);

-- ─── EMPLOYMENT INFO ──────────────────────────────────────────

CREATE TABLE employment_info (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    company_name VARCHAR(255),
    position VARCHAR(255),
    start_date DATE,
    salary DECIMAL(10, 2),
    employment_type VARCHAR(50),
    status VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT employment_info_type_check CHECK (employment_type IN (
        'full-time', 'part-time', 'contract', 'freelance'
    ) OR employment_type IS NULL),
    CONSTRAINT employment_info_status_check CHECK (status IN (
        'employed', 'unemployed', 'job-searching', 'self-employed'
    ) OR status IS NULL)
);

CREATE INDEX idx_employment_info_user_id ON employment_info(user_id);
CREATE INDEX idx_employment_info_status ON employment_info(status);
CREATE INDEX idx_employment_info_employment_type ON employment_info(employment_type);
CREATE INDEX idx_employment_info_updated_at ON employment_info(updated_at);
