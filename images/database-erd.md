# Database Entity Relationship Diagram

## Core User Management System

```
┌─────────────────┐    1:1    ┌─────────────────┐
│     users       │◄─────────►│  user_profiles  │
│                 │           │                 │
│ • user_id (PK)  │           │ • profile_id    │
│ • first_name    │           │ • user_id (FK)  │
│ • last_name     │           │ • job_role      │
│ • email         │           │ • experience    │
│ • password_hash │           │ • career_goals  │
│ • role          │           │ • interests     │
│ • cohort        │           │ • github_url    │
│ • github_*      │           │ • linkedin_url  │
│ • verified      │           └─────────────────┘
└─────────────────┘
         │
         │ 1:M
         ▼
┌─────────────────┐
│password_reset_  │
│     tokens      │
│                 │
│ • token_id      │
│ • user_id (FK)  │
│ • token         │
│ • expires_at    │
└─────────────────┘
```

## Learning Management System

```
┌─────────────────┐    1:M    ┌─────────────────┐    1:M    ┌─────────────────┐
│ curriculum_days │◄─────────►│  time_blocks    │◄─────────►│     tasks       │
│                 │           │                 │           │                 │
│ • id (PK)       │           │ • id (PK)       │           │ • id (PK)       │
│ • day_number    │           │ • day_id (FK)   │           │ • block_id (FK) │
│ • day_date      │           │ • start_time    │           │ • task_title    │
│ • day_type      │           │ • end_time      │           │ • description   │
│ • daily_goal    │           │ • block_category│           │ • task_type     │
│ • objectives    │           └─────────────────┘           │ • agent_prompt  │
│ • cohort        │                                         │ • deliverable   │
└─────────────────┘                                         │ • should_analyze│
                                                            └─────────────────┘
                                                                     │
                                                                     │ 1:M
                                                                     ▼
                                                            ┌─────────────────┐
                                                            │task_submissions │
                                                            │                 │
                                                            │ • id (PK)       │
                                                            │ • user_id (FK)  │
                                                            │ • task_id (FK)  │
                                                            │ • content       │
                                                            │ • feedback      │
                                                            └─────────────────┘
```

## User Progress & Interactions

```
┌─────────────────┐           ┌─────────────────┐           ┌─────────────────┐
│     users       │    1:M    │user_task_progress│    M:1    │     tasks       │
│                 │◄─────────►│                 │◄─────────►│                 │
│ • user_id (PK)  │           │ • user_id (FK)  │           │ • id (PK)       │
└─────────────────┘           │ • task_id (FK)  │           └─────────────────┘
         │                    │ • status        │
         │ 1:M                │ • progress      │
         ▼                    └─────────────────┘
┌─────────────────┐
│user_daily_      │
│   progress      │
│                 │
│ • user_id (FK)  │
│ • date          │
│ • tasks_completed│
│ • time_spent    │
└─────────────────┘

┌─────────────────┐           ┌─────────────────┐
│     users       │    1:M    │agent_interactions│
│                 │◄─────────►│                 │
│ • user_id (PK)  │           │ • interaction_id│
└─────────────────┘           │ • user_id (FK)  │
                              │ • task_id (FK)  │
                              │ • type          │
                              │ • content       │
                              │ • read_status   │
                              └─────────────────┘
```

## Conversation & Threading System

```
┌─────────────────┐    1:M    ┌─────────────────┐    1:M    ┌─────────────────┐
│     users       │◄─────────►│    threads      │◄─────────►│conversation_    │
│                 │           │                 │           │   messages      │
│ • user_id (PK)  │           │ • thread_id (PK)│           │                 │
└─────────────────┘           │ • user_id (FK)  │           │ • message_id    │
         │                    │ • title         │           │ • user_id (FK)  │
         │ 1:M                └─────────────────┘           │ • thread_id (FK)│
         ▼                             │                    │ • content       │
┌─────────────────┐                    │ 1:M               │ • message_role  │
│  task_threads   │                    ▼                    └─────────────────┘
│                 │           ┌─────────────────┐
│ • task_id (FK)  │           │conversation_    │
│ • thread_id (FK)│           │  embeddings     │
└─────────────────┘           │                 │
                              │ • embedding_id  │
                              │ • thread_id (FK)│
                              │ • text          │
                              │ • embedding     │
                              │ • metadata      │
                              └─────────────────┘
```

