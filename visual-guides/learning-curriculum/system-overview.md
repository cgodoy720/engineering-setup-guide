# Learning & Curriculum System — Overview

## Architecture

The Learning & Curriculum system powers AI-driven, task-based learning experiences. It combines hierarchical curriculum management (Days → Time Blocks → Tasks) with intelligent AI conversations, streaming responses, multiple task modes, and comprehensive progress tracking. The system supports cohort-based learning with permission-based content editing and change history.

### Tech Stack

- **Client**: React 19 + Vite, MUI v7, Tailwind, React Router v6, React Query
- **Server**: Express.js, PostgreSQL (pg-promise), JWT auth
- **AI**: Claude (Anthropic), GPT (OpenAI), Gemini (Google) for task conversations and content generation

---

## Pages

| Route | Component | Purpose | Permissions |
|---|---|---|---|
| `/learning` | Learning | Daily overview with task list, task-based chat interface. Supports modes: basic/conversation/assessment. Survey integration, deliverable submission, peer feedback. Streaming AI responses (SSE), model selection (Claude, GPT, Gemini). | None |
| `/content` | Content | Wrapper for CurriculumEditor. Full CRUD for days, blocks, and tasks. Cohort-based editing with change history. | `content` |
| `/content-preview` | ContentPreview | Read-only and interactive preview modes. Cohort/day selector, task editing, field history viewing, curriculum upload, test data clearing. | None |
| `/dashboard` | Dashboard | Today's goal, weekly agenda cards, task completion status, missed assignments, course switcher, week navigation. | None |
| `/gpt` | GPT | General-purpose AI chat. Thread management, file upload/URL processing, model selection, streaming responses. | None |

---

## Key Systems

### 1. AI-Powered Learning

Task-based conversations with AI personas, SSE streaming, model selection (Claude, GPT, Gemini), task modes (basic: sequential questions, conversation: open-ended with [TASK_COMPLETE] detection, assessment), completion detection, preview mode.

**Task Modes:**
- **Basic**: Sequential question-based flow. AI asks questions one at a time from the task's `questions[]` array.
- **Conversation**: Open-ended dialogue with AI persona. Completion detected via `[TASK_COMPLETE]` token in AI response or manual completion.
- **Assessment**: Structured assessment with scoring. May include deliverable submission and peer feedback integration.

**Completion Tracking:**
- `user_task_progress` tracks status (not_started/in_progress/completed) per user+task+preview
- `task_threads` links conversations to specific tasks (UNIQUE: user_id+task_id+is_preview)
- `task_submissions` stores deliverable content and feedback
- Preview mode (`is_preview=true`) allows testing without affecting real progress

### 2. Curriculum Management

Hierarchical: Days → Time Blocks → Tasks. Cohort-based, change history with revert, bulk JSON upload, permission-based editing.

**Structure:**
- **Days**: `day_number`, `day_date`, `day_type`, `daily_goal`, `learning_objectives`, `cohort`, `cohort_id`, `level`, `week`, `weekly_goal`
- **Time Blocks**: `start_time`, `end_time`, `block_category`
- **Tasks**: `task_title`, `task_description`, `task_type`, `duration_minutes`, `intro`, `conclusion`, `questions[]`, `deliverable`, `deliverable_type`, `deliverable_schema` (JSONB), `linked_resources` (JSONB), `should_analyze`, `analysis_type`, `task_mode`, `conversation_model`, `persona`, `ai_helper_mode`, `feedback_slot`, `assessment_id`, `smart_prompt`, `template` (JSONB), `facilitator_notes` (JSONB)

### 3. Content Generation

AI-powered JSON generation from text/URL/file, multi-day detection, facilitator notes, admin-editable prompts, Google Docs support.

### 4. Chat System

Task-specific threads (`task_threads`), general threads (`threads`), conversation summarization, cross-thread relevance via embeddings, article discussion.

---

## API Endpoints

### /api/learning

- `GET /personas` — Retrieve available AI personas
- `POST /task/:taskId/message` — Start or continue task conversation
- `GET /task/:taskId/stream` — SSE streaming response
- `POST /task/:taskId/complete` — Mark task as complete
- `GET /batch-completion-status` — Get completion status for multiple tasks
- Model selection via request body (Claude, GPT, Gemini)

### /api/curriculum

