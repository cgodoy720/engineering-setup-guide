# Engineering Best Practices & Setup Guide

## Repository Structure

Our codebase consists of two main repositories:
- **Backend**: `test-pilot-server`
- **Frontend**: `pilot-client`

## Tech Stack

### Backend (`test-pilot-server`)
- **Runtime**: Node.js with Express.js
- **Database**: PostgreSQL with pgvector extension
- **AI/ML**: OpenAI API integration with vector embeddings
- **Authentication**: JWT with bcrypt
- **Additional Services**: Google Cloud BigQuery, AWS S3, Nodemailer

### Frontend (`pilot-client`) 
- **Framework**: React with Vite build tool
- **Routing**: React Router DOM
- **Styling**: CSS with BEM naming conventions
- **UI Components**: React Icons, React Calendar
- **Language**: JavaScript (ES6+)

## Getting Started

### Prerequisites
- iTerm2 ([Download here](https://iterm2.com/))
- Node.js (Download here [nodejs.org](https://nodejs.org/en/download))
- Nodemon (in terminal run: `sudo npm i -g nodemon`, then enter your computer password and hit enter/return)
- Git (pre-installed on Mac, verify with `git --version`)
- Terminal access (`Command + Space`, type in Terminal, hit enter/return)

### Initial Setup

1. **Fork both repositories on GitHub**:
   
   **Fork the backend repository:**
   - Go to [https://github.com/cgodoy720/test-pilot-server](https://github.com/cgodoy720/test-pilot-server)
   - Click the **"Fork"** button in the top-right corner
   - Click **"Create fork"** (keep default settings)
   
   **Fork the frontend repository:**
   - Go to [https://github.com/cgodoy720/pilot-client](https://github.com/cgodoy720/pilot-client)
   - Click the **"Fork"** button in the top-right corner
   - Click **"Create fork"** (keep default settings)
   
   **Note**: This creates your own copies of the repositories that you can modify and submit pull requests from.

2. **In the `terminal` create a parent folder and clone your forked repositories**:
   ```bash
   # Create a parent folder for the project
   mkdir pilot-agent-project
   cd pilot-agent-project
   
   # Clone YOUR forked repositories (replace YOUR_USERNAME with your GitHub username)
   git clone https://github.com/YOUR_USERNAME/test-pilot-server.git
   git clone https://github.com/YOUR_USERNAME/pilot-client.git
   ```
   
   Your folder structure should now look like:
   ```
   pilot-agent-project/
   ├── test-pilot-server/
   └── pilot-client/
   ```

3. **Open the parent folder in Cursor**:
   - Open Cursor IDE
   - Go to File → Open Folder (or `Command + O` on Mac)
   - Select the `pilot-agent-project` folder you just created
   - **Important**: This gives Cursor's AI context of both repositories, making it much more helpful!

4. **Set up terminals and create feature branches** (never work directly on main):
   
   **Open and set up two terminals in Cursor:**
   - Open a terminal: View → Terminal (or `Control + `` backtick)
   - Click the `+` button next to the terminal tab to open a second terminal
   - Right-click the first terminal tab → Rename → type `backend`
   - Right-click the second terminal tab → Rename → type `frontend`
   
   **In the `backend` terminal:**
   ```bash
   cd test-pilot-server
   git checkout -b replace-with-your-feature-name
   ```
   
   **In the `frontend` terminal:**
   ```bash
   cd pilot-client
   git checkout -b replace-with-your-feature-name
   ```
   
   **Note**: Keep these terminals open - you'll use the `backend` terminal for all backend commands and `frontend` terminal for all frontend commands throughout development!

5. **Environment Configuration**:
   
   **In the `backend` terminal:**
   ```bash
   # Copy the example file to create your .env file
   cp .env.example .env
   ```
   - The `.env.example` file contains actual mock database connection details
   - **Never commit `.env` files to version control**

6. **Configure database connection for mock database**:
   
   **In the `backend` terminal, edit the database config file:**
   - Open `db/dbConfig.js` in Cursor
   - **Make sure lines 48-50 are NOT commented out** (SSL configuration):
   ```javascript
   // ssl: {
   //     rejectUnauthorized: true
   // }
   ```
   - These lines should already have `//` at the beginning
   - **Important**: The mock database uses SSL, so these lines must be added back in. Erase the `//` from each of those lines to add them in.
   
   **In the `frontend` terminal:**
   ```bash
   # Copy the example file (if it exists)
   cp .env.example .env
   ```

7. **Install dependencies**:
   
   **In the `backend` terminal:**
   ```bash
   npm install
   ```
   
   **In the `frontend` terminal:**
   ```bash
   npm install
   ```

8. **Database Connection**:
   - We use a shared mock PostgreSQL database for development
   - Connection details are provided in `.env.example` with actual values
   - **No local database setup required** - just use the provided mock database
   - To connect manually via terminal (in the `backend` terminal):
   ```bash
   source .env && PGPASSWORD="$PG_PASSWORD" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DATABASE"
   ```

9. **Start the applications**:
   
   **In the `backend` terminal:**
   ```bash
   npm start
   ```
   You should see: `Server listening on port 4001`
   
   **In the `frontend` terminal:**
   ```bash
   npm run dev
   ```
   You should see: `Local: http://localhost:5173/`
   
   **Note**: Both terminals need to stay running while you develop. Keep them open and use them for all future backend/frontend commands!

> **For Cursor IDE users**: See [cursor.md](./cursor.md) for Cursor-specific best practices, AI tips, and keyboard shortcuts.

## Backend Architecture (`test-pilot-server`)

### Directory Structure
- **`db/`**: Database configuration
  - `dbConfig.js`: Main database connection setup
- **`queries/`**: Database query functions organized by feature
- **`controllers/`**: API route handlers
- **`services/`**: Business logic and external API integrations

- **`app.js`**: Main application file
- **`server.js`**: Server startup file

### Database Architecture
- **PostgreSQL with pgvector**: Enables AI embedding storage and similarity search
- **Connection**: Configured in `db/dbConfig.js`
- **Mock Database**: Shared development environment (no local setup needed)

### API Conventions
- All API endpoints use the `/api/` prefix
- RESTful naming conventions
- Proper HTTP status codes
- Consistent error handling
- JWT authentication for protected routes

### Database Queries
- All database operations should be placed in the `queries/` folder
- Use parameterized queries to prevent SQL injection
- Follow consistent naming conventions for query functions
- Use pgvector for AI-related queries

### Controllers
- Keep controllers focused on request/response handling
- Business logic should be extracted to `services/` modules
- Use proper error handling and validation

## Frontend Architecture (`pilot-client`)

### Directory Structure
- **`src/components/`**: Reusable UI components
- **`src/pages/`**: Page-level components
- **`src/context/`**: React context providers
- **`src/services/`**: API calls and external integrations
- **`src/utils/`**: Helper functions and utilities

### CSS Conventions
- **BEM (Block Element Modifier) naming convention is mandatory**
- Structure: `block__element--modifier`
- Examples:
  - `.header` (block)
  - `.header__nav` (element)
  - `.header__nav--active` (modifier)

### Component Structure
- Organize components logically by feature
- Use consistent file naming conventions
- Include proper documentation
- Keep components focused and reusable

### Build Tool
- **Vite**: Fast development server and build tool
- **Hot Module Replacement**: Instant updates during development
- **ES6+ Support**: Modern JavaScript features

## Development Workflow

### Branch Strategy
- **Never work directly on main branch**
- Use feature branches for new development
- Follow naming convention: `feature/description` or `bugfix/description`
- Keep branches focused on single features or fixes

### Getting Started on a New Feature
1. **Pull latest changes in both repositories**:
   
   **In the `backend` terminal:**
   ```bash
   git checkout main
   git pull origin main
   ```
   
   **In the `frontend` terminal:**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create feature branches**:
   
   **In the `backend` terminal:**
   ```bash
   git checkout -b feature/your-feature-name
   ```
   
   **In the `frontend` terminal:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes and commit regularly**:
   
   **When working on backend files, in the `backend` terminal:**
   ```bash
   git add .
   git commit -m "descriptive commit message"
   ```
   
   **When working on frontend files, in the `frontend` terminal:**
   ```bash
   git add .
   git commit -m "descriptive commit message"
   ```

4. **Push your branches**:
   
   **In the `backend` terminal:**
   ```bash
   git push origin feature/your-feature-name
   ```
   
   **In the `frontend` terminal:**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create Pull Requests** on GitHub:
   - Go to your forked repository on GitHub (https://github.com/YOUR_USERNAME/test-pilot-server or pilot-client)
   - Click **"Compare & pull request"** button that appears after pushing
   - Make sure the pull request is going from your fork to the original repository (`cgodoy720/test-pilot-server` or `cgodoy720/pilot-client`)
   - Add a clear title and description of your changes
   - Click **"Create pull request"**
   - Repeat for the other repository if you made changes to both

### Code Review Process
- All code must be reviewed before merging
- Check for adherence to coding standards
- Verify BEM naming conventions in CSS changes
- Test functionality thoroughly

## Environment Management

### Development Environment
- **Backend**: Uses shared mock PostgreSQL database (no local setup required)
- **Frontend**: Connects to local backend API
- Use the provided `.env.example` as a template
- Never commit sensitive information
- Document any new environment variables in the README

### Important Environment Variables

#### Backend Required Variables:
- `PG_*`: Database connection (actual mock database values provided in `.env.example`)
- `SECRET`: JWT secret for authentication (placeholder in `.env.example`)
- `OPENAI_API_KEY`: Required for AI features (ask team lead for actual key)
- `FRONTEND_URL`: For CORS configuration (default value in `.env.example`)

#### Backend Optional Variables:
- `GITHUB_TOKEN`: For GitHub integration features
- `EMAIL_*`: For email notifications (development can work without)

#### Frontend Variables:
- `VITE_API_URL`: Backend API endpoint (usually `http://localhost:4001`)

### Production Considerations
- Environment variables should be set in deployment environment
- Use proper logging levels
- Implement proper error handling

## Testing Requirements

### Current Status
- **Backend**: No automated tests currently implemented
- **Frontend**: No automated tests currently implemented
- **Manual Testing**: Required for all changes

### Future Testing Goals
- Write unit tests for new functionality
- Ensure all tests pass before submitting PR
- Include integration tests for API endpoints

### Manual Testing Checklist
- Test API endpoints with Postman or similar tool
- Verify frontend functionality in browser
- Check database operations don't break existing data
- Test authentication flows

## Code Quality Standards

### General Guidelines
- Write self-documenting code with clear variable names
- Use consistent indentation and formatting
- Remove commented-out code and console.log statements
- Follow established patterns in the codebase

### JavaScript/Node.js
- Use ES6+ features appropriately
- Handle errors properly with try/catch blocks
- Use async/await for asynchronous operations
- Follow consistent function naming conventions

### CSS/SCSS
- Use BEM methodology for all class names
- Organize styles logically by component
- Use variables for repeated values
- Avoid overly specific selectors

### Database Operations
- Always use parameterized queries
- Handle database errors gracefully
- Use transactions for multi-step operations
- Follow naming conventions in `queries/` folder

## Security Best Practices

### API Security
- Validate all input parameters
- Use parameterized queries (prevent SQL injection)
- Implement proper authentication/authorization with JWT
- Never expose sensitive data in responses

### Environment Security
- Keep `.env` files out of version control
- Use strong, unique passwords for development
- Never commit API keys or secrets
- Use environment variables for all sensitive configuration

### Database Security
- Use the provided mock database for development only
- Never modify production data from development environment
- Use read-only connections when possible
- Be mindful of sensitive user data

## Troubleshooting

### Common Issues

#### Setup Issues

**Missing `.env` file**
- **Issue**: `Error: Cannot find module 'dotenv'` or database connection errors
- **Solution**: Make sure you copied `.env.example` to `.env` in the backend folder

**Permission denied when installing nodemon**
- **Issue**: `npm install -g nodemon` fails
- **Solution**: Use `sudo npm install -g nodemon` and enter your computer password

**Git branch errors**
- **Issue**: `fatal: A branch named 'feature/...' already exists`
- **Solution**: Use a different branch name or delete the old branch with `git branch -d feature/old-name`

**Clone URL errors**
- **Issue**: `git clone` fails with permission denied or repository not found
- **Solution**: Make sure you forked the repositories first and are cloning from YOUR GitHub username, not `cgodoy720`

**Database configuration errors**
- **Issue**: SSL connection errors or "rejectUnauthorized" errors
- **Solution**: Make sure the SSL configuration in `db/dbConfig.js` lines 48-50 are commented out (start with `//`)

#### Database Connection Problems
- **Issue**: Cannot connect to database
- **Solution**: 
  1. Verify `.env` file has correct database credentials from `.env.example`
  2. Check that you're in the `test-pilot-server` folder when running the app
  3. Make sure your internet connection is working

#### Frontend Not Loading
- **Issue**: React app shows errors or blank screen
- **Solution**: 
  1. Check if backend is running on port 4001 (look for "Server listening on port 4001")
  2. Verify `VITE_API_URL` in frontend `.env` file
  3. Check browser console for errors (F12 → Console tab)
  4. Try refreshing the page

#### API Endpoints Not Working
- **Issue**: 404 or 500 errors from API
- **Solution**:
  1. Verify backend server is running (check terminal for "Server listening on port 4001")
  2. Check API endpoint URLs use `/api/` prefix
  3. Review backend console for error messages
  4. Use Postman to test endpoints directly

#### Port Conflicts
- **Issue**: Cannot start servers due to port conflicts
- **Solution**: 
  - Backend: Change `PORT` in `.env` file to a different number (like 4002)
  - Frontend: Vite will automatically find an available port

#### Cannot Find Files/Folders
- **Issue**: Terminal says "No such file or directory"
- **Solution**: 
  1. Use `pwd` to see what folder you're in
  2. Use `ls` to see what's in the current folder
  3. Navigate to the correct folder with `cd folder-name`

### Getting Help
- Check existing documentation first
- Review error messages in browser console and server logs
- Ask in team chat with specific error details
- Create an issue in the appropriate repository for bugs

## Documentation Standards

### Code Documentation
- Document complex functions and algorithms
- Include JSDoc comments for public APIs
- Keep README files updated
- Document database schema changes
- Update this README when adding new features

### API Documentation
- Document all API endpoints in backend README
- Include request/response examples
- Specify required parameters and data types
- Note authentication requirements

## Resources

### Documentation
- [BEM Methodology](http://getbem.com/) - CSS naming conventions
- [React Documentation](https://react.dev/) - Frontend framework
- [Express.js Guide](https://expressjs.com/) - Backend framework
- [PostgreSQL Documentation](https://www.postgresql.org/docs/) - Database
- [Vite Guide](https://vitejs.dev/guide/) - Frontend build tool

### Development Tools
- **ESLint**: Code quality (configured in both projects)
- **Nodemon**: Backend auto-restart during development
- **React DevTools**: Browser extension for React debugging
- **Postman**: API testing and documentation

## Contact

For questions about these best practices or setup issues, please:
- Check existing documentation first
- Ask in the team chat
- Create an issue in the appropriate repository

---

*This document should be updated as practices evolve and new standards are adopted.*