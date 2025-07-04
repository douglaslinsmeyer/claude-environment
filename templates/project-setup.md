# Project Setup Guide

This guide helps you quickly set up a new project with best practices and standard configurations.

## 🚀 Quick Start

### 1. Initialize Project

```bash
# Create project directory
mkdir my-project && cd my-project

# Initialize git
git init

# Create initial structure
mkdir -p src tests docs config .github/workflows

# Create essential files
touch README.md LICENSE .gitignore .env.example
```

### 2. Choose Your Stack

<details>
<summary><b>Node.js/TypeScript Project</b></summary>

```bash
# Initialize package.json
npm init -y

# Install TypeScript and essential tools
npm install --save-dev typescript @types/node tsx
npm install --save-dev eslint prettier jest @types/jest
npm install --save-dev @typescript-eslint/parser @typescript-eslint/eslint-plugin

# Create TypeScript config
npx tsc --init

# Create initial source file
mkdir -p src
echo 'console.log("Hello, World!");' > src/index.ts
```

**package.json scripts:**
```json
{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "lint": "eslint src --ext .ts",
    "format": "prettier --write \"src/**/*.ts\""
  }
}
```

</details>

<details>
<summary><b>Python Project</b></summary>

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Create requirements files
touch requirements.txt requirements-dev.txt

# Install development tools
pip install black flake8 pytest mypy

# Create project structure
mkdir -p src tests
touch src/__init__.py src/main.py

# Create setup.py
cat > setup.py << 'EOF'
from setuptools import setup, find_packages

setup(
    name="my-project",
    version="0.1.0",
    packages=find_packages(),
    python_requires=">=3.9",
)
EOF
```

</details>

<details>
<summary><b>React/Next.js Project</b></summary>

```bash
# Using Next.js (recommended)
npx create-next-app@latest my-app --typescript --tailwind --app

# Or React with Vite
npm create vite@latest my-app -- --template react-ts
cd my-app
npm install

# Add common dependencies
npm install axios react-query zustand
npm install --save-dev @testing-library/react @testing-library/jest-dom
```

</details>

<details>
<summary><b>Go Project</b></summary>

```bash
# Initialize module
go mod init github.com/username/project

# Create structure
mkdir -p cmd/app internal pkg

# Create main file
cat > cmd/app/main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
EOF

# Install common tools
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install golang.org/x/tools/cmd/goimports@latest
```

</details>

## 📁 Standard Project Structure

### Web Application
```
my-app/
├── src/
│   ├── components/      # UI components
│   ├── pages/          # Page components
│   ├── services/       # API services
│   ├── hooks/          # Custom hooks
│   ├── utils/          # Utilities
│   ├── types/          # TypeScript types
│   └── styles/         # CSS/SCSS files
├── public/             # Static assets
├── tests/              # Test files
├── docs/               # Documentation
└── config/             # Configuration files
```

### API/Backend Service
```
my-service/
├── src/
│   ├── controllers/    # Request handlers
│   ├── models/         # Data models
│   ├── services/       # Business logic
│   ├── middleware/     # Express middleware
│   ├── routes/         # Route definitions
│   ├── utils/          # Utilities
│   └── config/         # Configuration
├── tests/
│   ├── unit/          # Unit tests
│   └── integration/   # Integration tests
├── scripts/           # Utility scripts
└── docs/              # Documentation
```

## 🔧 Configuration Files

### .gitignore (Universal)
```gitignore
# Dependencies
node_modules/
venv/
vendor/

# Build outputs
dist/
build/
*.egg-info/
__pycache__/

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*

# Testing
coverage/
.coverage
htmlcov/
.pytest_cache/

# Temporary files
tmp/
temp/
```

### ESLint Configuration (.eslintrc.json)
```json
{
  "parser": "@typescript-eslint/parser",
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended",
    "prettier"
  ],
  "plugins": ["@typescript-eslint", "react"],
  "rules": {
    "no-console": ["warn", { "allow": ["warn", "error"] }],
    "@typescript-eslint/explicit-module-boundary-types": "off",
    "@typescript-eslint/no-explicit-any": "warn",
    "react/react-in-jsx-scope": "off"
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  }
}
```

### Prettier Configuration (.prettierrc)
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "avoid",
  "endOfLine": "lf"
}
```

