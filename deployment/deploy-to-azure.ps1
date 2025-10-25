# Automated Azure Deployment Script for Field Service Management System
# This script creates all necessary Azure resources and deploys the application

param(
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$true)]
    [string]$CompanyCode,
    
    [Parameter(Mandatory=$false)]
    [string]$SqlAdminPassword
)

# Validate parameters
if ($AppName -notmatch '^[a-z0-9-]{3,24}$') {
    Write-Error "AppName must be 3-24 characters, lowercase letters, numbers, and hyphens only"
    exit 1
}

if ($CompanyCode -notmatch '^[A-Z]{3,10}$') {
    Write-Error "CompanyCode must be 3-10 uppercase letters"
    exit 1
}

# Generate strong password if not provided
if (-not $SqlAdminPassword) {
    Add-Type -AssemblyName 'System.Web'
    $SqlAdminPassword = [System.Web.Security.Membership]::GeneratePassword(16, 4)
    Write-Host "Generated SQL Admin Password: $SqlAdminPassword" -ForegroundColor Yellow
    Write-Host "SAVE THIS PASSWORD - You'll need it to access the database" -ForegroundColor Red
}

# Set variables
$resourceGroup = "$AppName-rg"
$sqlServer = "$AppName-sql"
$sqlDatabase = "FieldServiceDB"
$appServicePlan = "$AppName-plan"
$appServiceName = "$AppName-api"
$staticWebAppName = "$AppName-app"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Field Service Management - Azure Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  App Name: $AppName"
Write-Host "  Location: $Location"
Write-Host "  Company Code: $CompanyCode"
Write-Host "  Resource Group: $resourceGroup"
Write-Host ""

# Check if logged in to Azure
Write-Host "Checking Azure login..." -ForegroundColor Cyan
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "Not logged in to Azure. Please login..." -ForegroundColor Yellow
    az login
    $account = az account show | ConvertFrom-Json
}

Write-Host "Logged in as: $($account.user.name)" -ForegroundColor Green
Write-Host "Subscription: $($account.name)" -ForegroundColor Green
Write-Host ""

# Create Resource Group
Write-Host "Creating resource group..." -ForegroundColor Cyan
az group create --name $resourceGroup --location $Location --output none
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Resource group created" -ForegroundColor Green
} else {
    Write-Error "Failed to create resource group"
    exit 1
}

# Create SQL Server
Write-Host "Creating SQL Server..." -ForegroundColor Cyan
az sql server create `
    --name $sqlServer `
    --resource-group $resourceGroup `
    --location $Location `
    --admin-user sqladmin `
    --admin-password $SqlAdminPassword `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ SQL Server created" -ForegroundColor Green
} else {
    Write-Error "Failed to create SQL Server"
    exit 1
}

# Configure SQL Firewall
Write-Host "Configuring SQL Server firewall..." -ForegroundColor Cyan
az sql server firewall-rule create `
    --resource-group $resourceGroup `
    --server $sqlServer `
    --name AllowAzureServices `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 0.0.0.0 `
    --output none

Write-Host "✓ Firewall configured" -ForegroundColor Green

# Create SQL Database
Write-Host "Creating SQL Database..." -ForegroundColor Cyan
az sql db create `
    --resource-group $resourceGroup `
    --server $sqlServer `
    --name $sqlDatabase `
    --service-objective S0 `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ SQL Database created" -ForegroundColor Green
} else {
    Write-Error "Failed to create SQL Database"
    exit 1
}

# Create App Service Plan
Write-Host "Creating App Service Plan..." -ForegroundColor Cyan
az appservice plan create `
    --name $appServicePlan `
    --resource-group $resourceGroup `
    --location $Location `
    --sku B1 `
    --is-linux `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ App Service Plan created" -ForegroundColor Green
} else {
    Write-Error "Failed to create App Service Plan"
    exit 1
}

