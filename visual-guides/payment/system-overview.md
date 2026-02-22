# Payment & Financial System — Overview

## Architecture

The Payment & Financial system manages user financial documentation, employment information, and invoice calculations. It consists of two user-facing sides:

- **User Portal** — Pages for users to upload documents, manage employment info, calculate invoices, and schedule financial planning
- **Admin Dashboard** — Staff-only dashboard requiring `page:payment_admin` permission

### Tech Stack

- **Client**: React 19 + Vite, MUI v7, Tailwind, React Router v6, React Query
- **Server**: Express.js, PostgreSQL (pg-promise), JWT auth
- **Storage**: Google Cloud Storage (GCS) with signed URLs

---

## User-Facing Routes

| Route | Component | Purpose |
|---|---|---|
| `/payment` | Payment | Main user portal: document uploads (Good Job Agreement, Bill.com Guide, Bond FAQs, Employment Contract), invoice calculator (tiered/flat rates), employment info management, financial planning scheduling (Calendly) |
| `/payment-terms` | PaymentTerms | Static terms page with FAQs and definitions. No authentication required. |

## Admin Routes

| Route | Purpose |
|---|---|
| `/payment-admin` | Admin dashboard: user search/selection, upload documents for users, preview documents. Requires `page:payment_admin` permission. |

---

## Document Types

Users can upload four types of documents:

- `goodJobAgreement` — Good Job Agreement document
- `billComGuide` — Bill.com Guide document
- `bondFaqs` — Bond FAQs document
- `employmentContract` — Employment Contract document

Each user can have only one document per type (enforced by UNIQUE constraint on `user_id + document_type`).

---

## API Endpoints

### /api/payment/admin (Admin)

- `POST /upload-document` — Upload document for user (requires `page:payment_admin`)
  - Body: `userId`, `documentType`, `file` (multipart/form-data)
  - Returns: Document metadata with signed URL
- `GET /documents/:userId` — Get all documents for a user
  - Returns: Array of document objects with signed URLs

### /api/payment (User)

- `POST /upload-document` — Upload own document
  - Body: `documentType`, `file` (multipart/form-data)
  - Returns: Document metadata with signed URL
- `GET /documents` — Get own documents
  - Returns: Array of document objects with signed URLs
- `PUT /employment-info` — Update employment info
  - Body: `companyName`, `position`, `startDate`, `salary`, `employmentType`, `status`
  - Returns: Updated employment info
- `GET /employment-info` — Get employment info
  - Returns: Employment info object or null

---

## Database Tables (2 total)

### payment_documents

- **id** — SERIAL PRIMARY KEY
- **user_id** — INTEGER NOT NULL REFERENCES users(user_id)
- **document_type** — VARCHAR(50) NOT NULL (goodJobAgreement, billComGuide, bondFaqs, employmentContract)
- **original_name** — VARCHAR(255) NOT NULL
- **file_name** — VARCHAR(255) NOT NULL
- **file_path** — VARCHAR(500) NOT NULL (GCS path)
- **file_url** — TEXT (signed URL, temporary)
- **uploaded_at** — TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- **UNIQUE(user_id, document_type)**

### employment_info

- **id** — SERIAL PRIMARY KEY
- **user_id** — INTEGER UNIQUE NOT NULL REFERENCES users(user_id)
- **company_name** — VARCHAR(255)
- **position** — VARCHAR(255)
- **start_date** — DATE
- **salary** — DECIMAL(10, 2)
- **employment_type** — VARCHAR(50) (full-time, part-time, contract, freelance)
- **status** — VARCHAR(50) (employed, unemployed, job-searching, self-employed)
- **updated_at** — TIMESTAMP DEFAULT CURRENT_TIMESTAMP

---

## Storage

All document files are stored in Google Cloud Storage (GCS). The database stores metadata and file paths. Signed URLs are generated on-demand for secure access with expiration times. Files are organized by `user_id` and `document_type`.

---

## Key Files

### Client (`pilot-client/src/`)

- `pages/Payment/Payment.jsx` — Main user portal
- `pages/Payment/PaymentAdmin.jsx` — Admin dashboard
- `pages/Payment/PaymentTerms.jsx` — Static terms page

### Server (`test-pilot-server/`)

- `controllers/paymentController.js` — Payment API logic (admin and user routes)
- `routes/paymentRoutes.js` — Route definitions
- `db/schema.sql` — Database schema DDL

---

## Related Visual Guides

- `system-overview.html` — Visual guide with architecture diagrams
- `schema.sql` — Complete DDL for all payment-related tables
