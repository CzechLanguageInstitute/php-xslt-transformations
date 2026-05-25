# XSLT Pipeline Test Runner (PowerShell)
# 
# Runs the PHP test suite using Windows PowerShell
# This script invokes the PHP test runner and can also be used for local XML transformation testing

param(
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$PhpPath = "php",
    [switch]$Local = $false
)

$ErrorActionPreference = "Stop"

Write-Host "=== XSLT Pipeline Test Runner (PowerShell) ===" -ForegroundColor Cyan
Write-Host "Project Root: $ProjectRoot"
Write-Host ""

# Verify project structure
$inputDir = Join-Path $ProjectRoot "input"
$transformDir = Join-Path $ProjectRoot "transforms"
$expectedDir = Join-Path $ProjectRoot "expected"
$outputDir = Join-Path $ProjectRoot "output"
$testScript = Join-Path $PSScriptRoot "run-tests.php"

if (-not (Test-Path $testScript)) {
    Write-Host "ERROR: Test script not found: $testScript" -ForegroundColor Red
    exit 1
}

# Create output directory if it doesn't exist
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Run the PHP test suite
Write-Host "Running PHP test suite..." -ForegroundColor Yellow
Write-Host ""

& $PhpPath $testScript

$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "All tests passed!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Some tests failed!" -ForegroundColor Red
}

exit $exitCode
