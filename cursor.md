# Cursor IDE Guide

## 🚀 Quickstart Guide

### First Time Setup (5 minutes)

Follow the main setup guide in [README.md](./README.md) to clone repos, install dependencies, and start the servers. Once that's done, return here to start building with Cursor.

### Your First Cursor Session

**Step 1: Give Cursor Full App Context**

Start a new conversation and provide Cursor with the full application context:

```
I'm working on the Pursuit AI Native project. Here's the full context:

@documentation/app-context.md
@database-schema.sql

I want to understand the codebase before making changes.
```

**Why this works**: This gives Cursor immediate understanding of all 13 features, database structure, API patterns, and file organization.

**Step 2: Explore Before You Build**

Ask questions to understand the area you'll be working in:

```
How does the attendance system work? Show me the key files.
```

```
Where is user authentication handled in the frontend and backend?
```

```
What tables are related to the admissions pipeline?
```

**Step 3: Start Your First Feature**

When ready to build, use this workflow:

1. **Switch to Plan Mode**: Click the mode dropdown → Select "Plan"

2. **Describe your feature with context**:
   ```
   I need to add a new field "phone_number" to the user profile.
   
   @documentation/app-context.md
   @database-schema.sql
   
   Create a plan for:
   1. Adding the database column
   2. Updating the backend API
   3. Updating the frontend form
   ```

3. **Review & approve the plan**: Cursor will show you exactly what files will be changed

4. **Switch to Agent Mode**: Execute the plan step by step

5. **Test as you go**: After each step, verify it works before continuing

### Quick Command Reference

**Give Context to Cursor**:
- `@documentation/app-context.md` - Full app overview
- `@database-schema.sql` - Complete database structure
- `@documentation/README.md` - Setup and best practices
- `@filename.js` - Reference any specific file

**Common First Prompts**:
```
@documentation/app-context.md
Explain how [feature name] works in this app.
```

```
@documentation/app-context.md
@database-schema.sql
I need to add [feature]. Create a plan in Plan mode.
```

```
@filename.js
Explain what this file does and how it connects to other parts of the app.
```

### Example: Building Your First Feature

Let's say you want to add a "Notes" field to builder profiles:

**1. Start with context:**
```
@documentation/app-context.md
@database-schema.sql

I want to add a notes field to builder profiles where staff can add internal notes about each builder. What tables and files will I need to modify?
```

**2. Switch to Plan Mode and request a plan:**
```
@documentation/app-context.md
@database-schema.sql

Create a plan to add a staff_notes TEXT field to user profiles:
- Backend: database, queries, controllers, API endpoints
- Frontend: UI component in the profile page
- Only staff and admin roles should be able to add/edit notes
```

**3. Review plan, approve, then switch to Agent Mode to implement**

**4. Test each piece:**
```
Test the API endpoint for adding notes by calling POST /api/profile/notes
```

**5. When done, start fresh for next feature:**
```
[New conversation]

@documentation/app-context.md
Working on attendance reports. Show me the attendance system architecture.
```

---

## Cursor Best Practices

### Using Plan Mode for Features
**Before building any new feature**, use Plan mode to create a detailed implementation plan:

1. **Switch to Plan Mode**: Click the mode selector and choose "Plan"
2. **Describe the feature**: Provide context about what you want to build
3. **Review the plan**: Cursor will create a detailed plan with file changes and steps
4. **Approve and execute**: Once you approve the plan, switch back to Agent mode to implement

**Why Plan Mode?**
- Helps organize complex features before coding
- Identifies file dependencies and impacts
- Reduces mistakes and rework
- Creates a clear roadmap for implementation

### Choosing the Right Model

**Sonnet 4.5 (No Thinking/Brain Icon)** - Default for most tasks:
- Use for: Regular coding, refactoring, debugging, file edits
- Fastest response time
- Best for straightforward tasks

**Sonnet 4.5 with Thinking (Brain Icon)** - For complex problem solving:
- Use for: Complex algorithms, architectural decisions, multi-step reasoning
- Slower but more thorough
- Best for tasks requiring deep analysis

### Managing Context Windows

**Start fresh conversations regularly** to maintain performance:

- **New feature = New conversation**: Start a new chat when beginning a different feature
- **Context nearing full**: If you notice slower responses or repetitive answers, start fresh
- **After major changes**: Begin new conversation after completing a significant feature
- **Provide context**: In new chats, reference key files or provide brief context about what you're working on

**Tip**: Use `@` to reference files and documentation to quickly give context to new conversations.

---

## Setting Up Cursor Rules

