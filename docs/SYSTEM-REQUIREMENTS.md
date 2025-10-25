# System Requirements

## For Azure Deployment

### Required Software
- **Azure CLI** version 2.50.0 or later
  - Installation: `winget install Microsoft.AzureCLI`
  - Or download from: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
  
- **Node.js** version 18.0.0 or later (LTS recommended)
  - Installation: `winget install OpenJS.NodeJS.LTS`
  - Or download from: https://nodejs.org/

- **PowerShell** 5.1 or later (Windows) or PowerShell Core 7+ (cross-platform)
  - Included with Windows 10/11
  - Or download from: https://github.com/PowerShell/PowerShell

### Azure Requirements
- Active Azure subscription
- Permissions to create resources:
  - Resource Groups
  - SQL Server and Database
  - App Service and App Service Plan
  - Static Web Apps
  
### Recommended
- **SQL Server Management Studio** (SSMS) or **Azure Data Studio**
  - For database administration
  - Download: https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms

## For Local Development

### Required Software
- **Node.js** 18.0.0 or later
- **SQL Server** 2019 or later, or **SQL Server Express**
  - Download SQL Server Express: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
  
- **npm** or **yarn** package manager (included with Node.js)

### Optional but Recommended
- **Git** for version control
  - Installation: `winget install Git.Git`
  
- **Visual Studio Code**
  - Installation: `winget install Microsoft.VisualStudioCode`
  - Recommended extensions:
    - ESLint
    - Prettier
    - SQL Server (mssql)
    - Azure Tools

## Browser Requirements

### Supported Browsers
- **Chrome** 90+
- **Edge** 90+
- **Firefox** 88+
- **Safari** 14+

### Required Features
- JavaScript enabled
- Cookies enabled
- LocalStorage support
- Modern CSS support (Grid, Flexbox)

## Network Requirements

### Ports
- **Frontend (local dev)**: 5173 (Vite dev server)
- **API (local)**: 3000 (configurable in config.json)
- **SQL Server (local)**: 1433 (default)

### Outbound Access (for Azure deployment)
- Azure endpoints (*.azure.com, *.azurewebsites.net, *.database.windows.net)
- npm registry (registry.npmjs.org)
- GitHub (for package downloads)

## Minimum Hardware Requirements

### Development Machine
- **CPU**: 2+ cores
- **RAM**: 8 GB minimum, 16 GB recommended
- **Disk Space**: 5 GB free space
- **Internet**: Broadband connection (for Azure deployment)

### Azure Resources (Recommended Tiers)

#### SQL Database
- **Tier**: Standard S0 or higher
- **Storage**: 250 GB
- **DTUs**: 10 minimum
- **Estimated Cost**: ~$15/month

#### App Service
- **Tier**: Basic B1 or higher
- **RAM**: 1.75 GB
- **CPU**: 1 core
- **Estimated Cost**: ~$13/month

#### Static Web App
- **Tier**: Free (sufficient for most use cases)
- **Bandwidth**: 100 GB/month
- **Estimated Cost**: $0

**Total Estimated Monthly Cost**: ~$28/month

### Scaling Recommendations

#### Small Business (1-10 users)
- SQL: Standard S0
- App Service: Basic B1
- Cost: ~$28/month

#### Medium Business (10-50 users)
- SQL: Standard S1
- App Service: Standard S1
- Cost: ~$100/month

#### Large Business (50+ users)
- SQL: Standard S2 or higher
- App Service: Standard S2 or Premium P1
- Consider: Azure Front Door, Application Insights
- Cost: $200+/month

## Software Versions Used

This application has been tested with:
- Node.js 18.20.0 LTS
- npm 10.5.0
- Azure CLI 2.58.0
- SQL Server 2022 / Azure SQL Database
- React 18.2.0
- TypeScript 5.3.3
- Vite 5.4.20
- Express 4.18.0
- mssql (Node.js driver) 10.0.0

## Operating System Compatibility

### Development
- **Windows** 10/11 (tested)
- **macOS** 12+ (should work, minimal testing)
- **Linux** Ubuntu 20.04+ (should work, minimal testing)

### Production (Azure)
- Runs on Azure's managed infrastructure
- OS-agnostic from deployment perspective

## Database Requirements

### SQL Server Features Required
- Full-text search (optional, for advanced search)
- JSON support (SQL Server 2016+)
- Computed columns
- Foreign key constraints
- Triggers (for audit logging)

### Minimum SQL Server Version
- SQL Server 2019 or later
- Azure SQL Database (any service tier)
- SQL Server Express (free, suitable for development)

## Security Requirements

### SSL/TLS
- Required for Azure SQL connections
- Required for production frontend (HTTPS)
- API should run behind HTTPS in production

### Authentication
- Azure Active Directory (recommended for SQL)
- SQL authentication supported
- Windows authentication (local development only)

## Limitations

### Free Tier Limitations
- Static Web App Free tier: 100 GB bandwidth/month
- No custom domain on free tier
- Limited build minutes

### SQL Database
- Max database size depends on tier
- Connection pool limits
- DTU/vCore limits based on tier

### Concurrent Users
- Scales with App Service tier
- Database connections limited by tier
- Recommended: Load testing before production

## Next Steps

After verifying requirements:
1. See [DEPLOYMENT-GUIDE.md](../DEPLOYMENT-GUIDE.md) for Azure deployment
2. See [LOCAL-SETUP.md](LOCAL-SETUP.md) for local development setup
3. See [CONFIGURATION-GUIDE.md](CONFIGURATION-GUIDE.md) for configuration options
