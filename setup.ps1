<#
.SYNOPSIS
    Deploys Pi agent configuration files from this repository to your local Pi profile.

.DESCRIPTION
    Copies or creates symbolic links for settings.json, config.json, and SYSTEM.md into ~/.pi/agent.
    Automatically creates backups of existing files if they differ.

.PARAMETER Method
    Deployment method: 'Copy' (default) or 'Symlink'. Note: Symlinks on Windows may require Developer Mode or Admin rights.

.PARAMETER TargetDir
    Target directory for Pi agent files (defaults to $HOME\.pi\agent).
#>

[CmdletBinding()]
param (
    [ValidateSet("Copy", "Symlink")]
    [string]$Method = "Copy",

    [string]$TargetDir = "$env:USERPROFILE\.pi\agent"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Pi Configuration Setup ===" -ForegroundColor Cyan
Write-Host "Target directory: $TargetDir"
Write-Host "Method:           $Method"
Write-Host ""

if (-not (Test-Path -Path $TargetDir)) {
    Write-Host "Creating target directory: $TargetDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

$sourceDir = $PSScriptRoot
$configFiles = @("settings.json", "config.json", "SYSTEM.md")

foreach ($file in $configFiles) {
    $sourcePath = Join-Path $sourceDir $file
    $destPath   = Join-Path $TargetDir $file

    if (-not (Test-Path -Path $sourcePath)) {
        Write-Warning "Source file not found: $sourcePath, skipping."
        continue
    }

    if (Test-Path -Path $destPath) {
        $sourceContent = Get-Content -Raw -Path $sourcePath
        $destContent   = Get-Content -Raw -Path $destPath

        if ($sourceContent -ne $destContent) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupPath = "$destPath.bak_$timestamp"
            Write-Host "Backing up existing $file -> $file.bak_$timestamp" -ForegroundColor DarkGray
            Copy-Item -Path $destPath -Destination $backupPath -Force
        }
    }

    if ($Method -eq "Symlink") {
        try {
            if (Test-Path -Path $destPath) {
                Remove-Item -Path $destPath -Force
            }
            New-Item -ItemType SymbolicLink -Path $destPath -Target $sourcePath -Force | Out-Null
            Write-Host " [Symlink] $file -> $destPath" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to create symlink for $file ($($_.Exception.Message)). Falling back to Copy."
            Copy-Item -Path $sourcePath -Destination $destPath -Force
            Write-Host " [Copy]    $file -> $destPath" -ForegroundColor Green
        }
    }
    else {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host " [Copy]    $file -> $destPath" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Deployment completed successfully!" -ForegroundColor Cyan
Write-Host "Next steps on a new machine:" -ForegroundColor Yellow
Write-Host "  1. Run 'pi' - it will automatically download the packages listed in settings.json"
Write-Host "  2. Authenticate your provider (e.g., run '/login' or configure your API keys)"
