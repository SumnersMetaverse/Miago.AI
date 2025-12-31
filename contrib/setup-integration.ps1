# Bitcoin Core + Repository Integration Setup Script
# This script helps set up Bitcoin Core with your other repositories
# Run this in PowerShell as Administrator

# ============================================================================
# CONFIGURATION - UPDATE THESE WITH YOUR VALUES
# ============================================================================

# Bitcoin Core RPC Credentials (from your bitcoin.conf)
$BITCOIN_RPC_USER = "YOUR_RPC_USERNAME_HERE"
$BITCOIN_RPC_PASSWORD = "YOUR_RPC_PASSWORD_HERE"
$BITCOIN_RPC_HOST = "127.0.0.1"
$BITCOIN_RPC_PORT = "8332"

# Redis Configuration (from your Redis repository)
$REDIS_HOST = "YOUR_REDIS_HOST_HERE"
$REDIS_PORT = "6379"
$REDIS_PASSWORD = "YOUR_REDIS_PASSWORD_HERE"

# Tenderly Configuration (from tenderly.co)
$TENDERLY_API_KEY = "YOUR_TENDERLY_API_KEY_HERE"
$TENDERLY_PROJECT_ID = "YOUR_TENDERLY_PROJECT_ID_HERE"

# Project directories
$PROJECTS_DIR = "$HOME\projects"

# ============================================================================
# DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Bitcoin Core Integration Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

$prerequisites = @{
    "bitcoin-cli" = "Bitcoin Core"
    "git" = "Git"
    "python" = "Python 3"
    "node" = "Node.js"
}

$missing = @()
foreach ($cmd in $prerequisites.Keys) {
    if (Test-Command $cmd) {
        Write-Host "  ✓ $($prerequisites[$cmd]) installed" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $($prerequisites[$cmd]) NOT installed" -ForegroundColor Red
        $missing += $prerequisites[$cmd]
    }
}