## AI & Vector Search

```
┌─────────────────┐    1:M    ┌─────────────────┐
│     users       │◄─────────►│user_embeddings  │
│                 │           │                 │
│ • user_id (PK)  │           │ • embedding_id  │
└─────────────────┘           │ • user_id (FK)  │
                              │ • text          │
                              │ • embedding     │ ← vector(1536)
                              │ • metadata      │
                              └─────────────────┘

┌─────────────────┐    1:M    ┌─────────────────┐
│conversation_    │◄─────────►│conversation_    │
│   messages      │           │  embeddings     │
│                 │           │                 │
│ • message_id    │           │ • embedding_id  │
└─────────────────┘           │ • message_id(FK)│
                              │ • embedding     │ ← vector(1536)
                              │ • metadata      │
                              └─────────────────┘

┌─────────────────┐    1:M    ┌─────────────────┐
│     users       │◄─────────►│ article_summaries│
│                 │           │                 │
│ • user_id (PK)  │           │ • id (PK)       │
└─────────────────┘           │ • created_by(FK)│
                              │ • url (UNIQUE)  │
                              │ • title         │
                              │ • summary       │
                              │ • content_length│
                              └─────────────────┘
```

## Application Management System

```
┌─────────────────┐    1:M    ┌─────────────────┐    1:M    ┌─────────────────┐
│   applicant     │◄─────────►│  application    │◄─────────►│   response      │
│                 │           │                 │           │                 │
│ • applicant_id  │           │ • application_id│           │ • response_id   │
│ • email         │           │ • applicant_id  │           │ • application_id│
│ • first_name    │           │ • status        │           │ • question_id   │
│ • last_name     │           │ • submitted_at  │           │ • response_value│
│ • password_hash │           └─────────────────┘           └─────────────────┘
└─────────────────┘                    │                             ▲
         │                             │ 1:M                         │ M:1
         │ 1:M                         ▼                             │
         ▼                    ┌─────────────────┐                    │
┌─────────────────┐           │application_     │                    │
│applicant_notes  │           │   analysis      │                    │
│                 │           │                 │                    │
│ • note_id       │           │ • analysis_id   │                    │
│ • applicant_id  │           │ • application_id│                    │
│ • created_by    │           │ • learning_score│                    │
│ • note_content  │           │ • grit_score    │                    │
└─────────────────┘           │ • critical_score│                    │
         ▲                    │ • overall_score │                    │
         │ M:1                │ • recommendation│                    │
         │                    │ • strengths     │                    │
┌─────────────────┐           │ • concerns      │                    │
│     users       │           │ • tokens_used   │                    │
│   (staff)       │           │ • analyzer_ver  │                    │
│                 │           └─────────────────┘                    │
│ • user_id (PK)  │                                                  │
└─────────────────┘           ┌─────────────────┐                    │
                              │applicant_stage  │                    │
                              │                 │                    │
                              │ • stage_id      │                    │
                              │ • applicant_id  │                    │
                              │ • current_stage │                    │
                              │ • previous_stage│                    │
                              │ • stage_date    │                    │
                              └─────────────────┘                    │
                                                                     │
┌─────────────────┐    1:M    ┌─────────────────┐    1:M    ┌─────────────────┐
│    section      │◄─────────►│   question      │◄──────────┤  choice_option  │
│                 │           │                 │           │                 │
│ • section_id    │           │ • question_id   │           │ • option_id     │
│ • name          │           │ • section_id    │           │ • question_id   │
│ • display_order │           │ • prompt        │           │ • label         │
└─────────────────┘           │ • response_type │           │ • value         │
                              │ • is_required   │           │ • display_order │
                              │ • parent_q_id   │           └─────────────────┘
                              └─────────────────┘
```

## Event Management System