- `GET /days` — List days (with cohort filter)
- `GET /days/:dayId` — Get day details
- `POST /days` — Create day
- `PUT /days/:dayId` — Update day
- `DELETE /days/:dayId` — Delete day
- `GET /blocks/:blockId` — Get block details
- `POST /blocks` — Create block
- `PUT /blocks/:blockId` — Update block
- `DELETE /blocks/:blockId` — Delete block
- `GET /tasks/:taskId` — Get task details
- `POST /tasks` — Create task
- `PUT /tasks/:taskId` — Update task
- `DELETE /tasks/:taskId` — Delete task
- `GET /history/:entityType/:entityId` — Get change history
- `POST /revert` — Revert field change
- `POST /bulk-upload` — Bulk JSON upload
- `GET /calendar` — Calendar view

### /api/chat

- `GET /threads` — List threads
- `POST /threads` — Create thread
- `GET /threads/:threadId` — Get thread details
- `PUT /threads/:threadId` — Update thread
- `DELETE /threads/:threadId` — Delete thread
- `GET /threads/:threadId/messages` — Get messages
- `POST /threads/:threadId/messages` — Create message
- `GET /threads/:threadId/stream` — SSE streaming response
- `POST /article-discussion` — Discuss article with context

### /api/content

- `POST /generate-json` — Generate JSON from text/URL/file
- `POST /generate-facilitator-notes` — Generate facilitator notes
- `GET /prompts` — List content generation prompts
- `PUT /prompts/:promptId` — Update prompt (admin)

---

## Database Tables (10 core tables)

### Curriculum Structure (3 tables)

- **curriculum_days** — Days with goals, objectives, cohort, level, week
  - `id` (PK), `day_number`, `day_date`, `day_type`, `daily_goal`, `learning_objectives`, `cohort`, `cohort_id` (FK), `level`, `week`, `weekly_goal`

- **time_blocks** — Time blocks within days
  - `id` (PK), `day_id` (FK), `start_time`, `end_time`, `block_category`

- **tasks** — Tasks with modes, personas, questions, deliverables
  - `id` (PK), `block_id` (FK), `task_title`, `task_description`, `task_type`, `duration_minutes`, `intro`, `conclusion`, `questions[]`, `deliverable`, `deliverable_type`, `deliverable_schema` (JSONB), `linked_resources` (JSONB), `should_analyze`, `analysis_type`, `task_mode`, `conversation_model`, `persona`, `ai_helper_mode`, `feedback_slot`, `assessment_id`, `smart_prompt`, `template` (JSONB), `facilitator_notes` (JSONB)

### Learning Progress (3 tables)

- **user_task_progress** — Task completion status
  - `id` (PK), `user_id` (FK), `task_id` (FK), `status`, `completion_time`, `is_preview`
  - UNIQUE: `user_id` + `task_id` + `is_preview`

- **task_threads** — Task-specific conversation threads
  - `id` (PK), `user_id` (FK), `task_id` (FK), `thread_id` (FK), `is_preview`
  - UNIQUE: `user_id` + `task_id` + `is_preview`

- **task_submissions** — Deliverable submissions and feedback
  - `id` (PK), `user_id` (FK), `task_id` (FK), `content`, `feedback`, `is_preview`

### Chat System (2 tables)

- **threads** — General conversation threads
  - `thread_id` (PK), `user_id` (FK), `title`, `created_at`, `updated_at`

- **conversation_messages** — Messages with metadata
  - `message_id` (PK), `user_id` (FK), `thread_id` (FK), `content`, `message_role`, `is_preview`, `metadata` (JSONB)

### Content Management (2 tables)

- **curriculum_change_history** — Field-level change tracking
  - `id` (PK), `entity_type`, `entity_id`, `field_name`, `old_value`, `new_value`, `changed_by`, `changed_at`, `cohort`, `change_context` (JSONB)

- **content_generation_prompts** — Admin-editable AI prompts
  - `id` (PK), `name`, `display_name`, `description`, `content`, `prompt_type`, `is_default`, `is_active`

---

## Key Files

### Client (`pilot-client/src/`)

- `pages/Learning/Learning.jsx` — Main learning page with task list and chat
- `pages/Learning/Dashboard.jsx` — Today's goal and weekly agenda
- `pages/Content/Content.jsx` — Curriculum editor wrapper
- `pages/Content/ContentPreview.jsx` — Preview mode with editing
- `pages/Chat/GPT.jsx` — General-purpose AI chat

### Server (`test-pilot-server/`)

- `controllers/learningController.js` — Learning API logic
- `controllers/curriculumController.js` — Curriculum CRUD and history
- `controllers/chatController.js` — Chat threads and messages
- `controllers/contentController.js` — Content generation
- `queries/curriculum.js` — Database queries
- `routes/learningRoutes.js` — Route definitions
- `db/database-schema.sql` — Full schema DDL

---

## Related Visual Guides

- `system-overview.html` — Visual guide with architecture diagrams
- `schema.sql` — Complete DDL for all learning & curriculum tables
