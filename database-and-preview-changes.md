# Database Schema Changes & Content Preview Feature Documentation

**Date:** February 1, 2026  
**Author:** Development Team  
**Purpose:** Document database schema updates and the Content Preview page implementation

---

## Table of Contents

1. [Overview](#overview)
2. [Database Changes](#database-changes)
   - [New Tables](#new-tables)
   - [Modified Tables](#modified-tables)
   - [Preview System (is_preview flag)](#preview-system-is_preview-flag)
3. [Content Preview Page](#content-preview-page)
4. [Migration Guide](#migration-guide)

---

## Overview

This document covers two major updates to the system:

1. **Organizational Structure**: New hierarchical data model (Organization → Program → Course → Cohort) to support multi-tenant operations
2. **Preview System**: New `is_preview` flag system to allow staff/admin to test curriculum content without affecting real student data

---

## Database Changes

### New Tables

#### 1. `organizations` Table
Represents top-level organizations (e.g., universities, companies, external partners).

```sql
CREATE TABLE organizations (
    organization_id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    contact_email VARCHAR(255),
    contact_name VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Indexes:**
- `idx_organizations_name` on `name`

**Key Points:**
- Each organization can have multiple programs
- Contact information for organization-level communication
- Auto-updates `updated_at` via trigger

---

#### 2. `program` Table
Represents programs within an organization (e.g., "AI-Native Builder Program", "UFT AI Ambassadors").

```sql
CREATE TABLE program (
    program_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id INTEGER NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    description TEXT,
    program_type VARCHAR(50) DEFAULT 'builder',
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT program_type_check CHECK (program_type IN ('builder', 'workshop', 'external', 'enterprise')),
    CONSTRAINT program_name_org_unique UNIQUE(organization_id, name),
    CONSTRAINT program_slug_unique UNIQUE(slug)
);
```

**Indexes:**
- `idx_program_organization_id` on `organization_id`
- `idx_program_type` on `program_type`
- `idx_program_active` on `active` (partial index where active = true)

**Key Points:**
- Programs belong to an organization (cascading delete)
- Program types: `builder`, `workshop`, `external`, `enterprise`
- Unique slug across all programs (for URLs)
- Unique name within each organization

---

#### 3. `course` Table
Represents courses within a program (e.g., "Level 1: Foundations", "Level 2: Intermediate").

```sql
CREATE TABLE course (
    course_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    program_id UUID NOT NULL REFERENCES program(program_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    description TEXT,
    level VARCHAR(20),
    sequence_order INTEGER NOT NULL DEFAULT 1,
    duration_weeks INTEGER,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT course_name_program_unique UNIQUE(program_id, name),
    CONSTRAINT course_slug_program_unique UNIQUE(program_id, slug),
    CONSTRAINT course_sequence_program_unique UNIQUE(program_id, sequence_order)
);
```

**Indexes:**
- `idx_course_program_id` on `program_id`
- `idx_course_level` on `level`
- `idx_course_sequence` on `(program_id, sequence_order)`
- `idx_course_active` on `active` (partial index where active = true)

**Key Points:**
- Courses belong to a program (cascading delete)
- Level field (e.g., "L1", "L2", "L3", "L3+") for curriculum organization
- Sequence order ensures proper ordering within a program
- Duration in weeks for planning purposes

---

### Modified Tables

#### 1. `cohort` Table - NEW COLUMNS

The cohort table (which represents specific class offerings) received new columns:

**New Columns:**
```sql
ALTER TABLE cohort ADD COLUMN course_id UUID;
ALTER TABLE cohort ADD COLUMN is_current_signup BOOLEAN DEFAULT false;

ALTER TABLE cohort ADD CONSTRAINT cohort_course_id_fkey 
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE SET NULL;
```

**New Indexes:**
```sql
CREATE INDEX idx_cohort_course_id ON cohort(course_id);
CREATE UNIQUE INDEX idx_cohort_current_signup ON cohort(course_id) 
    WHERE is_current_signup = true;
```

**What This Means:**
- `course_id`: Links each cohort to its parent course
- `is_current_signup`: Marks which cohort should receive new signups (only ONE per course can be marked as current)

**Existing Cohort Structure:**
```sql
CREATE TABLE cohort (
    cohort_id UUID PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    cohort_type VARCHAR(50) DEFAULT 'builder',
    description TEXT,
    contact_email VARCHAR(255),
    contact_name VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    access_code VARCHAR(50),
    is_ai_native BOOLEAN DEFAULT false,
    -- NEW COLUMNS
    course_id UUID,
    is_current_signup BOOLEAN DEFAULT false,
    CONSTRAINT cohort_type_check CHECK (cohort_type IN ('builder', 'workshop', 'external'))
);
```

---

#### 2. `user_enrollment` Table

New table to track user enrollment history across multiple cohorts:

```sql
CREATE TABLE user_enrollment (
    enrollment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    cohort_id UUID NOT NULL REFERENCES cohort(cohort_id) ON DELETE CASCADE,
    enrolled_date DATE DEFAULT CURRENT_DATE,
    completion_date DATE,
    withdrawal_date DATE,
    status VARCHAR(50) DEFAULT 'in_progress',
    is_active BOOLEAN DEFAULT true,
    last_viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT enrollment_status_check CHECK (status IN ('in_progress', 'completed', 'withdrawn', 'deferred', 'paused')),
    CONSTRAINT enrollment_user_cohort_unique UNIQUE(user_id, cohort_id)
);
```

**Indexes:**
- `idx_enrollment_user_id` on `user_id`
- `idx_enrollment_cohort_id` on `cohort_id`
- `idx_enrollment_status` on `status`
- `idx_enrollment_active` on `is_active` (partial index where is_active = true)

**Key Points:**
- Users can have multiple enrollments (historical tracking)
- Only ONE active enrollment per user at a time (`is_active = true`)
- Status tracks progression: `in_progress`, `completed`, `withdrawn`, `deferred`, `paused`
- Notes field for administrative comments

---

### Preview System (`is_preview` Flag)

**Migration:** `051_add_preview_flags.sql` (January 27, 2026)

The preview system allows staff/admin/volunteers to test curriculum content without affecting:
- Real student submissions
- Real progress tracking
- Real survey responses
- Real assessment submissions

**Tables Modified with `is_preview` Column:**

#### 1. `task_submissions`
```sql
ALTER TABLE task_submissions 
ADD COLUMN IF NOT EXISTS is_preview BOOLEAN DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_task_submissions_preview 
ON task_submissions(user_id, is_preview) 
WHERE is_preview = true;
```
- Tracks which deliverable submissions were made in preview mode
- Staff can test task submissions without affecting real student data

#### 2. `conversation_messages`
```sql
ALTER TABLE conversation_messages 
ADD COLUMN IF NOT EXISTS is_preview BOOLEAN DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_conversation_messages_preview 
ON conversation_messages(user_id, is_preview) 
WHERE is_preview = true;
```
- Separates preview chat messages from real student conversations
- Allows staff to test AI interactions

#### 3. `user_task_progress`
```sql
ALTER TABLE user_task_progress 
ADD COLUMN IF NOT EXISTS is_preview BOOLEAN DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_user_task_progress_preview 
ON user_task_progress(user_id, is_preview) 
WHERE is_preview = true;
```
- Tracks task completion status separately for preview mode
- Prevents preview testing from marking tasks as "completed" in real progress

#### 4. `builder_feedback`
```sql
ALTER TABLE builder_feedback 
ADD COLUMN IF NOT EXISTS is_preview BOOLEAN DEFAULT false;
```
- Survey responses submitted in preview mode are flagged
- Real survey data remains unaffected by staff testing

#### 5. `task_threads`
```sql
ALTER TABLE task_threads 
ADD COLUMN IF NOT EXISTS is_preview BOOLEAN DEFAULT false;
```
**Migration:** `054_separate_preview_threads.sql`

**Unique Constraint Changed:**
- **OLD:** `UNIQUE (user_id, task_id)`
- **NEW:** `UNIQUE (user_id, task_id, is_preview)`

This allows:
- `(user_id=1, task_id=100, is_preview=false)` - real work
- `(user_id=1, task_id=100, is_preview=true)` - preview work

Both can coexist independently!

#### 6. `assessment_submissions`
**Migration:** `056_separate_preview_assessments.sql`

**Unique Constraint Changed:**
- **OLD:** `UNIQUE (user_id, assessment_id)`
- **NEW:** `UNIQUE (user_id, assessment_id, is_preview)`

Same separation principle - allows staff to preview assessments without affecting their real submissions.

---

## Content Preview Page

**File:** `pilot-client/src/pages/ContentPreview/ContentPreview.jsx`

### Purpose

The Content Preview page allows staff, admin, and volunteer users to:
1. **View curriculum content** in read-only mode
2. **Test content interactively** (same experience as students)
3. **Edit curriculum** (staff/admin only)
4. **Clear test data** without affecting real work

### Access Control

```javascript
const hasPreviewAccess = user?.role === 'admin' || user?.role === 'staff' || user?.role === 'volunteer';
const canEdit = user?.role === 'admin' || user?.role === 'staff';
```

- **Preview Access:** admin, staff, volunteer
- **Edit Access:** admin, staff only

### Two Modes

#### 1. Read-Only Mode (Default)
- Select cohort and day from sidebar
- View day structure, tasks, and content
- See task details in card format
- **Staff/Admin:** Edit tasks, goals, move tasks, delete tasks/days
- Button to enter Interactive Mode

#### 2. Interactive Mode
- Full student experience
- AI chat interactions
- Task submissions
- Deliverable uploads
- Surveys and assessments
- All interactions flagged with `is_preview = true`
- Button to clear test data

### Key Features

#### A. Cohort & Day Selection
**Component:** `CohortDaySelector`

- Lists all available cohorts
- Shows curriculum days for selected cohort
- Updates URL parameters for deep linking

#### B. Content Display
- Day header with goal and metadata
- Task cards showing:
  - Task title and description
  - Time range
  - Task type and mode
  - Deliverable requirements
  - Linked resources
- Edit/Delete buttons (for staff/admin)

#### C. Clear Test Data Function
```javascript
const handleClearTestData = async () => {
  // Deletes ONLY preview data (is_preview = true):
  // - Conversation messages
  // - Task threads
  // - Task submissions
  // - Assessment submissions
  // - Progress tracking
  // - Survey responses
  // - LocalStorage survey progress
}
```

**What Gets Deleted:**
- ✅ All preview submissions (`is_preview = true`)
- ✅ All preview conversation threads and messages
- ✅ All preview progress records
- ✅ All preview survey responses
- ✅ Cached survey data in localStorage
- ❌ Real student work (`is_preview = false`) - **NEVER TOUCHED**

#### D. Task Editing (Staff/Admin Only)

**Features:**
- Edit task content (title, description, intro, conclusion, questions)
- Edit deliverable settings
- Edit task mode (basic, chat, smart)
- View field history (all past versions)
- Revert to previous versions
- Move task to different day
- Delete task (with confirmation)

**Dialogs:**
- `TaskEditDialog` - Edit task fields
- `FieldHistoryDialog` - View/revert field changes
- `MoveTaskDialog` - Move task to different day
- `TaskCreateDialog` - Create new task
- `DayGoalEditor` - Edit day goals

#### E. URL Parameters

The page uses URL parameters for deep linking:
- `?cohort=...` - Selected cohort (JSON encoded)
- `?day=...` - Selected day ID

### API Endpoints Used

#### Read Operations:
- `GET /api/curriculum/days/:dayId/full-details?cohort=...` - Get day content
- Query includes all tasks, blocks, and metadata

#### Write Operations (Staff/Admin):
- `PUT /api/curriculum/tasks/:taskId/edit?cohort=...` - Update task
- `PUT /api/curriculum/blocks/:blockId/edit?cohort=...` - Update time block
- `PUT /api/curriculum/days/:dayId/edit?cohort=...` - Update day goals
- `POST /api/curriculum/tasks/:taskId/move?cohort=...` - Move task
- `POST /api/curriculum/tasks` - Create task
- `DELETE /api/curriculum/tasks/:taskId` - Delete task
- `DELETE /api/curriculum/days/:dayId` - Delete day
- `POST /api/curriculum/revert?cohort=...` - Revert field to previous value
- `DELETE /api/preview/clear-my-data` - Clear preview data

### Preview Mode Banner

Appears at top of page in both modes:

**Read-Only Mode:**
```
🔍 PREVIEW MODE - Select a cohort and day to preview content
[▶ Enter Interactive Mode] [Clear My Test Data]
```

**Interactive Mode:**
```
🔍 PREVIEW MODE - Interactive
{Cohort Name} • Day {Number}
[← Back to Overview] [Clear My Test Data]
```

### Component Structure

```
ContentPreview.jsx
├── CohortDaySelector (left sidebar)
│   ├── Cohort list
│   └── Day list (for selected cohort)
├── Content Display (main area)
│   ├── Day header
│   ├── Daily goal
│   ├── Task cards
│   └── Interactive mode CTA
└── Dialogs
    ├── TaskEditDialog
    ├── TaskCreateDialog
    ├── FieldHistoryDialog
    ├── DayGoalEditor
    ├── MoveTaskDialog
    ├── DeleteTaskDialog
    └── DeleteDayDialog
```

### Data Flow

1. **User selects cohort** → `handleCohortSelect()`
   - Updates state
   - Clears day selection
   - Updates URL

2. **User selects day** → `handleDaySelect()` → `loadDayContent()`
   - Fetches full day details
   - Updates state
   - Updates URL

3. **User enters interactive mode** → `setPreviewMode('interactive')`
   - Renders `LearningPreview` component
   - All interactions flagged with `is_preview = true`

4. **User clears test data** → `handleClearTestData()`
   - Calls backend API
   - Deletes all preview records
   - Clears localStorage
   - Resets to cohort view

### Backend Integration

The backend checks for `is_preview` query parameter or context:

```javascript
// Example from learningController.js
const isPreviewMode = req.query.preview === 'true' || 
                     req.headers['x-preview-mode'] === 'true';

// When creating thread
const thread = await db.one(
  `INSERT INTO task_threads (user_id, task_id, thread_id, is_preview) 
   VALUES ($1, $2, $3, $4)
   ON CONFLICT (user_id, task_id, is_preview) 
   DO UPDATE SET thread_id = task_threads.thread_id
   RETURNING thread_id`,
  [userId, taskId, newThreadId, isPreviewMode]
);
```

---

## Migration Guide

### For Existing Data

1. **Run organizational structure migrations:**
   ```bash
   # Create organizations, programs, courses tables
   psql -f migrations/XXX_organizational_structure.sql
   ```

2. **Run preview system migrations:**
   ```bash
   # Add is_preview columns
   psql -f migrations/051_add_preview_flags.sql
   
   # Update unique constraints for threads
   psql -f migrations/054_separate_preview_threads.sql
   
   # Update unique constraints for surveys
   psql -f migrations/055_separate_preview_surveys.sql
   
   # Update unique constraints for assessments
   psql -f migrations/056_separate_preview_assessments.sql
   ```

3. **Populate organizational data:**
   ```sql
   -- Create organizations
   INSERT INTO organizations (name, description) 
   VALUES ('Pursuit', 'Pursuit AI-Native Builder Program');
   
   -- Create programs
   INSERT INTO program (organization_id, name, slug, program_type)
   VALUES 
     (1, 'AI-Native Builder Program', 'ai-native', 'builder');
   
   -- Create courses
   INSERT INTO course (program_id, name, slug, level, sequence_order)
   VALUES
     ((SELECT program_id FROM program WHERE slug = 'ai-native'), 
      'Level 1: Foundations', 'level-1', 'L1', 1);
   
   -- Link existing cohorts to courses
   UPDATE cohort 
   SET course_id = (SELECT course_id FROM course WHERE level = 'L1')
   WHERE name IN ('March 2025', 'June 2025');
   ```

### For New Cohorts

When creating a new cohort:
```sql
INSERT INTO cohort (
  cohort_id, 
  name, 
  start_date, 
  course_id, 
  is_current_signup
) VALUES (
  gen_random_uuid(),
  'February 2026',
  '2026-02-01',
  (SELECT course_id FROM course WHERE slug = 'level-1'),
  true  -- Mark as current signup
);
```

**Important:** Only ONE cohort per course can have `is_current_signup = true`. The database enforces this with a unique partial index.

### For User Enrollment

When a user signs up:
```sql
-- Create user enrollment record
INSERT INTO user_enrollment (
  user_id, 
  cohort_id, 
  enrolled_date, 
  is_active, 
  status
) VALUES (
  :user_id,
  (SELECT cohort_id FROM cohort WHERE is_current_signup = true LIMIT 1),
  CURRENT_DATE,
  true,
  'in_progress'
);
```

---

## Summary of Key Changes

### Database Hierarchy
```
organizations (e.g., Pursuit)
  ↓
program (e.g., AI-Native Builder Program)
  ↓
course (e.g., Level 1: Foundations)
  ↓
cohort (e.g., March 2025, February 2026)
  ↓
user_enrollment (links users to cohorts with history)
```

### New Columns Summary

| Table | New Column | Type | Purpose |
|-------|-----------|------|---------|
| `cohort` | `course_id` | UUID | Links cohort to parent course |
| `cohort` | `is_current_signup` | BOOLEAN | Marks cohort for new signups |
| `task_submissions` | `is_preview` | BOOLEAN | Flags preview submissions |
| `conversation_messages` | `is_preview` | BOOLEAN | Flags preview messages |
| `user_task_progress` | `is_preview` | BOOLEAN | Flags preview progress |
| `builder_feedback` | `is_preview` | BOOLEAN | Flags preview surveys |
| `task_threads` | `is_preview` | BOOLEAN | Flags preview threads |
| `assessment_submissions` | `is_preview` | BOOLEAN | Flags preview assessments |

### ContentPreview Page Features

✅ Read-only content viewing  
✅ Interactive student experience testing  
✅ Task editing (staff/admin)  
✅ Field history tracking and reversion  
✅ Task creation and deletion  
✅ Day goal editing  
✅ Task movement between days  
✅ Clear test data (preview only)  
✅ Deep linking via URL parameters  
✅ Role-based access control  

---

## Questions?

For technical questions about:
- **Database schema:** Contact backend team
- **Content Preview page:** Contact frontend team
- **Migration issues:** Contact DevOps team

**Last Updated:** February 1, 2026
