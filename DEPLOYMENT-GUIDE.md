# Azure Deployment Guide

This guide will walk you through deploying the Field Service Management System to Azure.

## Prerequisites

Before you begin, ensure you have:

1. **Azure Subscription**
   - Active Azure subscription
   - Sufficient permissions to create resources

2. **Installed Software**
   - Azure CLI ([Install](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli))
   - Node.js 18+ ([Install](https://nodejs.org/))
   - Git (optional, for version control)

3. **Required Information**
   - Choose a unique app name (lowercase, no spaces)
   - Choose an Azure region (e.g., eastus, westus2)
   - Choose your company code (3-10 uppercase letters)

## Step 1: Azure Login

```powershell
# Login to Azure
az login

# Set your subscription (if you have multiple)
az account set --subscription "YOUR_SUBSCRIPTION_NAME_OR_ID"

# Verify you're logged in
az account show
```

## Step 2: Configure Your Deployment

1. **Copy Configuration Template**
   ```powershell
   Copy-Item config.json.template config.json
   ```

2. **Edit config.json**
   Replace the placeholders:
   - `YOUR_SQL_SERVER_NAME` → Your desired SQL server name (must be globally unique)
   - `YOUR_DATABASE_NAME` → Your database name (e.g., FieldServiceDB)
   - `YOUR_STATIC_WEB_APP_URL` → Will be generated, can update after deployment
   - `YOUR_COMPANY_CODE` → Your company code (e.g., ACME, CONTOSO)

## Step 3: Create Azure Resources

### Option A: Automated Script (Recommended)

```powershell
cd deployment
.\deploy-to-azure.ps1 -AppName "your-app-name" -Location "eastus" -CompanyCode "YOUR_CODE"
```

The script will:
- Create a resource group
- Create Azure SQL Database
- Create App Service for API
- Create Static Web App for frontend
- Configure firewall rules
- Set up application settings

### Option B: Manual Setup

#### 1. Create Resource Group
```powershell
$resourceGroup = "field-service-rg"
$location = "eastus"

az group create --name $resourceGroup --location $location
```

#### 2. Create SQL Database
```powershell
$sqlServer = "your-sql-server-name"
$sqlDatabase = "FieldServiceDB"

# Create SQL Server
az sql server create `
  --name $sqlServer `
  --resource-group $resourceGroup `
  --location $location `
  --admin-user sqladmin `
  --admin-password "YourStrongPassword123!"

# Create Database
az sql db create `
  --resource-group $resourceGroup `
  --server $sqlServer `
  --name $sqlDatabase `
  --service-objective S0

# Configure Firewall (Allow Azure Services)
az sql server firewall-rule create `
  --resource-group $resourceGroup `
  --server $sqlServer `
  --name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0
```

#### 3. Create App Service (API)
```powershell
$appServicePlan = "field-service-plan"
$appServiceName = "field-service-api"

# Create App Service Plan
az appservice plan create `
  --name $appServicePlan `
  --resource-group $resourceGroup `
  --sku B1 `
  --is-linux

# Create Web App
az webapp create `
  --resource-group $resourceGroup `
  --plan $appServicePlan `
  --name $appServiceName `
  --runtime "NODE:18-lts"

# Configure startup command
az webapp config set `
  --resource-group $resourceGroup `
  --name $appServiceName `
  --startup-file "node api.cjs"
```

#### 4. Create Static Web App (Frontend)
```powershell
$staticWebAppName = "field-service-app"

az staticwebapp create `
  --name $staticWebAppName `
  --resource-group $resourceGroup `
  --location $location
```

## Step 4: Deploy Database Schema

```powershell
# Install SQL tools if not already installed
winget install Microsoft.SQLServer.SQLCMD

# Run schema creation
sqlcmd -S $sqlServer.database.windows.net -d $sqlDatabase -U sqladmin -P "YourStrongPassword123!" -i "..\database\schema.sql"
```

### Creating the Initial Admin User

**The automated deployment script (Option A) handles this automatically**, but if you're deploying manually:

1. **Edit the Admin Creation Script**
   - Open `database\create-initial-admin.sql`
   - Update these variables:
   ```sql
   DECLARE @CompanyCode NVARCHAR(10) = 'YOUR_COMPANY_CODE'  -- Change to your company code
   DECLARE @Username NVARCHAR(100) = 'admin_001'            -- Your admin username
   DECLARE @Password NVARCHAR(255) = 'YOUR_SECURE_PASSWORD' -- Use a strong password
   ```

2. **Run the Script**
   ```powershell
   sqlcmd -S $sqlServer.database.windows.net -d $sqlDatabase -U sqladmin -P "YourStrongPassword123!" -i "..\database\create-initial-admin.sql"
   ```

3. **Save the Credentials**
   The script will output your admin credentials. **Save these securely!**

**IMPORTANT SECURITY NOTES:**
- Each installation should have unique admin credentials
- Never use default passwords in production
- Change the password immediately after first login
- Keep credentials in a secure password manager

### Password Recovery

If you forget the admin password, use the password reset script:

1. **Edit Reset Script**
   - Open `database\reset-admin-password.sql`
   - Update the variables:
   ```sql
   DECLARE @CompanyCode NVARCHAR(10) = 'YOUR_COMPANY_CODE'
   DECLARE @Username NVARCHAR(100) = 'admin_001'
   DECLARE @NewPassword NVARCHAR(255) = 'YOUR_NEW_PASSWORD'
   ```

2. **Run the Reset**
   ```powershell
   sqlcmd -S $sqlServer.database.windows.net -d $sqlDatabase -U sqladmin -P "YourStrongPassword123!" -i "..\database\reset-admin-password.sql"
   ```

## Step 5: Build and Deploy Frontend

```powershell
cd ..\frontend

# Install dependencies
npm install

# Update API URL in src/services/SqlApiService.ts
# Change API_BASE_URL to: https://YOUR-APP-SERVICE-NAME.azurewebsites.net

# Build
npm run build

# Get Static Web App deployment token
$deploymentToken = az staticwebapp secrets list --name $staticWebAppName --resource-group $resourceGroup --query "properties.apiKey" -o tsv

# Deploy
npx @azure/static-web-apps-cli deploy ./dist --deployment-token $deploymentToken --env production
```

## Step 6: Deploy API

```powershell
cd ..\api

# Deploy to App Service
az webapp deploy `
  --resource-group $resourceGroup `
  --name $appServiceName `
  --src-path api.cjs `
  --type static `
  --target-path api.cjs
```

## Step 7: Configure CORS

```powershell
# Get Static Web App URL
$staticWebAppUrl = az staticwebapp show --name $staticWebAppName --resource-group $resourceGroup --query "defaultHostname" -o tsv

# Configure CORS on API
az webapp cors add `
  --resource-group $resourceGroup `
  --name $appServiceName `
  --allowed-origins "https://$staticWebAppUrl"
```

## Step 8: Verify Deployment

1. **Check API Health**
   ```powershell
   curl https://YOUR-APP-SERVICE-NAME.azurewebsites.net/api/health
   ```

2. **Access Frontend**
   - Navigate to: `https://YOUR-STATIC-WEB-APP-NAME.azurestaticapps.net`
   - Login with initial admin credentials:
     - Username: `admin_001`
     - Password: `Admin123!` (change immediately)

## Post-Deployment Configuration

### 1. Update Frontend API URL
If not done during build:
```typescript
// frontend/src/services/SqlApiService.ts
const API_BASE_URL = 'https://YOUR-APP-SERVICE-NAME.azurewebsites.net'
```

### 2. Configure Company Settings
- Login as admin
- Navigate to Settings
- Update company information

### 3. Create Users
- Admin dashboard > Users
- Add dispatchers and technicians

### 4. Security Hardening
- Change admin password immediately
- Configure SQL firewall rules for your IP
- Enable App Service authentication (optional)
- Review activity logs

## Cost Estimation

Based on Azure pricing (subject to change):

| Resource | Tier | Estimated Monthly Cost |
|----------|------|------------------------|
| Azure SQL Database | S0 (Standard) | ~$15 |
| App Service | B1 (Basic) | ~$13 |
| Static Web App | Free | $0 |
| **Total** | | **~$28/month** |

You can scale up or down based on usage.

## Troubleshooting

### Database Connection Issues
- Verify firewall rules allow Azure services
- Check connection string in config.json
- Ensure SQL authentication is enabled

### API Won't Start
- Check App Service logs: `az webapp log tail --resource-group $resourceGroup --name $appServiceName`
- Verify startup command: `node api.cjs`
- Check application settings

### Frontend Can't Connect to API
- Verify CORS configuration
- Check API_BASE_URL in frontend
- Ensure API is running and accessible

### Deployment Fails
- Verify Azure CLI is authenticated: `az account show`
- Check resource name uniqueness
- Ensure sufficient permissions in subscription

## Updating the Application

### Update Frontend
```powershell
cd frontend
npm run build
npx @azure/static-web-apps-cli deploy ./dist --deployment-token $deploymentToken --env production
```

### Update API
```powershell
cd api
az webapp deploy --resource-group $resourceGroup --name $appServiceName --src-path api.cjs --type static --target-path api.cjs
```

### Update Database Schema
```powershell
sqlcmd -S $sqlServer.database.windows.net -d $sqlDatabase -U sqladmin -P "YourPassword" -i "path\to\migration.sql"
```

## Backup and Recovery

### Database Backup
Azure SQL automatically creates backups. To create manual backup:
```powershell
az sql db copy `
  --resource-group $resourceGroup `
  --server $sqlServer `
  --name $sqlDatabase `
  --dest-name "$sqlDatabase-backup-$(Get-Date -Format 'yyyyMMdd')"
```

### Export Configuration
```powershell
az group export --resource-group $resourceGroup > azure-resources.json
```

## Next Steps

- Review [Configuration Guide](docs/CONFIGURATION-GUIDE.md)
- Read [API Documentation](docs/API.md)
- See [Troubleshooting](docs/TROUBLESHOOTING.md)

## Support

For deployment issues:
1. Check Azure Portal for resource status
2. Review App Service logs
3. Verify SQL connection and firewall rules
4. Consult troubleshooting guide
