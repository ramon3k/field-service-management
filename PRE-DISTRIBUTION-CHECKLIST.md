# Pre-Distribution Checklist

Before distributing this package to customers, ensure you complete these steps:

## 1. Security & Credentials Review

### ✅ Remove Sensitive Data
- [ ] No production connection strings in any files
- [ ] No API keys or tokens in code
- [ ] No production database credentials
- [ ] No Azure subscription IDs
- [ ] No personal email addresses (except support)
- [ ] No hardcoded passwords

### ✅ Verify Template Files
- [ ] `config.json.template` contains only placeholders
- [ ] `.env.example` contains only placeholders
- [ ] `create-initial-admin.sql` has default/changeable credentials only
- [ ] No `.env` or `config.json` files with real values

## 2. Documentation Review

### ✅ README.md
- [ ] Installation instructions are clear
- [ ] Prerequisites are complete and accurate
- [ ] Support contact information is current
- [ ] Screenshots/examples are included (if applicable)
- [ ] Links to documentation are working

### ✅ DEPLOYMENT-GUIDE.md
- [ ] Azure deployment steps are tested
- [ ] All commands are correct for PowerShell
- [ ] Resource naming conventions are explained
- [ ] Cost estimates are current
- [ ] Troubleshooting section is comprehensive

### ✅ SYSTEM-REQUIREMENTS.md
- [ ] Software versions are accurate
- [ ] Browser compatibility is listed
- [ ] Azure tier requirements are specified
- [ ] Network requirements are documented

## 3. Code Quality

### ✅ Frontend (frontend/)
- [ ] No console.log statements in production code
- [ ] No commented-out code blocks
- [ ] TypeScript errors resolved (`npm run build` succeeds)
- [ ] ESLint warnings addressed
- [ ] Dependencies are current and secure (`npm audit`)

### ✅ Backend (api/)
- [ ] No console.log statements (except intentional logging)
- [ ] Error handling is comprehensive
- [ ] SQL injection protection verified
- [ ] Authentication/authorization is enforced
- [ ] Dependencies are current and secure (`npm audit`)

### ✅ Database (database/)
- [ ] Schema scripts are tested and working
- [ ] Initial admin creation script works
- [ ] Password reset script works
- [ ] Migration scripts (if any) are included
- [ ] Sample data scripts (if any) are sanitized

## 4. Deployment Scripts

### ✅ deploy-to-azure.ps1
- [ ] Script tested on clean Azure subscription
- [ ] All parameters are documented
- [ ] Error handling is robust
- [ ] Resource names follow Azure naming rules
- [ ] Script provides clear success/failure messages
- [ ] Admin user creation works correctly
- [ ] Credentials are displayed securely

## 5. Configuration Files

### ✅ package.json Files
- [ ] Correct versions specified
- [ ] All dependencies are necessary
- [ ] No dev-only packages in production dependencies
- [ ] Scripts are appropriate for distribution
- [ ] License field is set correctly

### ✅ config.json.template
- [ ] All required fields are present
- [ ] Placeholder format is clear (e.g., YOUR_VALUE_HERE)
- [ ] Comments explain each field
- [ ] Default values are safe (where applicable)

## 6. Legal & Licensing

### ✅ License Selection
- [ ] License type chosen (MIT, Proprietary, GPL, etc.)
- [ ] LICENSE.txt updated with chosen license
- [ ] License is appropriate for distribution model
- [ ] Copyright year and owner are correct

### ✅ Third-Party Dependencies
- [ ] All dependencies reviewed for license compatibility
- [ ] Attribution files included (if required)
- [ ] No GPL dependencies (if using permissive license)

## 7. Testing

### ✅ Clean Deployment Test
- [ ] Deployed to fresh Azure subscription
- [ ] Database schema created successfully
- [ ] Initial admin user created
- [ ] Frontend builds and deploys
- [ ] Backend API starts correctly
- [ ] Can log in with admin credentials
- [ ] Basic functionality works (create ticket, etc.)

### ✅ Documentation Walkthrough
- [ ] Followed README.md step-by-step
- [ ] Followed DEPLOYMENT-GUIDE.md step-by-step
- [ ] All commands work as documented
- [ ] No steps are missing
- [ ] Troubleshooting guide helps resolve common issues

## 8. Support Preparation

### ✅ Support Documentation
- [ ] Support contact information provided
- [ ] FAQ or knowledge base available
- [ ] Known issues documented
- [ ] Update/maintenance process explained

### ✅ Customer Onboarding
- [ ] Onboarding guide created (if needed)
- [ ] Training materials available (if needed)
- [ ] Demo environment available (if needed)

## 9. Package Structure

### ✅ File Organization
- [ ] All files are in correct directories
- [ ] No unnecessary files (node_modules, .git, etc.)
- [ ] No temporary or backup files
- [ ] No OS-specific files (.DS_Store, Thumbs.db)

### ✅ Archive Creation
- [ ] Package compressed (ZIP or TAR.GZ)
- [ ] Archive name includes version number
- [ ] README.md is at root of archive
- [ ] Archive extracts cleanly

## 10. Final Review

### ✅ Pre-Distribution Sign-Off
- [ ] Code review completed
- [ ] Security review completed
- [ ] Legal review completed (if required)
- [ ] Testing completed successfully
- [ ] Documentation reviewed and approved
- [ ] Support team briefed (if applicable)

## Distribution Methods

Once checklist is complete, you can distribute via:

1. **Direct Download**
   - Host on file server
   - Provide download link to customers
   - Include checksum for verification

2. **Version Control**
   - Push to private GitHub/GitLab repository
   - Grant customer access
   - Tag releases appropriately

3. **Package Registry**
   - Publish to private npm registry
   - Provide installation instructions

4. **Physical Media**
   - Burn to USB/DVD
   - Include printed documentation

## Post-Distribution

### ✅ Customer Follow-Up
- [ ] Confirm successful deployment
- [ ] Provide initial support
- [ ] Collect feedback
- [ ] Schedule training session (if applicable)

### ✅ Version Management
- [ ] Tag this version in version control
- [ ] Document changes in CHANGELOG.md
- [ ] Plan for future updates
- [ ] Establish update delivery method

---

## Quick Security Scan Commands

Run these before distribution:

```powershell
# Search for potential secrets
Get-ChildItem -Recurse -File | Select-String -Pattern "password|api[_-]?key|secret|token" -CaseSensitive:$false

# Find hardcoded IPs or URLs
Get-ChildItem -Recurse -File | Select-String -Pattern "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|https?://[^\s]+"

# Check for TODO/FIXME comments
Get-ChildItem -Recurse -File | Select-String -Pattern "TODO|FIXME|HACK|XXX"

# Verify no config files with real data
Get-ChildItem -Recurse -File -Include config.json,.env

# Check package.json for security issues
npm audit --audit-level=moderate
```

## Final Approval

**Approved By:** _____________________  
**Date:** _____________________  
**Version:** _____________________  
**Notes:** _____________________
