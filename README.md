# Field Service Management System

A comprehensive field service management application with ticket tracking, customer management, site management, and service request handling.

## Features

- **Ticket Management** - Create, track, and manage service tickets
- **Customer Management** - Maintain customer records and relationships
- **Site Management** - Track customer locations and site information
- **User Management** - Role-based access control (Admin, Tech, Dispatcher)
- **Service Requests** - Public-facing service request portal
- **License Tracking** - Software license management
- **Vendor Management** - Track service vendors and contractors
- **Activity Logging** - Comprehensive audit trail
- **Multi-tenant Support** - Company code isolation for data security

## Architecture

- **Frontend**: React + TypeScript + Vite
- **Backend**: Node.js + Express
- **Database**: Microsoft SQL Server
- **Hosting**: Azure Static Web Apps (frontend) + Azure App Service (API)

## System Requirements

### For Azure Deployment:
- Azure subscription
- Azure CLI installed
- Node.js 18+ installed locally (for build process)

### For Local Development:
- Node.js 18+
- SQL Server 2019+ or SQL Server Express
- npm or yarn package manager

## Quick Start

### Option 1: Deploy to Azure (Recommended)

1. **Install Prerequisites**
   ```powershell
   # Install Azure CLI if not already installed
   winget install Microsoft.AzureCLI
   
   # Install Node.js 18+ if not already installed
   winget install OpenJS.NodeJS.LTS
   ```

2. **Configure Your Deployment**
   ```powershell
   # Copy configuration template
   Copy-Item config.json.template config.json
   
   # Edit config.json with your values:
   # - SQL Server name
   # - Database name
   # - Company code
   ```

3. **Run Automated Deployment**
   ```powershell
   cd deployment
   .\deploy-to-azure.ps1
   ```

   The script will:
   - Create Azure resources (SQL Database, App Service, Static Web App)
   - Deploy the database schema
   - Build and deploy the frontend
   - Deploy the API
   - Create the initial admin user

4. **Access Your Application**
   - Frontend: `https://your-app-name.azurestaticapps.net`
   - Default admin credentials will be displayed after setup

### Option 2: Local Development

See [docs/LOCAL-SETUP.md](docs/LOCAL-SETUP.md) for detailed local development instructions.

### Option 3: Docker

See [deployment/docker-compose.yml](deployment/docker-compose.yml) for container-based deployment.

## Initial Setup

After deployment, you'll need to:

1. **Create Initial Admin User**
   - Run the script: `database/create-initial-admin.sql`
   - Or use the automated setup during deployment

2. **Configure Company Settings**
   - Log in as admin
   - Go to Settings > Company Settings
   - Configure company code, branding, and preferences

3. **Create Additional Users**
   - Admin dashboard > Users > Add User
   - Assign roles: Admin, Dispatcher, or Tech

## Configuration

### Frontend Configuration
Located in `frontend/src/services/SqlApiService.ts`:
- API_BASE_URL - Points to your API endpoint

### API Configuration
Located in `config.json`:
- Database connection settings
- CORS origins
- Port configuration
- Company settings

### Database Configuration
- Connection string in API configuration
- Azure SQL or local SQL Server
- See `database/schema.sql` for complete schema

## Security

- Multi-tenant data isolation via CompanyCode
- Role-based access control (RBAC)
- Azure Active Directory authentication for SQL
- HTTPS/TLS encryption
- Activity logging for audit trails

## File Structure

```
field-service-distribution/
├── frontend/          # React frontend application
├── api/              # Node.js Express API
├── database/         # SQL schema and setup scripts
├── deployment/       # Deployment automation scripts
├── docs/             # Additional documentation
├── config.json.template  # Configuration template
└── .env.example      # Environment variables template
```

## Documentation

- [Deployment Guide](DEPLOYMENT-GUIDE.md) - Detailed Azure deployment steps
- [System Requirements](docs/SYSTEM-REQUIREMENTS.md) - Prerequisites and dependencies
- [Configuration Guide](docs/CONFIGURATION-GUIDE.md) - Detailed configuration options
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [API Documentation](docs/API.md) - API endpoints and usage

## Support

For issues and questions:
1. Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
2. Review the [Deployment Guide](DEPLOYMENT-GUIDE.md)
3. Contact your system administrator

## License

This software is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.

**What this means:**
- ✅ Free to use, modify, and distribute
- ✅ Can be used commercially
- ⚠️ **If you run this as a web service, you must share your source code**
- ⚠️ Modifications must also be AGPL-3.0

See [LICENSE.txt](LICENSE.txt) for the full license text.

**Need a commercial license?** Contact: [your email address]

## Version

Version 1.0.0 - Initial Release