### Jest Configuration (jest.config.js)
```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  transform: {
    '^.+\\.ts$': 'ts-jest',
  },
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
```

### Docker Configuration

**Dockerfile (Node.js)**
```dockerfile
# Build stage
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Runtime stage
FROM node:22-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

**docker-compose.yml**
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      - db
      - redis

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=mydb
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

## 🤖 CI/CD Setup

### GitHub Actions (.github/workflows/ci.yml)
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]

    steps:
      - uses: actions/checkout@v3
      
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linter
        run: npm run lint
      
      - name: Run tests
        run: npm test -- --coverage
      
      - name: Build
        run: npm run build
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
```

## 🔐 Environment Setup

### .env.example
```env
# Application
NODE_ENV=development
PORT=3000
APP_NAME=my-app
LOG_LEVEL=debug

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
DB_SSL=false

# Redis
REDIS_URL=redis://localhost:6379

# Authentication
JWT_SECRET=your-secret-key-here
JWT_EXPIRY=7d
BCRYPT_ROUNDS=10

# External Services
API_KEY=your-api-key
STRIPE_SECRET_KEY=sk_test_...
SENDGRID_API_KEY=SG...

# Feature Flags
FEATURE_NEW_UI=false
FEATURE_BETA_API=false
```

## 📝 Documentation Templates

### API Documentation (docs/api.md)
```markdown
# API Documentation

## Base URL
`https://api.example.com/v1`

## Authentication
All API requests require authentication using Bearer tokens:
```
Authorization: Bearer <token>
```

## Endpoints

### GET /users
Get list of users

**Query Parameters:**
- `page` (number): Page number (default: 1)
- `limit` (number): Items per page (default: 20)

**Response:**
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```
```

### Architecture Decision Record (docs/adr/001-use-typescript.md)
```markdown
# ADR-001: Use TypeScript for Backend Development

## Status
Accepted

## Context
We need to choose a language for our backend services that provides type safety and good developer experience.

## Decision
We will use TypeScript for all backend Node.js services.

## Consequences
- ✅ Type safety reduces runtime errors
- ✅ Better IDE support and autocompletion
- ✅ Easier refactoring
- ❌ Additional build step required
- ❌ Learning curve for developers new to TypeScript
```

## 🚦 Pre-commit Hooks

### Install Husky
```bash
npm install --save-dev husky lint-staged
npx husky install
npx husky add .husky/pre-commit "npx lint-staged"
```

### lint-staged Configuration (package.json)
```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md,yml,yaml}": [
      "prettier --write"
    ]
  }
}
```

## 🏃 Getting Started Scripts

### setup.sh
```bash
#!/bin/bash

echo "🚀 Setting up project..."

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Copy environment file
echo "🔐 Setting up environment..."
cp .env.example .env
echo "Please update .env with your configuration"

# Setup git hooks
echo "🪝 Setting up git hooks..."
npx husky install

# Run initial build
echo "🔨 Building project..."
npm run build

# Run tests
echo "🧪 Running tests..."
npm test

echo "✅ Setup complete! Run 'npm run dev' to start developing."
```

Make it executable:
```bash
chmod +x setup.sh
```

## 📋 Project Checklist

- [ ] Initialize git repository
- [ ] Create README.md with project description
- [ ] Set up .gitignore file
- [ ] Choose and configure linter
- [ ] Set up code formatter
- [ ] Configure testing framework
- [ ] Create folder structure
- [ ] Set up environment variables
- [ ] Configure CI/CD pipeline
- [ ] Add pre-commit hooks
- [ ] Create initial documentation
- [ ] Set up error tracking (Sentry)
- [ ] Configure logging
- [ ] Add health check endpoint
- [ ] Set up monitoring

## 🎉 Next Steps

1. **Customize** the configuration files for your specific needs
2. **Document** your project-specific setup in README.md
3. **Create** your first feature branch
4. **Start** building your application!

---

*Happy coding! 🚀*