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
- Node.js (version 18.x or higher)
- Nodemon (in terminal run: `sudo npm i -g nodemon`)
- Git
- Terminal access

### Initial Setup

1. **Clone both repositories separately**:
   ```bash
   git clone https://github.com/cgodoy720/test-pilot-server.git
   git clone https://github.com/cgodoy720/pilot-client.git
   ```

2. **Create feature branches** (never work directly on main):
   ```bash
   # Backend
   cd test-pilot-server
   git checkout -b feature/your-feature-name
   
   # Frontend  
   cd pilot-client
   git checkout -b feature/your-feature-name
   ```

3. **Environment Configuration**:
   
   **Backend Setup** (`test-pilot-server`):
   - Copy `.env.example` to `.env` in the backend directory
   - The example file contains connection details for our mock development database
   - **Never commit `.env` files to version control**
   
   **Frontend Setup** (`pilot-client`):
   - Copy `.env.example` to `.env` in the frontend directory (if needed)

4. **Install dependencies**:
   ```bash
   # Backend
   cd test-pilot-server
   npm install

   # Frontend
   cd pilot-client
   npm install
   ```

5. **Database Connection**:
   - We use a shared mock PostgreSQL database for development
   - Connection details are provided in `.env.example` with actual values
   - **No local database setup required** - just use the provided mock database
   - To connect manually via terminal (after copying `.env.example` to `.env`):
   ```bash
   source .env && PGPASSWORD="$PG_PASSWORD" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DATABASE"
   ```

6. **Start the applications**:
   ```bash
   # Backend (runs on port 4001)
   cd test-pilot-server
   npm start
   
   # Frontend (runs on port 5173)
   cd pilot-client
   npm run dev
   ```

## Backend Architecture (`test-pilot-server`)

### Directory Structure
- **`db/`**: Database configuration, queries, and vector operations
  - `dbConfig.js`: Main database connection setup
  - `vectorQueries.js`: AI embedding and search functions
- **`queries/`**: Database query functions organized by feature
- **`controllers/`**: API route handlers
- **`services/`**: Business logic and external API integrations
- **`middleware/`**: Authentication and validation middleware
- **`routes/`**: API route definitions
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

## Cursor IDE Best Practices

### CSS Rules
- **Always use BEM naming conventions for CSS classes**
- When creating new styles, follow the BEM methodology
- Use semantic class names that describe the purpose, not appearance
- Avoid inline styles unless absolutely necessary

### Code Generation Guidelines
- When using Cursor's AI assistance, always specify BEM naming for CSS
- Review generated code for consistency with project standards
- Ensure generated code follows established patterns

### File Organization
- Follow existing project structure
- Use consistent naming conventions across files
- Group related functionality together

## Development Workflow

### Branch Strategy
- **Never work directly on main branch**
- Use feature branches for new development
- Follow naming convention: `feature/description` or `bugfix/description`
- Keep branches focused on single features or fixes

### Getting Started on a New Feature
1. **Pull latest changes**:
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes and commit regularly**:
   ```bash
   git add .
   git commit -m "descriptive commit message"
   ```

4. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create Pull Request** on GitHub for code review

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

#### Database Connection Problems
- **Issue**: Cannot connect to database
- **Solution**: Verify `.env` file has correct database credentials from `.env.example`

#### Frontend Not Loading
- **Issue**: React app shows errors or blank screen
- **Solution**: 
  1. Check if backend is running on port 4001
  2. Verify `VITE_API_URL` in frontend `.env`
  3. Check browser console for errors

#### API Endpoints Not Working
- **Issue**: 404 or 500 errors from API
- **Solution**:
  1. Verify backend server is running
  2. Check API endpoint URLs use `/api/` prefix
  3. Review backend console for error messages

#### Port Conflicts
- **Issue**: Cannot start servers due to port conflicts
- **Solution**: 
  - Backend: Change `PORT` in `.env` file
  - Frontend: Vite will automatically find available port

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