### Configuring User Rules
To ensure consistent development practices, set up these rules in Cursor:

1. **Access Settings**: Click the Settings gear icon in the top right corner
2. **Navigate to Rules**: Click on "Rules and Memories"
3. **Scroll to User Rules**: Find the User Rules section
4. **Apply these rules**:

```
1. Use Tailwind CSS utility classes for styling. Use shadcn/ui components from src/components/ui/ for common UI elements like buttons, inputs, dialogs, etc.

2. When you are directed to fix a bug or create a new feature, first explain the plan you plan to execute on before adding any code or creating any files, and ask for my approval of the plan before executing.

3. Make sure to only touch one file at a time when making updates and I will accept/reject changes before moving on to ensure we have mapped things correctly.

4. Always explain what you are doing / have done.

5. Follow the current project's file structure and style conventions.

6. Understand the project entry points: Backend (test-pilot-server) starts at app.js, Frontend (pilot-client) starts at main.jsx.
```

These rules ensure consistent code quality, proper workflow management, and clear communication during development.

## Working in Cursor IDE

### Getting the Most from Cursor's AI
- **Always have the parent folder open**: This gives the AI context of both frontend and backend
- **Use specific prompts**: Instead of "fix this," say "fix this component using Tailwind CSS utilities"
- **Reference files with @**: Use `@filename` to give Cursor context about specific files
- **Reference documentation**: Use `@documentation/` to include project docs in your prompt
- **Ask for explanations**: Use prompts like "explain how this database query works"
- **Break down complex tasks**: Ask Cursor to tackle one piece at a time for better results

### Common Cursor Commands
- **Command + Shift + P**: Open command palette
- **Command + P**: Quick file search
- **Command + /**: Comment/uncomment code
- **Command + D**: Select next occurrence of selected text
- **Command + Shift + L**: Select all occurrences of selected text

### Working with Multiple Projects
- **File Explorer**: Use the left sidebar to navigate between `test-pilot-server` and `pilot-client`
- **Terminal**: Use Cursor's built-in terminal (View → Terminal) or `Control + `` (backtick)
- **Split View**: Right-click a file tab → "Split Right" to view backend and frontend files side-by-side

## Cursor IDE Best Practices

### Code Generation Guidelines
- Review generated code for consistency with project standards
- Ensure generated code follows established patterns

### File Organization
- Follow existing project structure
- Use consistent naming conventions across files
- Group related functionality together

### AI Prompting Best Practices
- **Be specific with context**: "In the userController.js file, add error handling for the login function"
- **Reference the tech stack**: "Create a React component using Tailwind CSS and shadcn/ui components"
- **Include file paths**: "Update the database query in queries/users.js to include pagination"
- **Ask for explanations**: "Explain how this postgres JOIN query works and what it is doing"

### Code Exploration Tips
- **Use semantic search**: Ask "How does user authentication work?" instead of searching for specific function names
- **Trace dependencies**: Ask Cursor to explain how components/modules connect
- **Understand data flow**: "Show me how data flows from the API endpoint to the React component"

### Database Development
- **Reference schema**: Ask Cursor to check existing database structure before suggesting changes
- **Query optimization**: Request explanations for complex PostgreSQL/pgvector queries
- **Migration awareness**: Always ask about database migration impacts before schema changes

## Workflow Tips

### Feature Development Workflow

1. **Plan First**: Switch to Plan mode, describe the feature, review and approve the plan
2. **Use Sonnet 4.5**: Start in Agent mode with regular Sonnet 4.5 (no thinking icon)
3. **Reference context**: Use `@app-context.md` and `@database-schema.sql` for full app understanding
4. **Implement incrementally**: Work through the plan one step at a time
5. **Test as you go**: Test each change before moving to the next step
6. **Start fresh if needed**: If context gets cluttered, start a new conversation with context references

### When to Use Plan Mode vs Agent Mode

**Plan Mode** (Planning & Design):
- Planning new features
- Understanding complex requirements
- Exploring architectural options
- Breaking down large tasks

**Agent Mode** (Implementation):
- Writing code
- Making file changes
- Debugging issues
- Running commands
- Testing functionality

### Conversation Management

**Signs you need a new conversation**:
- Responses becoming slower
- AI repeating previous suggestions
- Context window warning appears
- Switching to a different feature area
- Completed a major milestone

**When starting a new conversation**:
- Reference key files: `@app-context.md`, `@database-schema.sql`
- Briefly state what you're working on
- Reference the specific feature area (e.g., "Working on the attendance system")

---

## Keyboard Shortcuts & Commands