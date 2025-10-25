# Publishing to GitHub

This guide walks you through publishing your Field Service Management System to GitHub.

## Why GitHub?

- ✅ Free hosting for AGPL open source projects
- ✅ Version control and change tracking
- ✅ Issue tracking and discussions
- ✅ Community contributions
- ✅ Automated workflows (GitHub Actions)
- ✅ Professional project visibility

## Prerequisites

1. **GitHub Account** - Create free account at [github.com](https://github.com)
2. **Git Installed** - `winget install Git.Git`
3. **GitHub CLI (optional)** - `winget install GitHub.cli`

---

## Option 1: Using GitHub CLI (Easiest)

### Step 1: Install and Login
```powershell
# Install GitHub CLI
winget install GitHub.cli

# Login to GitHub
gh auth login
```

### Step 2: Create Repository
```powershell
# Navigate to your distribution folder
cd "C:\Users\littl\OneDrive - dcpsp.com\Documents\myapps\field-service-distribution"

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial release - v1.0.0"

# Create GitHub repository and push
gh repo create field-service-management --public --source=. --push
```

Done! Your project is now on GitHub.

---

## Option 2: Using GitHub Web Interface

### Step 1: Create Repository on GitHub

1. Go to [github.com/new](https://github.com/new)
2. Repository name: `field-service-management`
3. Description: `AGPL-licensed field service management system for Azure`
4. Choose: **Public**
5. **Do NOT** initialize with README (you already have one)
6. **Do NOT** add .gitignore or license (you already have them)
7. Click "Create repository"

### Step 2: Push Your Code

```powershell
# Navigate to distribution folder
cd "C:\Users\littl\OneDrive - dcpsp.com\Documents\myapps\field-service-distribution"

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial release - v1.0.0"

# Add GitHub as remote (replace YOUR-USERNAME)
git remote add origin https://github.com/YOUR-USERNAME/field-service-management.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

## Step 3: Configure Repository Settings

### Add License Badge to README

Add this to the top of your README.md:

```markdown
# Field Service Management System

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
```

### Set License in GitHub

1. Go to your repository on GitHub
2. Click "Add file" > "Upload files"
3. GitHub should auto-detect `LICENSE.txt`
4. Go to repository settings
5. Scroll to "About" section (right sidebar)
6. Click ⚙️ gear icon
7. Select "GNU Affero General Public License v3.0" from dropdown

### Add Topics/Tags

In repository settings > About, add topics:
- `field-service`
- `azure`
- `react`
- `typescript`
- `nodejs`
- `sql-server`
- `agpl`
- `service-management`

### Create Release

1. Go to your repository
2. Click "Releases" in right sidebar
3. Click "Create a new release"
4. Tag version: `v1.0.0`
5. Release title: `Initial Release v1.0.0`
6. Description:
   ```markdown
   ## Features
   - Complete field service management system
   - Multi-tenant support
   - Azure-ready deployment
   - Automated setup scripts
   
   ## Installation
   See [README.md](README.md) for installation instructions.
   
   ## License
   AGPL-3.0
   ```
7. Click "Publish release"

---

## Recommended: Add .gitignore

Create `.gitignore` file to exclude sensitive/unnecessary files:

```gitignore
# Dependencies
node_modules/
package-lock.json
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build outputs
dist/
build/
*.log

# Environment files (IMPORTANT!)
.env
.env.local
.env.production
config.json

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
desktop.ini

# Azure
.azure/
*.azureauth

# Temporary files
*.tmp
*.temp
temp/
tmp/
```

**Add this file:**
```powershell
# Create .gitignore
@"
node_modules/
.env
config.json
dist/
build/
.DS_Store
Thumbs.db
*.log
"@ | Set-Content .gitignore

# Commit it
git add .gitignore
git commit -m "Add .gitignore"
git push
```

---

## IMPORTANT: Security Check Before Pushing

**NEVER push these files to public GitHub:**
- ❌ `config.json` (only push `config.json.template`)
- ❌ `.env` files with real credentials
- ❌ Database connection strings
- ❌ API keys or tokens
- ❌ Azure subscription IDs
- ❌ Passwords

**Run this check before pushing:**
```powershell
# Search for potential secrets
Get-ChildItem -Recurse -File | Select-String -Pattern "password=|api[_-]?key=|secret=" -CaseSensitive:$false

# Check for config.json (should only have .template)
Get-ChildItem -Recurse -Filter "config.json"

# Check for .env files (should only have .example)
Get-ChildItem -Recurse -Filter ".env"
```

If any are found, add them to `.gitignore` and run:
```powershell
git rm --cached <filename>
git commit -m "Remove sensitive file"
```

---

## Recommended: GitHub Repository Setup

### Enable Issues
1. Go to Settings > General
2. Check "Issues" under Features

### Add Description & Website
1. Click ⚙️ next to "About" on right sidebar
2. Description: `AGPL-licensed field service management system for Azure deployment`
3. Website: Link to your demo (if you have one)

### Create README Sections
Your README already has most of this, but ensure you have:
- [ ] Clear project description
- [ ] Feature list
- [ ] Quick start guide
- [ ] Prerequisites
- [ ] Installation steps
- [ ] Configuration instructions
- [ ] License information
- [ ] Contributing guidelines (if accepting contributions)

### Add CONTRIBUTING.md (Optional)
If you want community contributions:

```markdown
# Contributing to Field Service Management System

## AGPL License
All contributions must be licensed under AGPL-3.0.

## How to Contribute
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Code Standards
- Follow existing code style
- Add comments for complex logic
- Update documentation
- Test all changes

## Questions?
Open an issue for discussion before starting major changes.
```

---

## After Publishing

### 1. Test Clone
Clone your repository in a different location to verify everything works:

```powershell
cd C:\temp
git clone https://github.com/YOUR-USERNAME/field-service-management.git
cd field-service-management

# Test that installation works
Copy-Item config.json.template config.json
# Edit config.json and try deploying
```

### 2. Share Your Project
- Post on social media (Twitter, LinkedIn)
- Share in relevant communities (Reddit r/selfhosted, r/azure)
- Submit to awesome lists
- Write a blog post about it

### 3. Monitor Activity
- Watch for issues and pull requests
- Respond to questions
- Review contributions
- Update documentation based on feedback

---

## Ongoing Maintenance

### When You Make Updates

```powershell
# Make your changes
# ...

# Stage changes
git add .

# Commit with descriptive message
git commit -m "Fix: Corrected site editing field priority"

# Push to GitHub
git push

# Create new release for major updates
# Go to GitHub > Releases > Create new release
# Tag: v1.1.0
```

### Semantic Versioning
- `v1.0.0` - Initial release
- `v1.0.1` - Bug fixes
- `v1.1.0` - New features (backward compatible)
- `v2.0.0` - Breaking changes

---

## Optional: GitHub Actions (CI/CD)

You can add automated testing and deployment with GitHub Actions.

Create `.github/workflows/test.yml`:

```yaml
name: Test Build

on: [push, pull_request]

jobs:
  test-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install and Build Frontend
        run: |
          cd frontend
          npm install
          npm run build
  
  test-api:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Test API Dependencies
        run: |
          cd api
          npm install
```

This runs automatically on every push to verify the code builds successfully.

---

## Questions?

- **What if I already have code in GitHub?** - Just add the AGPL license and update README
- **Can I make it private?** - Yes, but AGPL requires sharing source when deployed as a service
- **What about forks?** - Others can fork under AGPL terms, which benefits everyone
- **How do I handle contributions?** - Contributors agree their code is AGPL-licensed

---

## Resources

- [GitHub Quickstart](https://docs.github.com/en/get-started/quickstart)
- [AGPL FAQ](https://www.gnu.org/licenses/gpl-faq.html#AGPLv3)
- [Git Documentation](https://git-scm.com/doc)
- [GitHub Actions](https://docs.github.com/en/actions)

---

**Ready to publish? Great! Your AGPL-licensed project will benefit the community while ensuring improvements come back to everyone.** 🚀