# Create App Service (API)
Write-Host "Creating App Service for API..." -ForegroundColor Cyan
az webapp create `
    --resource-group $resourceGroup `
    --plan $appServicePlan `
    --name $appServiceName `
    --runtime "NODE:18-lts" `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ App Service created" -ForegroundColor Green
} else {
    Write-Error "Failed to create App Service"
    exit 1
}

# Configure App Service startup command
az webapp config set `
    --resource-group $resourceGroup `
    --name $appServiceName `
    --startup-file "node api.cjs" `
    --output none

# Create Static Web App
Write-Host "Creating Static Web App for frontend..." -ForegroundColor Cyan
az staticwebapp create `
    --name $staticWebAppName `
    --resource-group $resourceGroup `
    --location $Location `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Static Web App created" -ForegroundColor Green
} else {
    Write-Error "Failed to create Static Web App"
    exit 1
}

# Get Static Web App URL
$staticWebAppUrl = az staticwebapp show `
    --name $staticWebAppName `
    --resource-group $resourceGroup `
    --query "defaultHostname" `
    -o tsv

Write-Host "✓ Frontend URL: https://$staticWebAppUrl" -ForegroundColor Green

# Configure CORS
Write-Host "Configuring CORS..." -ForegroundColor Cyan
az webapp cors add `
    --resource-group $resourceGroup `
    --name $appServiceName `
    --allowed-origins "https://$staticWebAppUrl" `
    --output none

Write-Host "✓ CORS configured" -ForegroundColor Green

# Deploy Database Schema
Write-Host "Deploying database schema..." -ForegroundColor Cyan
$sqlConnectionString = "Server=tcp:$sqlServer.database.windows.net,1433;Initial Catalog=$sqlDatabase;Persist Security Info=False;User ID=sqladmin;Password=$SqlAdminPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# Check if sqlcmd is available
$sqlcmdPath = Get-Command sqlcmd -ErrorAction SilentlyContinue
if ($sqlcmdPath) {
    Write-Host "Deploying schema using sqlcmd..." -ForegroundColor Cyan
    $schemaFile = Join-Path $PSScriptRoot "..\database\schema.sql"
    if (Test-Path $schemaFile) {
        sqlcmd -S "$sqlServer.database.windows.net" -d $sqlDatabase -U sqladmin -P $SqlAdminPassword -i $schemaFile
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Database schema deployed" -ForegroundColor Green
        } else {
            Write-Warning "Database schema deployment had issues. You may need to run it manually."
        }
    } else {
        Write-Warning "Schema file not found at $schemaFile"
    }
} else {
    Write-Warning "sqlcmd not found. Please install SQL Server tools and run database\schema.sql manually"
    Write-Host "Connection: Server=$sqlServer.database.windows.net User=sqladmin Password=$SqlAdminPassword Database=$sqlDatabase"
}


# Create Initial Admin User
Write-Host "Creating initial admin user..." -ForegroundColor Cyan
$adminUsername = "admin_001"
$adminPassword = [System.Web.Security.Membership]::GeneratePassword(12, 2)
$adminScript = Join-Path $PSScriptRoot "..\database\create-initial-admin.sql"

if (Test-Path $adminScript) {
    # Read and customize the script
    $sqlContent = Get-Content $adminScript -Raw
    $sqlContent = $sqlContent -replace "DECLARE @CompanyCode NVARCHAR\(10\) = 'CHANGEME'", "DECLARE @CompanyCode NVARCHAR(10) = '$CompanyCode'"
    $sqlContent = $sqlContent -replace "DECLARE @Password NVARCHAR\(255\) = 'Admin123!'", "DECLARE @Password NVARCHAR(255) = '$adminPassword'"
    
    # Save customized script to temp file
    $tempScript = Join-Path $env:TEMP "create-admin-temp.sql"
    $sqlContent | Set-Content $tempScript
    
    if ($sqlcmdPath) {
        sqlcmd -S "$sqlServer.database.windows.net" -d $sqlDatabase -U sqladmin -P $SqlAdminPassword -i $tempScript
        if ($LASTEXITCODE -eq 0) {
            Write-Host " Initial admin user created" -ForegroundColor Green
            Write-Host ""
            Write-Host "==========================================="" -ForegroundColor Yellow
            Write-Host "INITIAL ADMIN CREDENTIALS - SAVE THESE!" -ForegroundColor Yellow
            Write-Host "==========================================="" -ForegroundColor Yellow
            Write-Host "Username: $adminUsername" -ForegroundColor White
            Write-Host "Password: $adminPassword" -ForegroundColor White
            Write-Host "Company: $CompanyCode" -ForegroundColor White
            Write-Host "==========================================="" -ForegroundColor Yellow
            Write-Host ""
        }
        Remove-Item $tempScript -ErrorAction SilentlyContinue
    } else {
        Write-Warning "Could not create admin user automatically. Run database\create-initial-admin.sql manually after deployment."
        Write-Host "Remember to update the CompanyCode and Password in the script!"
    }
} else {
    Write-Warning "Admin creation script not found. You'll need to create an admin user manually."
}
# Update config.json
Write-Host "Creating configuration file..." -ForegroundColor Cyan
$configPath = Join-Path $PSScriptRoot "..\config.json"
$config = @{
    database = @{
        server = "$sqlServer.database.windows.net"
        database = $sqlDatabase
        authentication = @{
            type = "default"
            options = @{
                userName = "sqladmin"
                password = $SqlAdminPassword
            }
        }
        options = @{
            encrypt = $true
            trustServerCertificate = $false
        }
    }
    server = @{
        port = 3000
    }
    cors = @{
        origin = "https://$staticWebAppUrl"
        credentials = $true
    }
    app = @{
        name = "Field Service Management"
        companyCode = $CompanyCode
    }
}

$config | ConvertTo-Json -Depth 10 | Set-Content $configPath
Write-Host "✓ Configuration file created" -ForegroundColor Green

# Build Frontend
Write-Host "Building frontend..." -ForegroundColor Cyan
$frontendPath = Join-Path $PSScriptRoot "..\frontend"
Push-Location $frontendPath

# Update API URL in source
$apiServicePath = "src\services\SqlApiService.ts"
if (Test-Path $apiServicePath) {
    $content = Get-Content $apiServicePath -Raw
    $content = $content -replace "const API_BASE_URL = '[^']*'", "const API_BASE_URL = 'https://$appServiceName.azurewebsites.net'"
    $content | Set-Content $apiServicePath -NoNewline
}

npm install --silent
npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Frontend built successfully" -ForegroundColor Green
} else {
    Pop-Location
    Write-Error "Failed to build frontend"
    exit 1
}

# Deploy Frontend
Write-Host "Deploying frontend to Static Web App..." -ForegroundColor Cyan
$deploymentToken = az staticwebapp secrets list `
    --name $staticWebAppName `
    --resource-group $resourceGroup `
    --query "properties.apiKey" `
    -o tsv

$env:SWA_CLI_DEPLOYMENT_TOKEN = $deploymentToken
npx @azure/static-web-apps-cli deploy ./dist --deployment-token $deploymentToken --env production --no-use-keychain

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Frontend deployed" -ForegroundColor Green
} else {
    Pop-Location
    Write-Error "Failed to deploy frontend"
    exit 1
}

Pop-Location

# Deploy API
Write-Host "Deploying API to App Service..." -ForegroundColor Cyan
$apiPath = Join-Path $PSScriptRoot "..\api\api.cjs"
az webapp deploy `
    --resource-group $resourceGroup `
    --name $appServiceName `
    --src-path $apiPath `
    --type static `
    --target-path api.cjs `
    --timeout 300

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ API deployed" -ForegroundColor Green
} else {
    Write-Error "Failed to deploy API"
    exit 1
}

# Deploy config.json to App Service
Write-Host "Deploying configuration to App Service..." -ForegroundColor Cyan
az webapp deploy `
    --resource-group $resourceGroup `
    --name $appServiceName `
    --src-path $configPath `
    --type static `
    --target-path config.json `
    --timeout 300

# Test API Health
Write-Host "Testing API..." -ForegroundColor Cyan
Start-Sleep -Seconds 10
try {
    $healthCheck = Invoke-WebRequest -Uri "https://$appServiceName.azurewebsites.net/api/health" -UseBasicParsing -TimeoutSec 30
    if ($healthCheck.StatusCode -eq 200) {
        Write-Host "✓ API is healthy" -ForegroundColor Green
    }
} catch {
    Write-Warning "API health check failed. The API may still be starting up."
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your application has been deployed successfully!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Application URLs:" -ForegroundColor Yellow
Write-Host "  Frontend: https://$staticWebAppUrl" -ForegroundColor White
Write-Host "  API: https://$appServiceName.azurewebsites.net" -ForegroundColor White
Write-Host ""
Write-Host "Database Details:" -ForegroundColor Yellow
Write-Host "  Server: $sqlServer.database.windows.net" -ForegroundColor White
Write-Host "  Database: $sqlDatabase" -ForegroundColor White
Write-Host "  Username: sqladmin" -ForegroundColor White
Write-Host "  Password: $SqlAdminPassword" -ForegroundColor White
Write-Host ""
Write-Host "Default Admin Credentials:" -ForegroundColor Yellow
Write-Host "  Username: admin_001" -ForegroundColor White
Write-Host "  Password: Admin123! (CHANGE IMMEDIATELY)" -ForegroundColor Red
Write-Host ""
Write-Host "Azure Resource Group: $resourceGroup" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Navigate to https://$staticWebAppUrl" -ForegroundColor White
Write-Host "  2. Login with admin credentials" -ForegroundColor White
Write-Host "  3. Change the admin password immediately" -ForegroundColor White
Write-Host "  4. Configure company settings" -ForegroundColor White
Write-Host "  5. Create additional users" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANT: Save the SQL Admin password shown above!" -ForegroundColor Red
Write-Host ""