```
┌─────────────────┐    1:M    ┌─────────────────┐    M:M    ┌─────────────────┐
│   event_type    │◄─────────►│     event       │◄─────────►│event_registration│
│                 │           │                 │           │                 │
│ • type_id (PK)  │           │ • event_id (PK) │           │ • user_id (FK)  │
│ • name          │           │ • type_id (FK)  │           │ • event_id (FK) │
│ • description   │           │ • title         │           │ • applicant_id  │
│ • default_cap   │           │ • description   │           │ • status        │
└─────────────────┘           │ • start_time    │           └─────────────────┘
                              │ • end_time      │                    ▲
                              │ • location      │                    │
                              │ • capacity      │                    │ M:1
                              │ • is_online     │                    │
                              │ • meeting_link  │           ┌─────────────────┐
                              │ • status        │           │     users       │
                              └─────────────────┘           │                 │
                                                            │ • user_id (PK)  │
                                                            └─────────────────┘
```

## Peer Feedback System

```
┌─────────────────┐           ┌─────────────────┐           ┌─────────────────┐
│     users       │    1:M    │  peer_feedback  │    M:1    │     users       │
│   (from_user)   │◄─────────►│                 │◄─────────►│   (to_user)     │
│                 │           │ • id (PK)       │           │                 │
│ • user_id (PK)  │           │ • from_user_id  │           │ • user_id (PK)  │
└─────────────────┘           │ • to_user_id    │           └─────────────────┘
                              │ • feedback_text │
                              │ • day_number    │
                              └─────────────────┘
```

## Email & Communication System

```
┌─────────────────┐           ┌─────────────────┐
│ email_template  │    1:M    │   email_sent    │
│                 │◄─────────►│                 │
│ • template_id   │           │ • email_id      │
│ • stage         │           │ • applicant_id  │
│ • subject_temp  │           │ • stage         │
│ • body_template │           │ • email_address │
│ • is_active     │           │ • subject       │
└─────────────────┘           │ • body          │
                              │ • status        │
                              │ • error_message │
                              └─────────────────┘

┌─────────────────┐
│approved_partner_│
│     emails      │
│                 │
│ • id (PK)       │
│ • email (UNIQUE)│
└─────────────────┘
```

## Task Analysis & Threading

```
┌─────────────────┐    1:M    ┌─────────────────┐
│     tasks       │◄─────────►│ task_analyses   │
│                 │           │                 │
│ • id (PK)       │           │ • id (PK)       │
└─────────────────┘           │ • task_id (FK)  │
         ▲                    │ • user_id (FK)  │
         │ M:1                │ • analysis_type │
         │                    │ • analysis_result│
┌─────────────────┐           │ • feedback      │
│  task_threads   │           └─────────────────┘
│                 │                    ▲
│ • id (PK)       │                    │ M:1
│ • user_id (FK)  │                    │
│ • task_id (FK)  │           ┌─────────────────┐
│ • thread_id (FK)│           │     users       │
│ UNIQUE(user,task)│           │                 │
└─────────────────┘           │ • user_id (PK)  │
         │                    └─────────────────┘
         │ M:1
         ▼
┌─────────────────┐
│    threads      │
│                 │
│ • thread_id (PK)│
│ • user_id (FK)  │
│ • title         │
└─────────────────┘
```

## Key Relationships Summary

- **Users** are central to the system with 1:1 profiles and 1:M relationships to most entities
- **Curriculum structure**: curriculum_days → time_blocks → tasks
- **Learning tracking**: users ↔ tasks through submissions, progress, and analysis tables
- **AI Integration**: Vector embeddings for users and conversations (pgvector), article summaries
- **Application flow**: applicant → application → responses → analysis (with detailed scoring)
- **Event system**: event_types → events ↔ users/applicants through registrations
- **Communication**: users → threads → messages with AI embeddings
- **Task system**: Complex threading with task_threads linking users, tasks, and conversation threads
- **Email automation**: Template-based email system with stage tracking for applicants
- **Analysis system**: Comprehensive scoring (learning, grit, critical thinking) with AI token tracking