if ($missing.Count -gt 0) {
    Write-Host ""
    Write-Host "Missing prerequisites: $($missing -join ', ')" -ForegroundColor Red
    Write-Host "Please install missing software before continuing." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Validate configuration
Write-Host "Validating configuration..." -ForegroundColor Yellow

$configValid = $true

if ($BITCOIN_RPC_USER -eq "YOUR_RPC_USERNAME_HERE") {
    Write-Host "  ✗ Bitcoin RPC username not configured" -ForegroundColor Red
    $configValid = $false
} else {
    Write-Host "  ✓ Bitcoin RPC username configured" -ForegroundColor Green
}

if ($BITCOIN_RPC_PASSWORD -eq "YOUR_RPC_PASSWORD_HERE") {
    Write-Host "  ✗ Bitcoin RPC password not configured" -ForegroundColor Red
    $configValid = $false
} else {
    Write-Host "  ✓ Bitcoin RPC password configured" -ForegroundColor Green
}

if (-not $configValid) {
    Write-Host ""
    Write-Host "Please update the configuration section at the top of this script." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test Bitcoin Core connection
Write-Host "Testing Bitcoin Core connection..." -ForegroundColor Yellow

try {
    $auth = "${BITCOIN_RPC_USER}:${BITCOIN_RPC_PASSWORD}"
    $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($auth))
    $headers = @{
        Authorization = "Basic $base64Auth"
        "Content-Type" = "application/json"
    }
    
    $body = @{
        jsonrpc = "2.0"
        id = "test"
        method = "getblockchaininfo"
        params = @()
    } | ConvertTo-Json
    
    $uri = "http://${BITCOIN_RPC_HOST}:${BITCOIN_RPC_PORT}/"
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -TimeoutSec 10
    
    if ($response.result) {
        Write-Host "  ✓ Bitcoin Core connection successful" -ForegroundColor Green
        Write-Host "    Chain: $($response.result.chain)" -ForegroundColor Gray
        Write-Host "    Blocks: $($response.result.blocks)" -ForegroundColor Gray
        Write-Host "    Progress: $([math]::Round($response.result.verificationprogress * 100, 2))%" -ForegroundColor Gray
    } else {
        Write-Host "  ✗ Unexpected response from Bitcoin Core" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  ✗ Failed to connect to Bitcoin Core" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "    Is Bitcoin Core running on ${BITCOIN_RPC_HOST}:${BITCOIN_RPC_PORT}?" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Create projects directory if it doesn't exist
if (-not (Test-Path $PROJECTS_DIR)) {
    Write-Host "Creating projects directory: $PROJECTS_DIR" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $PROJECTS_DIR | Out-Null
    Write-Host "  ✓ Projects directory created" -ForegroundColor Green
} else {
    Write-Host "  ✓ Projects directory exists: $PROJECTS_DIR" -ForegroundColor Green
}

Write-Host ""

# Setup environment variables
Write-Host "Setting up environment variables..." -ForegroundColor Yellow

$envVars = @{
    "BITCOIN_RPC_USER" = $BITCOIN_RPC_USER
    "BITCOIN_RPC_PASSWORD" = $BITCOIN_RPC_PASSWORD
    "BITCOIN_RPC_HOST" = $BITCOIN_RPC_HOST
    "BITCOIN_RPC_PORT" = $BITCOIN_RPC_PORT
}

if ($REDIS_HOST -ne "YOUR_REDIS_HOST_HERE") {
    $envVars["REDIS_HOST"] = $REDIS_HOST
    $envVars["REDIS_PORT"] = $REDIS_PORT
    if ($REDIS_PASSWORD -ne "YOUR_REDIS_PASSWORD_HERE") {
        $envVars["REDIS_PASSWORD"] = $REDIS_PASSWORD
    }
}

if ($TENDERLY_API_KEY -ne "YOUR_TENDERLY_API_KEY_HERE") {
    $envVars["TENDERLY_API_KEY"] = $TENDERLY_API_KEY
    $envVars["TENDERLY_PROJECT_ID"] = $TENDERLY_PROJECT_ID
}

foreach ($key in $envVars.Keys) {
    [Environment]::SetEnvironmentVariable($key, $envVars[$key], "User")
    Write-Host "  ✓ Set $key" -ForegroundColor Green
}

Write-Host ""
Write-Host "Note: You may need to restart your terminal for environment variables to take effect." -ForegroundColor Yellow
Write-Host ""

# Create .env file template
Write-Host "Creating .env template..." -ForegroundColor Yellow

$envTemplate = @"
# Bitcoin Core Configuration
BITCOIN_RPC_USER=$BITCOIN_RPC_USER
BITCOIN_RPC_PASSWORD=$BITCOIN_RPC_PASSWORD
BITCOIN_RPC_HOST=$BITCOIN_RPC_HOST
BITCOIN_RPC_PORT=$BITCOIN_RPC_PORT

# Redis Configuration (if applicable)
REDIS_HOST=$REDIS_HOST
REDIS_PORT=$REDIS_PORT
REDIS_PASSWORD=$REDIS_PASSWORD

# Tenderly Configuration (if applicable)
TENDERLY_API_KEY=$TENDERLY_API_KEY
TENDERLY_PROJECT_ID=$TENDERLY_PROJECT_ID

# Network Configuration
NETWORK=mainnet

# API Configuration
API_HOST=localhost
API_PORT=3000
"@

$envPath = Join-Path $PROJECTS_DIR ".env.template"
$envTemplate | Out-File -FilePath $envPath -Encoding UTF8
Write-Host "  ✓ Created .env template at: $envPath" -ForegroundColor Green
Write-Host ""

# Test Redis connection (if configured)
if ($REDIS_HOST -ne "YOUR_REDIS_HOST_HERE") {
    Write-Host "Testing Redis connection..." -ForegroundColor Yellow
    
    if (Test-Command "redis-cli") {
        try {
            if ($REDIS_PASSWORD -ne "YOUR_REDIS_PASSWORD_HERE") {
                $redisTest = redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD ping 2>&1
            } else {
                $redisTest = redis-cli -h $REDIS_HOST -p $REDIS_PORT ping 2>&1
            }
            
            if ($redisTest -match "PONG") {
                Write-Host "  ✓ Redis connection successful" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Redis connection failed" -ForegroundColor Red
            }
        } catch {
            Write-Host "  ✗ Redis connection failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ⚠ redis-cli not found, skipping Redis test" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Clone or update repositories
Write-Host "Repository Management" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

$repositories = @(
    @{
        Name = "Miago.AI"
        Url = "https://github.com/SumnersMetaverse/Miago.AI.git"
        Description = "Main Miago AI repository"
    }
)

foreach ($repo in $repositories) {
    $repoPath = Join-Path $PROJECTS_DIR $repo.Name
    
    if (Test-Path $repoPath) {
        Write-Host "Repository '$($repo.Name)' already exists" -ForegroundColor Yellow
        Write-Host "  Path: $repoPath" -ForegroundColor Gray
        
        $update = Read-Host "  Update repository? (y/n)"
        if ($update -eq "y") {
            Write-Host "  Updating..." -ForegroundColor Yellow
            Push-Location $repoPath
            git pull
            Pop-Location
            Write-Host "  ✓ Repository updated" -ForegroundColor Green
        }
    } else {
        Write-Host "Cloning '$($repo.Name)'..." -ForegroundColor Yellow
        Write-Host "  Description: $($repo.Description)" -ForegroundColor Gray
        
        git clone $repo.Url $repoPath
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Repository cloned successfully" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Failed to clone repository" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}

# Create integration test script
Write-Host "Creating integration test script..." -ForegroundColor Yellow

$testScript = @"
# Integration Test Script
# Tests connections to all configured services

Write-Host "Running integration tests..." -ForegroundColor Cyan
Write-Host ""

# Test Bitcoin Core
Write-Host "Testing Bitcoin Core..." -ForegroundColor Yellow
python "$PSScriptRoot\mempool-space\test-integration.py" --user $BITCOIN_RPC_USER --password $BITCOIN_RPC_PASSWORD --host $BITCOIN_RPC_HOST --port $BITCOIN_RPC_PORT

Write-Host ""
Write-Host "Integration tests complete!" -ForegroundColor Green
"@

$testScriptPath = Join-Path $PSScriptRoot "test-integration-all.ps1"
$testScript | Out-File -FilePath $testScriptPath -Encoding UTF8
Write-Host "  ✓ Created test script at: $testScriptPath" -ForegroundColor Green
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Restart your terminal to load environment variables" -ForegroundColor White
Write-Host "  2. Copy the .env template to your project directories:" -ForegroundColor White
Write-Host "     Copy-Item '$envPath' '<your-project>\.env'" -ForegroundColor Gray
Write-Host "  3. Run integration tests:" -ForegroundColor White
Write-Host "     .\test-integration-all.ps1" -ForegroundColor Gray
Write-Host "  4. Start developing!" -ForegroundColor White
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "  - Bitcoin Core setup: $PSScriptRoot\mempool-space\README.md" -ForegroundColor Gray
Write-Host "  - Integration testing: $PSScriptRoot\mempool-space\test-integration.py --help" -ForegroundColor Gray
Write-Host ""
Write-Host "Environment Variables Set:" -ForegroundColor Yellow
foreach ($key in $envVars.Keys) {
    Write-Host "  - $key" -ForegroundColor Gray
}
Write-Host ""
Write-Host "Happy coding! 🚀" -ForegroundColor Cyan
